defmodule TemereServer.RoomRegistry do
  alias TemereServer.Room
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, :rooms, name: __MODULE__)
  end

  def create(server, player, room_name) do
    GenServer.call(server, {:create, player, room_name})
  end

  def lookup(server, room_name) do
    GenServer.call(server, {:lookup, room_name})
  end

  def init(room_table) do
    :ets.new(room_table, [:set, :protected, :named_table])
    {:ok, room_table}
  end

  def handle_call({:create, player, room_name}, _from, room_table) do
    case :ets.lookup(room_table, room_name) do
      [] ->
        {:ok, room} = GenServer.start_link(Room, player)
        :ets.insert(room_table, {room_name, room})

        {:reply, :ok, room_table}

      _ ->
        {:reply, {:error, :already_exists}, room_table}
    end
  end

  def handle_call({:lookup, room_name}, _from, room_table) do
    case :ets.lookup(room_table, room_name) do
      [{^room_name, room}] -> {:reply, {:ok, room}, room_table}
      [] -> {:reply, {:error, :not_found}, room_table}
    end
  end

  def handle_info({:delete, room}, room_table) do
    :ets.match_delete(room_table, {:"$1", room})
    {:noreply, room_table}
  end
end
