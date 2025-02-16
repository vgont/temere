defmodule TemereServer.RoomRegistryTest do
  alias TemereServer.Player
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(RoomRegistry)
    player1 = Player.create!("vinicinho")
    player2 = Player.create!("nocettinha")
    %{registry: registry, player1: player1, player2: player2}
  end

  test "Create a room.", %{registry: registry, player1: player1} do
    RoomRegistry.create(registry, player1, "first_room")
    assert {:ok, _room} = RoomRegistry.lookup(registry, "first_room")
    assert {:error, _reason} = RoomRegistry.create(registry, player1, "first_room")
  end

  test "Lookup a room.", %{registry: registry, player1: player1} do
    RoomRegistry.create(registry, player1, "first_room")
    assert {:ok, _room} = RoomRegistry.lookup(registry, "first_room")
  end

  test "Delete a room.", %{registry: registry, player1: player1} do
    RoomRegistry.create(registry, player1, "first_room")
    RoomRegistry.delete(registry, "first_room")
    assert {:error, _reason} = RoomRegistry.lookup(registry, "first_room")
  end
end
