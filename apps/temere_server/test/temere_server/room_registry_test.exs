defmodule TemereServer.RoomRegistryTest do
  alias TemereServer.Player
  alias TemereServer.RoomRegistry
  use ExUnit.Case, async: true

  setup do
    player1 = Player.create!("vinicinho")
    player2 = Player.create!("nocettinha")
    %{player1: player1, player2: player2}
  end

  test "Create a room.", %{player1: player1} do
    RoomRegistry.create(RoomRegistry, player1, "first_room")
    assert {:ok, _room} = RoomRegistry.lookup(RoomRegistry, "first_room")
    assert {:error, _reason} = RoomRegistry.create(RoomRegistry, player1, "first_room")
  end

  test "Lookup a room.", %{player1: player1} do
    RoomRegistry.create(RoomRegistry, player1, "first_room")
    assert {:ok, _room} = RoomRegistry.lookup(RoomRegistry, "first_room")
  end
end
