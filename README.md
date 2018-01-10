# SimpleStatEx

SimpleStatEx allows your elixir project to roll up stat counters in a simple and fast manner.  The statistics can be rolled up into time windows of your choice (see usage for more detail).  This library is tested for Phoenix Framework 1.3.

Your statistics can be stored in your applications data store using the migration and model available, or held in a process via GenServer.  SimpleStatEx also supports mass insertion, holding the state of your stats until you yourself save it manually, or using a cron service such as Quantum (see Quantum instruction below).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `simplestatex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simplestatex, "~> 0.1.0"}
  ]
end
```

If wanting persisted stats, either copy your existing repo config in your application as simple stat ex's, or use a different repo,
in `dev.exs`:

```elixir
config :simplestatex, SimpleStatEx.Repo,
  adapter: Ecto.Adapters.Postgres, # or your adapter of choice
  username: "dbuser",
  password: "dbpassword",
  database: "dbname",
  hostname: "localhost", # or another host
  pool_size: 10
```

Add Simple Stats Repo to your application in `lib/myapp/application.ex`:

```elixir
  ...
  children = [
    ...
    supervisor(SimpleStatEx.Repo, []),
    ...
  ]
```

And run the migration to get the stat table:

```elixir
# Make sure if you use this method, your production deploy flow migrates as well
mix ecto.migrate -r SimpleStatEx.Repo
```

alternatively and easier, you can copy the migration file to your own application:

```elixir
mix simple_stat_ex.copy_migration
```

and configure your repo for simple stat to use in `config.exs`:

```elixir
config :simplestatex,
  repo: MyApp.Repo
```

## Usage

### Persistant Storage

The normal use case will be to hold your stats in a database such as postgres.  Here are some examples of persisted statistics:

```elixir

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/simplestatex](https://hexdocs.pm/simplestatex).

