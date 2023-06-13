defmodule Engine.Util.ModuleTest do
  use ExUnit.Case, async: true

  alias Engine.Util.Module

  test "get_entity_types should return the entities defined in the code" do
    assert [Engine.EntityTypes.Goblin] == Module.get_entity_types()
  end

  test "get_component_types should return the components defined in the code" do
    assert [Engine.ComponentTypes.Stats] == Module.get_component_types()
  end

  test "get_system_types should return the systems definde in the code" do
    assert [] == Module.get_system_types()
  end
end
