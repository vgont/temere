defmodule TemereServer.RoomRegistryTest do
  alias TemereServer.Player
  alias TemereServer.RoomRegistry
  use ExUnit.Case, async: true

  setup do
    player_1 = Player.create!("vinicinho")
    player_2 = Player.create!("nocettinha")
    %{player_1: player_1, player_2: player_2}
  end

  @tag :room_registry
  test "Create a room.", %{player_1: player_1} do
    RoomRegistry.create(RoomRegistry, player_1, "first_room")
    assert {:ok, _room} = RoomRegistry.lookup(RoomRegistry, "first_room")
    assert {:error, _reason} = RoomRegistry.create(RoomRegistry, player_1, "first_room")
  end

  @tag :room_registry
  test "Get all rooms.", %{player_1: player_1} do
    RoomRegistry.create(RoomRegistry, player_1, "second_room")
    assert rooms = RoomRegistry.get_all_rooms(RoomRegistry)
    assert length(rooms) > 0
  end

  @tag :room_registry
  test "Join a room.", %{player_1: player_1, player_2: player_2} do
    RoomRegistry.create(RoomRegistry, player_1, "joinar")
    assert {:error, _} = RoomRegistry.join(RoomRegistry, "joinar", player_1)
    assert :ok = RoomRegistry.join(RoomRegistry, "joinar", player_2)
  end
end
