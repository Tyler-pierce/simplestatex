# SimpleStatEx

SimpleStatEx allows your elixir project to keep simple statistic counters.  The statistics can be rolled up into time windows of your choice (see usage for more detail).  This library is tested for Phoenix Framework 1.3.

Easy install and simplicity are the top priorities of this library.  Simple Stat is compatible with Ecto, long term storage, and/or in memory storage of your statistics.

[Full documentation here.](https://hexdocs.pm/simplestatex/SimpleStatEx.html) or [jump straight to usage examples](https://github.com/Tyler-pierce/simplestatex#usage).

## Installation

Add `simplestatex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simplestatex, "~> 0.1.3"}
  ]
end
```

Copy the migration file into your application:

```elixir
mix simple_stat_ex.copy_migration
```

and configure your repo for simple stat to use in `config.exs`:

```elixir
config :simplestatex,
  repo: MyApp.Repo
```

## Installation Option #2

You can also set simple stat up with it's own Repo to work alongside your own.

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

Add a Repo module for simple stat to your project somewhere (lib/myapp/ssx_repo.ex):

```elixir
defmodule SimpleStatEx.Repo do
  use Ecto.Repo, otp_app: :simplestatex
end
```

And run the migration to get the stat table:

```elixir
# Make sure if you use this method, your production deploy flow migrates as well
mix ecto.migrate -r SimpleStatEx.Repo
```

### Optional Setup

To add and query stats from memory you will need Simple Stats supervisor added to your application.ex:

```elixir
  ...
  children = [
    ...
    supervisor(SimpleStatEx.StatSupervisor, []),
    ...
  ]
```
**Hint** You needent set up any kind of repo and can choose to only keep stats in memory


## Usage

### Recording Stats

Here are some examples of recording statistics:

```elixir
alias SimpleStatEx, as: SSX

SSX.stat("index visit", :hourly) |> SSX.save()

{:ok, %SimpleStatEx.SimpleStat{ ... }}

SSX.stat("about page visit", :daily) |> SSX.save()

{:ok, %SimpleStatEx.SimpleStat{ ... }}
```

The currently allowed atoms for time periods are :minute, :second, :hourly, :daily, :weekly, :monthly, :yearly.

You can also save to memory easily by making use of the piping convenience function (make sure to do optional setup):

```elixir
SS.stat("mongol visit", :minute) |> SS.memory() |> SS.save()

{:ok,
 %SimpleStatEx.SimpleStat{ ... }}
```

That will save to state in a genserver.  The only strategy currently available for concurrency is 1 process per topic though
of course you can implement or contribute additional genserver implementations.

### Querying Stats

Ecto can be used to make custom queries per usual but Simple Stat includes conveniences and recommended ways to query:

```elixir
SSX.query("index visit", :daily) |> SSX.get()

{:ok,
 [%{category: "index visit", count: 2, period: "daily",
    time: ~N[2018-01-13 00:00:00.000000], updated_at: ~N[2018-01-13 03:34:50.310691]}]}

SSX.query("index visit", :minute) |> SSX.limit(2) |> SSX.get()

{:ok,
 [%{category: "index visit", count: 5, period: "minute",
    time: ~N[2018-01-13 10:27:00.000000], updated_at: ~N[2018-01-13 03:34:50.310691]},
  %{category: "index visit", count: 15, period: "minute",
    time: ~N[2018-01-13 10:27:01.000000], updated_at: ~N[2018-01-13 03:34:50.310691]}]}

SSX.query("index visit temp", :daily) |> SSX.limit(10) |> SSX.offset(1) |> SSX.memory() |> SSX.get()

{:ok, [ ... ]}
```

## Definitions

* **period** a slice of time such as an hour or minute or year
* **category** a string by which stats are grouped and separated
* **stat** a single stat by category and period (category: "index" period: "hourly", count: 6901)

## Coming up next

* Mass insert (for dumping stats from memory to disk periodically)
* Additional genserver strategies (in case of high volumn needs for a single category)
* Quantum support for periodic stat roundups