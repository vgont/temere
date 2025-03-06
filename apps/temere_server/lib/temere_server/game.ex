defmodule TemereServer.Game do
  alias TemereServer.Room
  @behaviour WebSock
  require Logger

  def init(room_name), do: {:ok, room_name}

  def handle_in({"get_state", _}, room_name) do
    state = Room.get_state(room_name)
    state = Map.drop(state, [:helper, :guesser])
    {:push, {:text, Poison.encode!(%{state: state})}, room_name}
  end

  def handle_in({"set_word:" <> word, _}, room_name) do
    Logger.info("Helper set word: \"#{word}\"")
    Room.set_word(room_name, word)
    {:ok, room_name}
  end

  def handle_in({"add_hint:" <> hint, _}, room_name) do
    Logger.info("Helper add hint: \"#{hint}\"")

    case Room.add_hint(room_name, hint) do
      :ok -> {:ok, room_name}
      {:error, reason} -> {:push, {:text, reason}, room_name}
    end
  end

  def handle_in({"try_guess:" <> guess, _}, room_name) do
    case Room.try_guess(room_name, guess) do
      :ok -> {:push, {:text, send_message("You guessed it!")}, room_name}
      {:error, reason} -> {:push, {:text, send_message(reason)}, room_name}
    end
  end

  def handle_info({:hints, hints}, state) do
    {:push, {:text, %{hints: hints}}, state}
  end

  def handle_info(:word_set, state) do
    Logger.info("Word set!")
    {:push, {:text, Poison.encode!(%{message: "word set"})}, state}
  end

  def terminate(_reason, room_name) do
    Room.leave(self(), room_name)
  end

  defp send_message(message) do
    Poison.encode!(%{"message" => message})
  end
end
