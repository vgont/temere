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

  test "GET /room/all" do
    player = Player.create!("vgont")
    RoomRegistry.create(RoomRegistry, player, "manae")

    conn = conn(:get, "/room/all")
    conn = TemereServer.call(conn, @opts)
    assert conn.status == 200
    [room_name | _] = Poison.decode!(conn.resp_body)
    assert room_name == "manae"
  end
end
