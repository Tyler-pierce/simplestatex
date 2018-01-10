defmodule SimpleStatExTest do
  use ExUnit.Case
  doctest SimpleStatEx

  test "greets the world" do
    assert SimpleStatEx.hello() == :world
  end
end
