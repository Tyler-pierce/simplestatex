defmodule SimpleStatEx.SimpleStatHolder do
	@moduledoc """
	SimpleStatHolder represents a set of stats held in memory
	"""
	defstruct simple_stat: nil, category_bucket_pid: nil
end