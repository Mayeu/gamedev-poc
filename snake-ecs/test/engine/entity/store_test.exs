defmodule Engine.Entity.StoreTest do
  use ExUnit.Case, async: true

  alias Engine.Entity
  alias Entity.Store

  test "it should be possible to add entity to a group" do
    group = :group1
    world = :world
    {:ok, entity} = Entity.create(:Goblin)

    :ok = Store.add_to_group(group, world, entity)

    assert [entity] == :pg.get_members(Module.concat(world, group))

    Entity.destroy(entity)
  end

  test "it should be possible to remove an entity from a group" do
    group = :group2
    world = :world
    {:ok, entity} = Entity.create(:Goblin)

    :ok = Store.add_to_group(group, world, entity)
    :ok = Store.remove_from_group(group, world, entity)

    assert [] == :pg.get_members(Module.concat(world, group))
  end

  test "it should be possible to get an entity matching a group" do
    group = :group3
    group2 = :group4
    world = :default
    {:ok, entity} = Entity.create(:Goblin)

    :ok = Store.add_to_group(group, world, entity)
    :ok = Store.add_to_group(group2, world, entity)

    assert [entity] == Store.get_with(group, world)
    assert [entity] == Store.get_with([group], world)

    # Matching a non existing group should return empty
    assert [] == Store.get_with(:group5, world)

    # Matching a list of group, both exist for this entity
    assert [entity] == Store.get_with([group, group2], world)

    # Matching a list of group, of which only one match the entity in the store
    assert [] == Store.get_with([group2, :group5], world)
  end
end
