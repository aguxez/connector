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

      defoverridable handle_message: 2
    end
  end
end
