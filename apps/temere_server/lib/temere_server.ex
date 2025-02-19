defmodule TemereServer do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/player", to: TemereServer.PlayerRouter)
  forward("/room", to: TemereServer.RoomRegistryRouter)
end
