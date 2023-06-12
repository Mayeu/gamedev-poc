defmodule Engine.Entity.Store do
  # The fact that all this use Module.concat feels wrong

  @spec add_to_group(atom(), atom() | binary(), pid()) :: :ok
  def add_to_group(group, world_name, entity) when is_atom(group) and is_pid(entity) do
    full_name = Module.concat(world_name, group)
    :pg.join(full_name, entity)
  end

  @spec remove_from_group(atom(), atom() | binary(), pid()) :: :ok
  def remove_from_group(group, world_name, entity)
      when is_atom(group) and is_pid(entity) do
    full_name = Module.concat(world_name, group)
    :pg.leave(full_name, entity)
  end

  @spec get_with(list(atom()) | atom(), atom()) :: list(pid())
  def get_with(single_want_list, world_name) when is_atom(single_want_list) do
    full_name = Module.concat(world_name, single_want_list)

    :pg.get_members(full_name)
  end

  # TODO: Replace :sets with MapSet, maybe add more "complex" tests before this refactoring
  def get_with(want_list, world_name) when is_list(want_list) do
    Enum.map(want_list, fn want ->
      full_name = Module.concat(world_name, want)

      :pg.get_members(full_name)
      |> :sets.from_list()
    end)
    # With one args, it expect a list of set
    # https://www.erlang.org/doc/man/sets.html#intersection-1
    |> :sets.intersection()
    |> :sets.to_list()
  end
end
