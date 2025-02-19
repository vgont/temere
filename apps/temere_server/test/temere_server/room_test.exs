defmodule TemereServer.RoomTest do
  alias TemereServer.RoomRegistry
  alias TemereServer.Player
  alias TemereServer.Room
  use ExUnit.Case, async: true

  setup context do
    player_1 = Player.create!("vinicinho")
    GenServer.start_link(Room, player_1, name: context.test)
    %{room: context.test, player_1: player_1}
  end

  test "A player joins the room. Room can hold only 2 players", %{room: room} do
    player = Player.create!("nocettinha")
    {:ok, players} = Room.join(room, player)

    assert Enum.at(players, 0).name == "nocettinha"
    assert Enum.at(players, 1).name == "vinicinho"

    player = Player.create!("invalid_player")
    assert {:error, :full_room} = Room.join(room, player)
  end

  test "A player exits the room", %{player_1: player_1} do
    player = Player.create!("nocettinha")

    assert :ok = RoomRegistry.create(RoomRegistry, player_1, "xesquedele")
    {:ok, room} = RoomRegistry.lookup(RoomRegistry, "xesquedele")

    assert :ok = Room.exit(room, player_1)

    assert {:error, :not_found} = RoomRegistry.lookup(RoomRegistry, "xesquedele")
  end
end
