defmodule TemereServer.Room do
  alias TemereServer.RoomRegistry

  use GenServer

  ## Client API
  def join(room, player) do
    GenServer.call(room, {:join, player})
  end

  def exit(room, player) do
    GenServer.call(room, {:exit, player})
  end

  @impl true
  def init(player_1) do
    {:ok, %{players: [player_1], word: nil, hints: []}}
  end

  @impl true
  def handle_call({:join, player}, _from, %{players: players} = state) when length(players) < 2 do
      players = [player | players]
      {:reply, {:ok, players}, %{state | players: players}}
  end

  @impl true
  def handle_call({:join, _player}, _from, state), do: {:reply, {:error, :full_room}, state}

  @impl true
  def handle_call({:exit, player}, _from, %{players: players} = state) do
    players = remove_player(players, player)

    if players == [] do
      send(RoomRegistry, {:delete, self()})
      {:stop, :normal, :ok, %{state | players: players}}
    else
      {:reply, :ok, %{state | players: players}}
    end
  end

  defp remove_player(players, player), do: Enum.reject(players, &(&1 == player))
end
