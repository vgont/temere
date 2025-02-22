defmodule TemereServer.Room do
  alias TemereServer.RoomRegistry

  use GenServer

  def join(room, player) do
    GenServer.call(room, {:join, player})
  end

  def set_word(room, {word, player}) do
    GenServer.call(room, {:set_word, {word, player}})
  end

  def add_hint(room, hint) do
    GenServer.call(room, {:add_hint, hint})
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
  def handle_call({:set_word, word}, _from, %{word: word} = state) do
    {:reply, :ok, %{state | word: word}}
  end

  @impl true
  def handle_call({:add_hint, _hint}, _from, %{hints: hints} = state) when length(hints) == 5 do
    {:reply, {:error, :max_hints_reached}, state}
  end

  @impl true
  def handle_call({:add_hint, hint}, _from, %{word: word, hints: hints} = state) when hint != word do
    case Enum.member?(hints, hint) do
      true -> {:reply, {:error, :hint_already_used}, state}
      false -> {:reply, :ok, %{state | hints: [hint | hints]}}
    end
  end

  @impl true
  def handle_call({:add_hint, _hint}, _from, state), do: {:reply, {:error, :wrong_hint}, state}

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
