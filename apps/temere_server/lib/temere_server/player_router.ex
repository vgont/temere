defmodule TemereServer.PlayerRouter do
  use Plug.Router
  import Plug.Conn
  alias TemereServer.PlayerRegistry

  plug(:match)
  plug(:dispatch)

  get "/new/:name" do
    {:ok, player} = PlayerRegistry.register(name)
    conn = send_resp(conn, 201, Poison.encode!(player))
    conn
  end
end
