defmodule TemereServer.RoomTest do
  alias TemereServer.PlayerRegistry
  alias TemereServer.Room
  use ExUnit.Case, async: false

  setup do
    {:ok, player_1} = PlayerRegistry.create("vinicinho")
    {:ok, player_2} = PlayerRegistry.create("nocettinha")
    %{player_1: player_1, player_2: player_2}
  end

  @tag :room
  test "Create a room", %{player_1: player_1} do
    assert :ok = Room.start_link("xesquedele", player_1)
    assert {:error, _reason} = Room.start_link("xesquedele", player_1)
  end

  @tag :room
  test "Join a room", %{player_1: player_1, player_2: player_2} do
    assert :ok = Room.start_link("xesquedele", player_1)
    IO.inspect(Registry.lookup(TemereServer.RoomRegistry, "xesquedele"))
  end
end
