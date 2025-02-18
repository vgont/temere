defmodule TemereServer.PlayerRouter do
  use Plug.Router
  import Plug.Conn
  alias TemereServer.Player

  plug(:match)
  plug(:dispatch)

  post "/new" do
    player = conn.body_params
    player = Player.create!(player["name"])
    conn = send_resp(conn, 200, Poison.encode!(player))
    conn
  end
end
