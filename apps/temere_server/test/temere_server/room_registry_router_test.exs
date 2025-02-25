defmodule TemereServer.RoomRegistryRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias TemereServer.Player
  alias TemereServer.RoomRegistry

  @opts TemereServer.init([])

  setup do
    player_1 = Player.create!("vgont")
    player_2 = Player.create!("nocettinha")
    %{player_1: player_1, player_2: player_2}
  end

  @tag :room_registry_router
  test "POST /room/new", %{player_1: player} do
    conn = conn(:post, "/room/new", %{player: player, room_name: "namae"})

    conn = TemereServer.call(conn, @opts)
    assert conn.status == 200
    assert {:ok, _room} = RoomRegistry.lookup(RoomRegistry, "namae")
  end

  @tag :room_registry_router
  test "GET /room/all", %{player_1: player} do
    RoomRegistry.create(RoomRegistry, player, "manae")

    conn = conn(:get, "/room/all")
    conn = TemereServer.call(conn, @opts)
    assert conn.status == 200
    [room_name | _] = Poison.decode!(conn.resp_body)
    assert room_name == "manae"
  end

  @tag :room_registry_router
  test "POST /room/join/:room_name", %{player_1: player_1, player_2: player_2} do
    {:ok, _room} = RoomRegistry.create(RoomRegistry, player_1, "joinit")

    conn = conn(:post, "/room/join/joinit", %{player: player_1})
    conn = TemereServer.call(conn, @opts)
    assert conn.status == 400

    conn = conn(:post, "/room/join/joinit", %{player: player_2})
    conn = TemereServer.call(conn, @opts)
    assert conn.status == 200
  end
end
