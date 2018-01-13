defmodule SimpleStatEx.StatSupervisor do
  use Supervisor

  def start_link do
  	Supervisor.start_link(__MODULE__, nil, name: :stat_supervisor)
  end

  @doc """
  Start an activity child which can be any kind of activity server
  """
  def start_child(name) do
    Supervisor.start_child(:stat_supervisor, [name])
  end

  def init(_) do
    supervise([worker(SimpleStatEx.Server.SimpleStatSet, [])], strategy: :simple_one_for_one)
  end
end