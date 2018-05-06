# Connector - SignalR client for Elixir.

## Installation

Not available in Hex for now, use Github's version.

```elixir
def deps do
  [
    {:connector, github: "aguxez/connector"}
  ]
end
```

## Usage
The process is pretty straight forward, you'll want to create a `start_link` function your module and add it to your Supervision tree. `Connector.Interface.start_link/1` expects a map as the argument, it has required keys, example:

```elixir
# We're suppose you're going to connect to Bittrex websocket API.
state = %{
  base_url: "https://socket.bittrex.com/signalr",
  ws_url: "wss://socket.bittrex.com/signalr",
  transport: "webSockets",
  negotiate_query: %{
    connection_data: [%{name: "c2"}]
  },
  connect_query: %{
    connection_data: [%{name: "c2"}]
  },
  start_query: %{
    connection_data: [%{name: "c2"}]
  },
  mod: MyApp.Module
}
```
"webSockets" is the only transport supported for now.

`:mod` is the module that will implement the `handle_message/2` callback. In this case `MyApp.Module.handle_message(frame, text)` will be the the module handling data incoming from the websocket.

### Example
```elixir
defmodule MyApp.Module do
  @moduledoc false

  use Connector

  def start_link do
    # Bittrex websocket args
    state = %{
      base_url: "https://socket.bittrex.com/signalr",
      ws_url: "wss://socket.bittrex.com/signalr",
      transport: "webSockets",
      negotiate_query: %{
        connection_data: [%{name: "c2"}]
      },
      connect_query: %{
        connection_data: [%{name: "c2"}]
      },
      start_query: %{
        connection_data: [%{name: "c2"}]
      },
      mod: MyApp.Module
    }

    Connector.Interface.start_link(state)
  end

  def handle_message({:text, msg}, state) do
    msg
    |> Jason.decode!()
    |> IO.inspect()

    {:ok, state}
  end
end
```

`handle_message/2` should return `{:ok, state}`
