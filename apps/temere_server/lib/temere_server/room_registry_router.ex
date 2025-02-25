defmodule TemereServer.RoomRegistryRouter do
  use Plug.Router
  import Plug.Conn
  alias TemereServer.RoomRegistry

  plug(:match)
  plug(:dispatch)

  post "/new" do
    player = conn.body_params["player"]
    room_name = conn.body_params["room_name"]
    {:ok, _room} = RoomRegistry.create(TemereServer.RoomRegistry, player, room_name)
    conn = send_resp(conn, 200, Poison.encode!(%{message: "Room successfully created"}))
    conn
  end

  get "/all" do
    rooms = inspect(RoomRegistry.get_all_rooms(TemereServer.RoomRegistry))
    conn = send_resp(conn, 200, rooms)
    conn
  end

  post "/join/:room_name" do
    player = conn.body_params["player"]
    result = RoomRegistry.join(TemereServer.RoomRegistry, room_name, player)
    case result do
      :ok -> send_resp(conn, 200, Poison.encode!(%{message: "Player successfully joined"}))
      {:error, reason} -> send_resp(conn, 400, Poison.encode!(%{message: reason}))
    end
  end
end
