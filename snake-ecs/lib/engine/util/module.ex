defmodule Engine.Util.Module do
  @spec get_entity_types() :: list(atom())
  def get_entity_types do
    {:ok, modules} = :application.get_key(:snake, :modules)

    modules
    |> Enum.filter(fn module ->
      parts = Module.split(module)

      # TODO: convert the module beginning name to string instead of using string (for compiling error)
      # TODO: Also, consider making this a configuration. It should not be Engine.EntityTypes by default also, maybe just Entity.xxx, because it's not the entities of the engine.
      match?(["Engine", "EntityTypes" | _], parts)
    end)
  end

  @spec get_component_types() :: list(atom())
  def get_component_types do
    {:ok, modules} = :application.get_key(:snake, :modules)

    modules
    |> Enum.filter(fn module ->
      parts = Module.split(module)
      # TODO: convert the moduleule name to string instead of using string (for compiling error)
      match?(["Engine", "ComponentTypes" | _], parts)
    end)
  end

  @spec get_system_types() :: list(atom())
  def get_system_types do
    {:ok, modules} = :application.get_key(:snake, :modules)

    modules
    |> Enum.filter(fn module ->
      parts = Module.split(module)
      # TODO: convert the moduleule name to string instead of using string (for compiling error)
      match?(["Engine", "RuntimeSystems" | _], parts)
    end)
  end
end
