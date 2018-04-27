defmodule Connector.Interface do
  @moduledoc false

  use Tesla
  use GenServer

  require Logger

  alias Connector.Client.{Line}
  alias Tesla.Middleware

  @keys ~w(
    connection_id connection_timeout connection_token disconnect_timeout keep_alive_timeout
    long_poll_delay protocol_version transport_connect_timeout try_web_sockets url
  )a

  def start_link(state) do
    GenServer.start_link(__MODULE__, Map.put(state, :existing_keys, @keys), name: :connector)
  end

  # SERVER

  def init(state) do
    send(self(), :negotiate)

    {:ok, Map.drop(state, [:existing_keys])}
  end

  def handle_info(:negotiate, state) do
    new_state = negotiate(state)

    {:noreply, new_state}
  end

  def negotiate(state) do
    conn_data = Jason.encode!(state.negotiate_query.connection_data)

    request =
      [connectionData: conn_data]
      |> client(state.base_url, %{})
      |> get("/negotiate")

    do_negotiate(request.body, state)
  end

  def do_negotiate(request, state) do
    request
    |> Enum.map(fn{key, value} ->
      new_key =
        key
        |> Macro.underscore()
        |> String.to_existing_atom()

      {new_key, value}
    end)
    |> Enum.into(%{})
    |> Map.merge(state)
    |> connect()
  end

  def connect(state) do
    www_query =
      state.connect_query.connection_data
      |> Jason.encode!()
      |> URI.encode_www_form()

    params =
      %{
        transport: state.transport,
        clientProtocol: state.protocol_version,
        connectionToken: state.connection_token
      }
      |> URI.encode_query()
      |> (&(&1 <> "&connectionData=" <> www_query)).()

    Line.start_link(state.ws_url <> "/connect?" <> params, state)

    start(state)
  end

  def start(state) do
    query_params = [
      transport: state.transport,
      connectionToken: state.connection_token,
      connectionData: Jason.encode!(state.start_query.connection_data)
    ]

    request =
      query_params
      |> client(state.base_url, %{})
      |> get("/start")

    case request.body do
      %{"Response" => "started"} ->
        {:noreply, state}

      error ->
        Logger.error("#{error}")

        {:stop, :normal}
    end
  end

  defp client(query, url, headers) do
    Tesla.build_client([
      {Middleware.BaseUrl, url},
      {Middleware.Headers, Map.merge(%{}, headers)},
      {Middleware.Query, Keyword.merge([clientProtocol: 1.5], query)},
      {Middleware.JSON, encode: &Jason.encode/1, decode: &Jason.decode/1}
    ])
  end
end
