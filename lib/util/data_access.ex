defmodule SimpleStatEx.Util.DataAccess do
  alias SimpleStatEx.{Repo, SimpleStat, StatSupervisor}

  @doc """
  Retrieve the configured Repo, or the internal Repo if the application chose to grant SimpleStat 
  it's own repository to work from.
  """
  def repo() do
    case Application.get_env(:simplestatex, :repo) do
      nil ->
        Repo
      repo ->
        repo
    end
  end

  @doc """
  Lookup the bucket process id for an in memory operation.  Creates the bucket if it does not exist
  """
  def lookup_bucket(%SimpleStat{} = simple_stat) do
    case Process.whereis(get_stat_process_name(simple_stat)) do
      nil ->
        create_stat_bucket(simple_stat)
      pid ->
        pid
    end
  end

  defp get_stat_process_name(%SimpleStat{category: category}) do
    String.to_atom("stat_proc_" <> category)
  end

  defp create_stat_bucket(%SimpleStat{} = simple_stat) do
    case StatSupervisor.start_child(get_stat_process_name(simple_stat)) do
      {:ok, pid} ->
        pid
      _ ->
        Process.whereis(get_stat_process_name(simple_stat))
    end
  end
end