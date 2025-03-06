defmodule TemereServer.RoomRouter do
  alias TemereServer.PlayerRegistry
  alias TemereServer.Room
  use Plug.Router
  import Plug.Conn
  require Logger

  plug(:match)
  plug(:dispatch)

  get "/new" do
    %{"room_name" => room_name, "player" => player_uuid} = conn.query_params
    {:ok, player} = PlayerRegistry.lookup(player_uuid)
    player = %{ws_pid: self(), player: player}

    case Room.start_link(room_name, player) do
      :ok -> 
        Logger.info("Player #{inspect(player)} created room #{room_name}")
        WebSockAdapter.upgrade(conn, TemereServer.Game, room_name, timeout: :infinity)
      {:error, reason} -> 
        Logger.info("ERROR: Player #{inspect(player)} created room #{room_name}")
        send_resp(conn, 400, Poison.encode!(%{message: reason}))
    end
  end

  get "/join" do
    %{"room_name" => room_name, "player" => player_uuid} = conn.query_params
    {:ok, player} = PlayerRegistry.lookup(player_uuid)
    player = %{ws_pid: self(), player: player}

    case Room.join(room_name, player) do
      :ok ->
        Logger.info("Player #{inspect(player)} joined room #{room_name}")
        WebSockAdapter.upgrade(conn, TemereServer.Game, room_name, timeout: :infinity)
      {:error, reason} ->
        Logger.info("ERROR: Player #{inspect(player)} joined room #{room_name}")
        send_resp(conn, 400, Poison.encode!(%{message: reason}))
    end
  end
end
