defmodule TemereServer.Room do
  alias TemereServer.RoomRegistry

  use GenServer

  def join(room, player) do
    GenServer.call(room, {:join, player})
  end

  def get_helper_and_guesser(room) do
    GenServer.call(room, :get_helper_and_guesser)
  end

  def set_word(room, word, player) do
    GenServer.call(room, {:set_word, word, player})
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
  def handle_call({:join, player}, _from, %{helper: helper, guesser: guesser} = state)
      when player != helper and player != guesser do
    cond do
      guesser == nil -> {:reply, :ok, %{state | guesser: player}}
      helper == nil -> {:reply, :ok, %{state | helper: player}}
      true -> {:reply, {:error, "room already full"}, state}
    end
  end

  def handle_call({:join, _player}, _from, state), do: {:reply, {:error, "player already joined"}, state}

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
  def handle_call({:set_word, word, player}, _from, %{helper: helper} = state) do
    case player do
      ^helper -> {:reply, :ok, %{state | word: word}}
      _ -> {:reply, {:error, "Only the helper can set the word"}, state}
    end
  end

  @impl true
  def handle_call(:get_word, _from, %{word: word} = state) do
    {:reply, {:ok, word}, state}
  end

  @impl true
  def handle_call({:add_hint, _hint}, _from, %{hints: hints} = state) when length(hints) == 5 do
    {:reply, {:error, "max hints reached"}, state}
  end

  @impl true
  def handle_call({:add_hint, hint}, _from, %{word: word, hints: hints} = state)
      when hint != word do
    case Enum.member?(hints, hint) do
      true -> {:reply, {:error, "hint already used"}, state}
      false -> {:reply, :ok, %{state | hints: [hint | hints]}}
    end
  end

  @impl true
  def handle_call({:add_hint, _hint}, _from, state), do: {:reply, {:error, "invalid hint"}, state}

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
