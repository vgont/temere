defmodule TemereServer.PlayerRegistry do
  use GenServer
  alias __MODULE__
  @derive [Poison.Encoder]
  require Logger

  defstruct [:uuid, :name]

  @type t :: %PlayerRegistry{uuid: String.t(), name: String.t()}

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register(player_name) do
    GenServer.call(__MODULE__, {:register, player_name})
  end

  def lookup(uuid) do
    GenServer.call(__MODULE__, {:lookup, uuid})
  end

  def init(players), do: {:ok, players}

  def handle_call({:register, player_name}, _from, players) do
    player = %PlayerRegistry{uuid: UUID.uuid4(), name: player_name}
    Logger.info("Registering player #{player_name} | id: #{player.uuid}")
    {:reply, {:ok, player}, [player | players]}
  end

  def handle_call({:lookup, uuid}, _from, players) do
    case Enum.find(players, fn player -> player.uuid == uuid end) do
      nil -> {:reply, :not_found, players}
      player -> {:reply, {:ok, player}, players}
    end
  end
end
