defmodule SimpleStatEx.SimpleStat do
  use Ecto.Schema
  import Ecto.Changeset
  alias SimpleStatEx.SimpleStat


  schema "simplestats" do
    field :category, :string
    field :count, :integer, default: 1
    field :period, :string, default: "daily"
    field :time, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(%SimpleStat{} = simple_stats, attrs) do
    simple_stats
    |> cast(attrs, [:category, :period, :time, :count])
    |> validate_required([:category, :period, :time, :count])
  end
end
