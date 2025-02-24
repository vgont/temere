defmodule TemereServer.PlayerTest do
  alias TemereServer.Player
  use ExUnit.Case, async: true

  setup context do
    GenServer.start_link(TemereServer.Room, :ok, name: context.test)
    %{room: context.test}
  end

  test "creates a new player" do
    player = Player.create!("vgont")
    assert player.uuid != nil
    assert player.name == "vgont"
  end
end
