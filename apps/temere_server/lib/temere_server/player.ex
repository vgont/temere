defmodule TemereServer.Player do
  alias __MODULE__
  @derive [Poison.Encoder]
  defstruct [:uuid, :name, :type]

  @type t() :: %Player{
          uuid: String.t(),
          name: String.t(),
          type: atom() | nil
        }

  def create!(name) when is_binary(name) do
    %Player{uuid: UUID.uuid4(), name: name}
  end
end
