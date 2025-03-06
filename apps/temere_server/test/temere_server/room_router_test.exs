defmodule TemereServer.RoomRouterTest do
  alias TemereServer.PlayerRegistry
  use ExUnit.Case, async: true
  use Plug.Test

  @opts TemereServer.init([])

  setup do
    {:ok, player_1} = PlayerRegistry.register("vgont")
    %{player_1: player_1}
  end

  @tag :here
  test "GET /room/new", %{player_1: player_1} do
    conn = conn(:get, "/room/new", %{room_name: "namae", player: player_1.uuid})
    IO.inspect(conn)
  end
end
