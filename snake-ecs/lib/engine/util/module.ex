defmodule Engine.Util.Module do
  def get_entity_types do
    {:ok, modules} = :application.get_key(:elixir_rpg, :modules)

    modules
    |> Enum.filter(fn module ->
      parts = Module.split(module)
      # TODO: convert the moduleule name to string instead of using string (for compiling error)
      match?(["EntityTypes" | _], parts)
    end)
  end

  def get_component_types do
    {:ok, modules} = :application.get_key(:elixir_rpg, :modules)

    modules
    |> Enum.filter(fn module ->
      parts = Module.split(module)
      # TODO: convert the moduleule name to string instead of using string (for compiling error)
      match?(["ComponentTypes" | _], parts)
    end)
  end

  def get_system_types do
    {:ok, modules} = :application.get_key(:elixir_rpg, :modules)

    modules
    |> Enum.filter(fn module ->
      parts = Module.split(module)
      # TODO: convert the moduleule name to string instead of using string (for compiling error)
      match?(["RuntimeSystems" | _], parts)
    end)
  end
end
