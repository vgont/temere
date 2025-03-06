defmodule TemereServer do
  use Plug.Router

  plug(:match)

  plug CORSPlug, origin: "http://localhost:5173"

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/player", to: TemereServer.PlayerRouter)
  forward("/room", to: TemereServer.RoomRouter)

  get "/health" do
    conn = send_resp(conn, 200, set_message("temere is running!"))
    conn
  end

  get "game/:room_name" do
    conn
  end

  def set_message(message) do
    Poison.encode!(%{message: message})
  end
end
