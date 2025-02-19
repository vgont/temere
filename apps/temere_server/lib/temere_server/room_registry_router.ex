defmodule TemereServer.RoomRegistryRouter do
  use Plug.Router
  import Plug.Conn
  alias TemereServer.RoomRegistry

  plug(:match)
  plug(:dispatch)

  post "/new" do
    player = conn.body_params["player"]
    room_name = conn.body_params["room_name"]
    :ok = RoomRegistry.create(TemereServer.RoomRegistry, player, room_name)
    conn = send_resp(conn, 200, "Joined")
    conn
  end
end
