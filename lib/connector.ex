defmodule Connector do
  @moduledoc false

  # state = %{
  #   base_url: "https://socket.bittrex.com/signalr",
  #   ws_url: "wss://socket.bittrex.com/signalr",
  #   transport: "webSockets",
  #   negotiate_query: %{
  #     connection_data: [%{name: "c2"}]
  #   },
  #   connect_query: %{
  #     connection_data: [%{name: "c2"}]
  #   },
  #   start_query: %{
  #     connection_data: [%{name: "c2"}]
  #   }
  # }

  @type data :: any
  @type state :: any
  @tyope error :: any

  @callback handle_message(data, state) :: {:ok, state} | {:error, error}

  defmacro __using__(_opts) do
    quote do
      @behaviour Connector

      alias Connector.Interface

      def start_link(state) do
        Interface.start_link(state)
      end

      def handle_message(_data, state), do: {:ok, state}

      defoverridable handle_message: 2
    end
  end
end
