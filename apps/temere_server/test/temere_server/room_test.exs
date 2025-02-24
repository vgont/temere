defmodule TemereServer.RoomTest do
  alias TemereServer.RoomRegistry
  alias TemereServer.Player
  alias TemereServer.Room
  use ExUnit.Case, async: true

  setup context do
    player_1 = Player.create!("vinicinho")
    player_2 = Player.create!("nocettinha")
    GenServer.start_link(Room, player_1, name: context.test)
    %{room: context.test, player_1: player_1, player_2: player_2}
  end

  @tag :room
  test "A player joins the room. Room can hold only 2 players", %{room: room, player_2: player_2} do
    assert :ok = Room.join(room, player_2)

    invalid_player = Player.create!("invalid_player")
    assert {:error, :full_room} = Room.join(room, invalid_player)
  end

  @tag :room
  test "A player exits the room", %{player_1: player_1} do
    assert :ok = RoomRegistry.create(RoomRegistry, player_1, "xesquedele")
    {:ok, room} = RoomRegistry.lookup(RoomRegistry, "xesquedele")

    assert :ok = Room.exit(room, player_1)

    assert {:error, :not_found} = RoomRegistry.lookup(RoomRegistry, "xesquedele")
  end

  @tag :room
  test "A player can change the helper", %{room: room, player_2: player_2} do
    Room.join(room, player_2)

    assert {:ok, old_helper, old_guesser} = Room.get_helper_and_guesser(room)
    assert {:ok, new_helper, new_guesser} = Room.change_helper(room)

    assert old_helper == new_guesser
    assert old_guesser == new_helper
  end

  @tag :room
  test "Player SET and GET a word to the room", %{room: room} do
    assert {:ok, nil} = Room.get_word(room)

    assert :ok = Room.set_word(room, "word")

    assert {:ok, word} = Room.get_word(room)
    assert word == "word"
  end
end
