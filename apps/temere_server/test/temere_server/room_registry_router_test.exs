defmodule TemereServer.RoomRegistryRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias TemereServer.Player
  alias TemereServer.RoomRegistry

  @opts TemereServer.init([])

  test "POST /room/new" do
    player = Player.create!("vgont")
    conn = conn(:post, "/room/new", %{player: player, room_name: "namae"})

    conn = TemereServer.call(conn, @opts)
    assert conn.status == 200
    assert {:ok, _room} = RoomRegistry.lookup(RoomRegistry, "namae")
  end
end
