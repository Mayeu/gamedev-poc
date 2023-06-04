defmodule ScenesState do
  use Agent

  @game_scene %{
    scene_initialised: false,
    viewport: nil,
    tile_width: nil,
    tile_height: nil,
    frame_count: 1,
    frame_timer: nil,
    graph: nil,
    score: 0,
    objects: %{
      snake: %{
        body: [],
        size: 5,
        direction: {1, 0}
      },
      pellet: nil
    }
  }

  @initial_state %{
    Scenes.Game => @game_scene
  }

  def start_link(_) do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  # Get the state for the module
  def get(module) do
    Agent.get(__MODULE__, &Map.fetch!(&1, module))
  end

  def update(module, state) do
    Agent.update(__MODULE__, &Map.put(&1, module, state))
  end

  def reset(module) do
    Agent.update(__MODULE__, &Map.put(&1, module, @initial_state[module]))
  end
end
