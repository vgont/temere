defmodule TemereServer.Room do
  alias TemereServer.RoomRegistry

  use GenServer

  def join(room, player) do
    GenServer.call(room, {:join, player})
  end

  def get_helper_and_guesser(room) do
    GenServer.call(room, :get_helper_and_guesser)
  end

  def set_word(room, word) do
    GenServer.call(room, {:set_word, word})
  end

  def change_helper(room) do
    GenServer.call(room, :change_helper)
  end

  def get_word(room) do
    GenServer.call(room, :get_word)
  end

  def add_hint(room, hint) do
    GenServer.call(room, {:add_hint, hint})
  end

  def exit(room, player) do
    GenServer.call(room, {:exit, player})
  end

  @impl true
  def init(player_1) do
    {:ok, %{helper: player_1, guesser: nil, word: nil, hints: []}}
  end

  @impl true
  def handle_call({:join, player}, _from, %{helper: helper, guesser: guesser} = state) do
    cond do
      guesser == nil -> {:reply, :ok, %{state | guesser: player}}
      helper == nil -> {:reply, :ok, %{state | helper: player}}
      true -> {:reply, {:error, :full_room}, state}
    end
  end

  @impl true
  def handle_call(:get_helper_and_guesser, _from, %{helper: helper, guesser: guesser} = state) do
   {:reply, {:ok, helper, guesser}, state}
  end

  @impl true
  def handle_call(:change_helper, _from, %{helper: helper, guesser: guesser} = state)
      when helper != nil and guesser != nil do
    {:reply, {:ok, guesser, helper}, %{state | helper: guesser, guesser: helper}}
  end

  @impl true
  def handle_call({:set_word, word}, _from, state) do
    {:reply, :ok, %{state | word: word}}
  end

  @impl true
  def handle_call(:get_word, _from, %{word: word} = state) do
    {:reply, {:ok, word}, state}
  end

  @impl true
  def handle_call({:add_hint, _hint}, _from, %{hints: hints} = state) when length(hints) == 5 do
    {:reply, {:error, :max_hints_reached}, state}
  end

  @impl true
  def handle_call({:add_hint, hint}, _from, %{word: word, hints: hints} = state)
      when hint != word do
    case Enum.member?(hints, hint) do
      true -> {:reply, {:error, :hint_already_used}, state}
      false -> {:reply, :ok, %{state | hints: [hint | hints]}}
    end
  end

  @impl true
  def handle_call({:add_hint, _hint}, _from, state), do: {:reply, {:error, :wrong_hint}, state}

  @impl true
  def handle_call({:exit, player}, _from, %{helper: helper, guesser: guesser} = state) do
    state =
      case player do
        ^helper -> %{state | helper: nil}
        ^guesser -> %{state | guesser: nil}
      end

    cond do
      state.helper == nil and state.guesser == nil ->
        send(RoomRegistry, {:delete, self()})
        {:stop, :normal, :ok, state}

      true ->
        {:reply, :ok, state}
    end
  end
end
