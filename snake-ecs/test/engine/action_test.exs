defmodule Engine.ActionTest do
  use ExUnit.Case, async: true

  alias Engine.Action

  test "#{__MODULE__}.create: should work" do
    assert %Action{} = Action.create(:a_type, System.pid(), %{pay: "load"})
  end

  test "#{__MODULE__}.execute: should work" do
    {:ok, ent} = Engine.Entity.create(:Goblin)
    action = Action.create(:attack, ent, %{hp: -10_000})
    assert :ok = Action.execute(action)
    # TODO: how to check for the goblin action queue?
    # assert %Entity.Data{}
  end
end
