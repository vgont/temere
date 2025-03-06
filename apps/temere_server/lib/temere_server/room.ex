defmodule TemereServer.Room do
  use GenServer
  alias TemereServer.PlayerRegistry
  require Logger

  defstruct room_name: "", guesser: nil, helper: nil, word: nil, hints: []

  @type t :: %__MODULE__{
          room_name: String.t(),
          guesser: %{ws_pid: pid, player: PlayerRegistry.t()} | nil,
          helper: %{ws_pid: pid, player: PlayerRegistry.t()},
          word: String.t() | nil,
          hints: [String.t()] | []
        }

  def start_link(room_name, player) do
    result =
      GenServer.start_link(
        __MODULE__,
        %{room_name: room_name, helper: player, guesser: nil, word: nil, hints: []},
        name: get_room(room_name)
      )

    case result do
      {:ok, _} -> :ok
      {:error, _} -> {:error, "Room already exists"}
    end
  end

  def join(room_name, player) do
    GenServer.call(get_room(room_name), {:join, player})
  end

  def get_state(room_name) do
    GenServer.call(get_room(room_name), :get_state)
  end

  def set_word(room_name, word) do
    GenServer.cast(get_room(room_name), {:set_word, word})
  end

  def add_hint(room_name, hint) do
    GenServer.call(get_room(room_name), {:add_hint, hint})
  end

  def try_guess(room_name, guess) do
    GenServer.call(get_room(room_name), {:try_guess, guess})
  end

  def get_players(room_name) do
    GenServer.call(get_room(room_name), :get_players)
  end

  def leave(ws_pid, room_name) do
    GenServer.call(get_room(room_name), {:leave, ws_pid})
  end

  @impl true
  @spec init(t()) :: {:ok, t()}
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:join, player}, _from, state) do
    cond do
      state.helper == nil ->
        {:reply, :ok, %{state | helper: player}}

      state.guesser == nil ->
        {:reply, :ok, %{state | guesser: player}}

      true ->
        {:reply, {:error, "Room is full"}, state}
    end
  end

  @impl true
  def handle_call({:add_hint, hint}, {pid, _}, %{word: word, hints: hints, guesser: guesser} = state) do
    cond do
      hint == word ->
        {:reply, {:error, "Hint is the same as the word"}, state}

      length(hints) == 5 ->
        {:reply, {:error, "Max number of hints reached"}, state}

      true ->
        hints = hints ++ [hint]
        send(guesser.ws_pid, {:hints, hints})
        {:reply, :ok, %{state | hints: hints}}
    end
  end

  @impl true
  def handle_call({:try_guess, guess}, _from, state) do
    cond do
      state.word == guess -> {:reply, :ok, %{state | guesser: nil}}
      true -> {:reply, {:error, "Wrong guess"}, state}
    end
  end

  @impl true
  def handle_call(:get_state, {pid, _}, state) do
    player_type = 
      cond do
        state.helper.ws_pid == pid -> "helper"
        state.guesser.ws_pid == pid -> "guesser"
        true -> "none"
      end
    response = Map.merge(state, %{player_type: player_type})
    {:reply, response, state}
  end

  @impl true
  def handle_call({:leave, ws_pid}, _from, %{helper: helper, guesser: guesser} = state) do
    cond do
      helper.ws_pid == ws_pid ->
        {:reply, :ok, %{state | helper: nil}}

      guesser.ws_pid == ws_pid ->
        {:reply, :ok, %{state | guesser: nil}}

      true ->
        {:reply, {:error, "Player not found"}, state}
    end
  end

  @impl true
  def handle_cast({:set_word, word}, %{guesser: guesser} = state) do
    send(guesser.ws_pid, :word_set)
    {:noreply, %{state | word: word}}
  end

  @spec get_room(room_name :: String.t()) ::
          {:via, Registry, {TemereServer.RoomRegistry, String.t()}}
  defp get_room(room_name) do
    {:via, Registry, {TemereServer.RoomRegistry, room_name}}
  end
end
