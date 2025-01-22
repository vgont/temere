defmodule TemereServer.RoomTest do
  alias TemereServer.Player
  alias TemereServer.Room
  use ExUnit.Case, async: true

  setup context do
    player_1 = Player.create!("vinicinho")
    GenServer.start_link(Room, player_1, name: context.test)
    %{room: context.test}
  end

  test "A player joins the room. Room can hold only 2 players", %{room: room} do
    player = Player.create!("nocettinha")
    {:ok, players} = Room.join(room, player)

    assert Enum.at(players, 0).name == "nocettinha"
    assert Enum.at(players, 1).name == "vinicinho"

    player = Player.create!("invalid_player")
    assert {:error, _} = Room.join(room, player)
  end

  test "A player exits the room", %{room: room} do
    player = Player.create!("nocettinha")
    {:ok, _players} = Room.join(room, player)

    assert :ok = Room.exit(room, player)
  end
end
