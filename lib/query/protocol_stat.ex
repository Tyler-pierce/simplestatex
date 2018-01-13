defprotocol SimpleStatEx.Query.Stat do
  @moduledoc """
  Interface to query stats from the configured Repo
  """

  @doc """
  Insert a new stat or new stats to the means of storage
  """  
  def insert(stat)

  @doc """
  Retrieve a stat or set of stats from the means of storage
  """
  def retrieve(stat, stat_query)

  @doc """
  Retrieve all stats in a categorized set
  """
  def all(stat)
end


defimpl SimpleStatEx.Query.Stat, for: SimpleStatEx.SimpleStat do
  
  require Ecto.Query

  alias Ecto.Query
  alias SimpleStatEx.{SimpleStat, SimpleStatQuery}
  alias SimpleStatEx.Util.DataAccess

    
  def insert(%SimpleStat{category: category, time: time, count: count} = simple_stat) do
    simple_stat |> DataAccess.repo().insert(
      conflict_target: [:category, :time],
      on_conflict: SimpleStat |> Query.where(category: ^category, time: ^time) |> Query.update([inc: [count: ^count]])
    )
  end

  def retrieve(%SimpleStat{category: category, period: period}, %SimpleStatQuery{offset: offset, limit: limit}) do
    case SimpleStat
      |> Query.select([s], %{category: s.category, period: s.period, count: s.count, time: s.time, updated_at: s.updated_at})
      |> Query.where(category: ^category, period: ^period)
      |> Query.limit(^limit)
      |> Query.offset(^offset)
      |> DataAccess.repo().all() do
      {:error, reason} ->
        {:error, reason}
      result ->
        {:ok, result}    
    end
  end

  def all(%SimpleStat{category: category}) do
    case SimpleStat
      |> Query.select([s], %{category: s.category, period: s.period, count: s.count, time: s.time, updated_at: s.updated_at})
      |> Query.where(category: ^category)
      |> DataAccess.repo().all() do
      {:error, reason} ->
        {:error, reason}
      result ->
        {:ok, result}    
    end
  end
end

defimpl SimpleStatEx.Query.Stat, for: SimpleStatEx.SimpleStatHolder do
  
  alias SimpleStatEx.{SimpleStat, SimpleStatHolder, SimpleStatQuery}
  alias SimpleStatEx.Server.SimpleStatSet


  def insert(%SimpleStatHolder{simple_stat: %SimpleStat{} = simple_stat, category_bucket_pid: category_bucket}) do
    _ = SimpleStatSet.add_stat(category_bucket, simple_stat)

    {:ok, simple_stat}
  end

  def retrieve(%SimpleStatHolder{simple_stat: %SimpleStat{} = simple_stat, category_bucket_pid: category_bucket}, %SimpleStatQuery{} = simple_stat_query) do
    SimpleStatSet.query_stats(category_bucket, simple_stat, simple_stat_query)
  end

  def all(%SimpleStatHolder{category_bucket_pid: category_bucket}) do
    SimpleStatSet.get_stats(category_bucket)
  end
end