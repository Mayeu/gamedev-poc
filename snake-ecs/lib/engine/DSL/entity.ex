defmodule Engine.DSL.Entity do
  defmacro __using__(_options) do
    quote do
      import Engine.DSL.Entity
    end
  end

  defmacro defentity(name, do: block) do
    quote do
      # Maybe it should Game.Entity instead of Engine.EntityTypes
      defmodule Engine.EntityTypes.unquote(name) do
        alias Engine.Entity

        Module.register_attribute(__MODULE__, :components, accumulate: true, persist: true)
        Module.register_attribute(__MODULE__, :entity_name, persist: true)

        unquote(block)

        defp __full_type(type) do
          Module.concat(Engine.ComponentTypes, type)
        end

        def create do
          components =
            Enum.reduce(@components, %{}, fn {type, default_data}, acc ->
              full_type = __full_type(type)
              Map.put_new(acc, full_type, struct(full_type, default_data))
            end)

          %Entity.Data{
            components: components
          }
        end
      end
    end
  end

  defmacro component(component_type) do
    quote do
      @components {unquote(component_type), %{}}
    end
  end

  defmacro component(component_type, default_data) do
    {:__aliases__, _, [type]} = component_type
    full_type = Module.concat(Engine.ComponentTypes, type)

    # Some person on the Internet[1] say this function is unsafe and can
    # deadlock, and that the recommended function is actually ensure_loaded?
    #
    # [1]: https://github.com/elixirmoney/money/pull/131
    if !Code.ensure_compiled(full_type) do
      raise(CompileError,
        description: "Component #{type} does not exist!",
        file: __CALLER__.file,
        line: __CALLER__.line
      )
    end

    quote do
      @components {unquote(component_type), unquote(default_data)}
    end
  end
end
