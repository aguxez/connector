defmodule Connector.Client.Line do
  @moduledoc """
  Websocket module.
  """

  use WebSockex

  require Logger

  def start_link(url, state) do
    opts = [name: :line, handle_initial_conn_failure: true]
    WebSockex.start_link(url, __MODULE__, state, opts)
  end

  def send(frame, type) do
    WebSockex.send_frame(:line, {type, frame})
  end

  def handle_connect(_conn, state) do
    Logger.debug("Connected...")

    {:ok, state}
  end

  def handle_frame(msg, state) do
    state.mod.handle_message(msg, state)
  end

  def handle_disconnect(_conn, state) do
    Logger.debug("Disconnected...")

    {:ok, state}
  end
end
