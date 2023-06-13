defmodule Engine.EntityTest do
  use ExUnit.Case, async: true

  alias Engine.Entity
  alias Engine.Action
  alias Engine.ComponentTypes

  test "it should be possible to create and destroy an entity without error" do
    assert {:ok, ent} = Entity.create(:Goblin)

    assert :ok = Entity.destroy(ent)
  end

  test "it should be possible to pop an action from the entity" do
    {:ok, ent} = Entity.create(:Goblin)

    # Without action, we should get :empty
    assert :empty = Entity.pop_action(ent)

    # Add an action
    action = Action.create(:attack, ent, %{hp: -10_000})
    assert action = Entity.pop_action(ent)

    # Now it should be empty again
    assert :empty = Entity.pop_action(ent)

    Entity.destroy(ent)
  end

  test "it should be possible to get the componant of an entity" do
    {:ok, ent} = Entity.create(:Goblin)

    assert %ComponentTypes.Stats{hp: _} = Entity.get_component(ent, ComponentTypes.Stats)

    Entity.destroy(ent)
  end

  test "it should be possible to set the data of a component throught the entity" do
    {:ok, ent} = Entity.create(:Goblin)

    assert :ok = Entity.set_component_data(ent, ComponentTypes.Stats, :hp, 100)
    assert %ComponentTypes.Stats{hp: 100} = Entity.get_component(ent, ComponentTypes.Stats)

    Entity.destroy(ent)
  end
end
