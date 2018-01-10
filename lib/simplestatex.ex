defmodule SimpleStatEx do
  @moduledoc """
  SimpleStatEx is a lightweight library that supports logging statistics from any elixir project, including
  the Phoenix Framework.  Stats are stored via ecto to your data store rolled up by category and time window and
  can be queried conveniently.
  """

  alias SimpleStatEx.SimpleStat
  alias SimpleStatEx.Util.HandleTime

  require Ecto.Query

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
  def save(%SimpleStat{} = simple_stat}) do
    save({:ok, simple_stat})
  end

  def save({:ok, %SimpleStat{category: category, time: time, count: count} = simple_stat}) do
    simple_stat
      |> repo().insert(
        conflict_target: [:category, :time],
        on_conflict: SimpleStat |> Ecto.Query.where(category: ^category, time: ^time) |> Ecto.Query.update([inc: [count: ^count]])
      )
  end

  def save({:error, reason}) do
    {:error, reason}
  end

  def hold() do
    :ok
  end

  def get() do
    :ok
  end

  @doc """
  Retrieve the configured Repo, or the internal Repo if the application chose to give SimpleStat 
  it's own repository to work from.
  """
  def repo() do
    case Application.get_env(:simplestatex, :repo) do
      nil ->
        SimpleStatEx.Repo
      repo ->
        repo
    end
  end
end
