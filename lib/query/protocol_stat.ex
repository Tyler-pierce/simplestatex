defprotocol SimpleStatEx.Query.Stat do
  @moduledoc """
  Interface to query stats from the configured Repo
  """

  @doc """
  Insert a new stat or new stats to the data store
  """  
  def insert(stat)

  @doc """
  Retrieve a stat or set of stats from the datastore
  """
  def get(stat)
end


defimpl SimpleStatEx.Query.Stat, for: SimpleStatEx.SimpleStat do
  
  alias SimpleStatEx.{Repo, SimpleStat}
    
  def insert(%SimpleStat{} = stats) do
    {:ok, stats}
  end

  def get(%SimpleStat{} = stats) do
    {:ok, stats}
  end  
end