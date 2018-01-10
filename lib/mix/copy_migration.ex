defmodule Mix.Tasks.SimpleStatEx.CopyMigration do
	@moduledoc """
	Copies the migration file used to create the simplestats table to the dependent application
	"""
	use Mix.Task

  @default_app_path "priv/repo/migrations/00000_create_simplestats.exs"
  @default_simple_path "deps/simplestatex/priv/repo/migrations/00000_create_simplestats.exs"

	@shortdoc "Copy SimpleStat migration file to application"

  def run([]) do
    run([@default_app_path])
  end

	def run([app_path]) do
    case File.copy(@default_simple_path, app_path) do
      {:ok, _} ->
        Mix.shell.info "Migration file copied to " <> app_path
      {:error, _} ->
        Mix.shell.info "Failed to copy migration file"
    end
  end

  def run(_) do
    Mix.shell.info "Migration copy takes 1 or fewer arguments only"
  end
end