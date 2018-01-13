defmodule SimpleStatEx do
  @moduledoc """
  SimpleStatEx is a lightweight library that supports logging simple statistics for any elixir project, including
  the Phoenix Framework.  Stats are stored via ecto to your data store or in memory.  They are rolled up by category 
  and time window and can be queried conveniently.  SimpleStatEx provides the recommended interface to your stats.
  """

  alias SimpleStatEx.{SimpleStat, SimpleStatHolder, SimpleStatQuery}
  alias SimpleStatEx.Util.{HandleTime, DataAccess}
  alias SimpleStatEx.Query.Stat

  @doc """
  Generate a stat model based on passed arguments

  ## Examples

      iex> SimpleStatEx.stat("index visit", :daily)
      %SimpleStat{category: "index visit", period: "daily", count: 1, ...}

  """
  def stat(category) when is_binary(category) do
    case HandleTime.round(:daily, Timex.now()) do
      {:ok, time} ->
        {:ok, %SimpleStat{category: category, period: HandleTime.period_to_string!(:daily), time: time}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def stat(category, period, count \\ 1) when is_binary(category) do
    case HandleTime.round(period, Timex.now()) do
      {:ok, time} ->
        {:ok, %SimpleStat{category: category, period: HandleTime.period_to_string!(period), count: count, time: time}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Attempt to transform any simple stat operation into using memory instead of repository. Meant for use in piping from
  other parts of this interface such as `stat` and `query`.

  ## Example

    iex> SimpleStatEx.stat("mongol visit") |> SimpleStatEx.memory() |> SimpleStatEx.save()

    iex> SimpleStatEx.query("mongol visit") |> SimpleStatEx.memory() |> SimpleStatEx.get()
  """
  def memory({:ok, %SimpleStat{} = simple_stat}) do
    pid = DataAccess.lookup_bucket(simple_stat)

    {:ok, %SimpleStatHolder{simple_stat: simple_stat, category_bucket_pid: pid}}
  end

  def memory({:ok, %SimpleStat{} = simple_stat, %SimpleStatQuery{} = simple_stat_query}) do
    pid = DataAccess.lookup_bucket(simple_stat)

    {:ok, %SimpleStatHolder{simple_stat: simple_stat, category_bucket_pid: pid}, simple_stat_query}
  end

  @doc """
  Save a stat or stat container to the datastore or to state. If within the time and period of a stat of the same
  category, updates the counter, incrementing by your new stat's count.

  ## Example

    iex> SimpleStatEx.stat("index visit") |> SimpleStatEx.save()
    {:ok,
      %SimpleStatEx.SimpleStat{__meta__: #Ecto.Schema.Metadata<:loaded, "simplestats">,
        category: "index visit", count: 1, id: 1,
        inserted_at: ~N[2018-01-10 05:50:35.225979], period: "daily",
        time: #DateTime<2018-01-10 00:00:00Z>,
        updated_at: ~N[2018-01-10 05:50:35.225986]}}
  """
  def save({:ok, simple_stat}) do
    Stat.insert(simple_stat)
  end

  def save(error_reason) do
    error_reason
  end

  @doc """
  Build a stat query that can be used to obtain results from the database or stat set. You are free to query
  using Ecto in any way you like, Simple Stats helpers simple give you an easy interface to query in the
  suggested way, and are compatible with the Stat Sets held in memory.

  ## Example

    iex> SimpleStatEx.query("index visit", :daily) |> SimpleStatEx.limit(10) |> SimpleStatEx.get()
  """
  def query(category, period) when is_binary(category) do
    case HandleTime.period_to_string(period) do
      {:ok, period_string} ->
        {:ok, %SimpleStat{category: category, period: period_string}, %SimpleStatQuery{}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def query(%SimpleStat{category: category, period: period}) do
    query(category, period)
  end

  def query(category) when is_binary(category) do
    query(category, :daily)
  end

  @doc """
  Add a limit to a stat query, overriding the default `1`

  ## Example

    iex> SimpleStatEx.query("index visit") |> SimpleStatEx.limit(50) |> SimpleStatEx.get()

  """
  def limit({:ok, simple_stat, %SimpleStatQuery{} = simple_stat_query}, limit) do
    {:ok, simple_stat, %{simple_stat_query | limit: limit}}
  end

  def limit(error_reason, _) do
    error_reason
  end

  @doc """
  Add an offset to a stat query, overriding the default `0`

  ## Example

    # Get 1 day stats from 50 days ago
    iex> SimpleStatEx.query("index visit") |> SimpleStatEx.offset(50) |> Simple StatEx.get()
  """
  def offset({:ok, simple_stat, %SimpleStatQuery{} = simple_stat_query}, offset) do
    {:ok, simple_stat, %{simple_stat_query | offset: offset}}
  end

  def offset(error_reason, _) do
    error_reason
  end

  @doc """
  Retrieve a stat using simple stat query builder helpers.  This is usually called via pipe from
  SimpleStatEx.query.

  ## Example

    iex> SimpleStatEx.get(%SimpleStat{category: "mongol visit", period: :daily}, %SimpleStatQuery{limit: 7, offset: 7})
    {:ok,
      [%{category: "mongol visit", period: "daily", time: ~N[2018-01-10 00:00:00.000000],
       updated_at: ~N[2018-01-10 05:26:03.562011]}]}

    iex> SimpleStatEx.query("mongol visit") |> SimpleStatEx.limit(7) |> SimpleStatEx.offset(7) |> SimpleStatEx.get()
    {:ok,
    [%{category: "test", period: "daily", time: ~N[2018-01-10 00:00:00.000000],
     updated_at: ~N[2018-01-10 05:26:03.562011]}]}
  """
  def get({simple_stat, %SimpleStatQuery{} = simple_stat_query}) do
    get({:ok, simple_stat, simple_stat_query})
  end

  def get({:ok, simple_stat, %SimpleStatQuery{} = simple_stat_query}) do
    Stat.retrieve(simple_stat, simple_stat_query)
  end

  def get({:error, reason}) do
    {:error, reason}
  end

  def get!(stat_query_tuple) do
    {:ok, result} = get(stat_query_tuple)

    result
  end

  @doc """
  See get/1 above but only return one result with no list structure

  ## Example

    iex> SimpleStatEx.get(%SimpleStatQuery{category: "mongol visit", period: :daily}, :single)
    {:ok,
      %{category: "test", period: "daily", time: ~N[2018-01-10 00:00:00.000000],
       updated_at: ~N[2018-01-10 05:26:03.562011]}}
  """
  def get(stat_query_tuple, :single) do
    {:ok, [result|_]} = get(stat_query_tuple)

    {:ok, result}
  end

  def get!(stat_query_tuple, :single) do
    [result|_] = get!(stat_query_tuple)

    result
  end
end
