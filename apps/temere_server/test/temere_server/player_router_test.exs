defmodule PlayerRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias TemereServer.Player

  @opts TemereServer.init([])

  test "POST /player/new" do
    conn = conn(:post, "/player/new", %{name: "vgont"})

    conn = TemereServer.call(conn, @opts)
    assert conn.status == 200

    player = Poison.decode!(conn.resp_body, as: %Player{})
    assert player.name == "vgont"
  end
end
