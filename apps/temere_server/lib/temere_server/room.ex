defmodule TemereServer.Room do
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
    {:ok, %{players: [player_1], status: :waiting_for_player}}
  end

  @impl true
  def handle_call({:join, player}, _from, state) do
    players = state.players

    if length(players) < 2 do
      players =
        [player | players]
        |> Enum.reject(&is_nil/1)

      {:reply, {:ok, players}, %{players: players, status: :ready}}
    else
      {:reply, {:error, :full_room}, state}
    end
  end

  @impl true
  def handle_call({:exit, player}, _from, state) do
    players = Enum.reject(state.players, &(&1 == player))

    cond do
      Enum.find(players, &(&1 == player)) != nil ->
        {:reply, {:error, :player_not_found}, state}

      length(players) == 0 ->
        {:stop, :room_without_players, :ok, state}

      true ->
        {:reply, :ok, %{players: players, status: :waiting_for_player}}
    end
  end
end
