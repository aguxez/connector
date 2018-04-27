defmodule Connector.Client.Starter do
  @moduledoc false

  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{}, name: :starter)
  end

  def init(state) do
    send(self(), :init)

    {:ok, state}
  end

  def handle_info(:init, state) do
    Connector.negotiate([])

    {:noreply, state}
  end
end
