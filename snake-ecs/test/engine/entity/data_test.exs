defmodule Engine.Entity.DataTest do
  use ExUnit.Case, async: true

  alias Engine.Entity.Data

  test "validate Entity default data" do
    data = %Data{}

    assert data.world_name == :global
    assert data.components == %{}
    assert data.action_queue == nil
  end
end
