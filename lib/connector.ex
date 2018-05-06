defmodule Connector do
  @moduledoc false

  @type data :: any
  @type state :: any
  @type error :: any

  @callback handle_message(data, state) :: {:ok, state} | {:error, error}

  def send(message, type) do
    WebSockex.send_frame(:line, {type, message})
  end

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Connector

      def handle_message(_data, state), do: {:ok, state}

      def child_spec(_arg) do
        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []}
        }

        Supervisor.child_spec(spec, restart: :permanent)
      end

      defoverridable handle_message: 2, child_spec: 1
    end
  end
end
