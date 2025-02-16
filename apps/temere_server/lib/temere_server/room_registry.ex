defmodule RoomRegistry do
  alias TemereServer.Room
  use GenServer

  ## Client API
  def start_link([]) do
    GenServer.start_link(RoomRegistry, :rooms)
  end

  def create(server, player, room_name) do
    GenServer.call(server, {:create, player, room_name})
  end

  def lookup(server, room_name) do
    GenServer.call(server, {:lookup, room_name})
  end

  def delete(server, room_name) do
    GenServer.call(server, {:delete, room_name})
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

  def handle_call({:delete, room}, _from, room_table) do
    :ets.delete(room_table, room)
    {:reply, :ok, room_table}
  end
end
