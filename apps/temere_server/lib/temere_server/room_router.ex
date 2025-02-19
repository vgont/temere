defmodule TemereServer.RoomRouter do
  alias TemereServer.Room
  use Plug.Router
  import Plug.Conn

  plug(:match)
  plug(:dispatch)

  post "/join/:room" do
    player = conn.body_params.player
    {:ok, _players} = Room.join(room, player)
    conn = send_resp(conn, 200, "Joined")
    conn
  end
end
