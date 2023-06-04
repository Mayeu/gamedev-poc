defmodule Scenes.Game do
  require Logger

  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives, only: [text: 3, rounded_rectangle: 3]

  # Constants
  @graph Graph.build(font: :roboto, font_size: 36)
  @tile_size 32
  @tile_radius 8
  @frame_ms 192
  @pellet_score 100

  @game_over_scene Scenes.GameOver

  # Initialize the game scene
  @impl Scenic.Scene
  def init(scene, _params, opts) do
    {:ok, viewport} = Scenic.ViewPort.info(:main_viewport)
    Logger.debug(scene: scene)
    Logger.debug(viewport: viewport)

    # calculate the transform that centers the snake in the viewport
    # {:ok, %ViewPort{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    {vp_width, vp_height} = viewport.size

    # how many tiles can the viewport hold in each dimension?
    vp_tile_width = trunc(vp_width / @tile_size)
    vp_tile_height = trunc(vp_height / @tile_size)

    # snake always starts centered
    snake_start_coords = {
      trunc(vp_tile_width / 2),
      trunc(vp_tile_height / 2)
    }

    pellet_start_coords = {
      vp_tile_width - 2,
      trunc(vp_tile_height / 2)
    }

    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    # The entire game state will be held here
    state = ScenesState.get(__MODULE__)

    state =
      if !state.scene_initialised do
        %{
          state
          | viewport: viewport,
            tile_width: vp_tile_width,
            tile_height: vp_tile_height,
            frame_timer: timer,
            scene_initialised: 1,
            graph: @graph,
            objects:
              put_in(state.objects, [:snake, :body], [snake_start_coords])
              |> put_in([:pellet], pellet_start_coords)
        }
      else
        # TODO: should we update the viewport size here?
        state
      end

    # Update the graph and push it to be rendered
    graph =
      state.graph
      |> draw_score(state.score)
      |> draw_game_objects(state.objects)

    scene =
      scene
      |> assign(state: state, graph: graph)
      |> push_graph(graph)

    :ok = request_input(scene, :key)

    ScenesState.update(__MODULE__, state)
    {:ok, scene}
  end

  # Handle new frame message
  def handle_info(
        :frame,
        %Scenic.Scene{assigns: %{state: %{frame_count: frame_count} = state}} = scene
      ) do
    Logger.debug(state)
    new_state = move_snake(state)

    new_graph = @graph |> draw_game_objects(state.objects) |> draw_score(state.score)

    scene =
      scene
      |> assign(state: %{new_state | frame_count: frame_count + 1}, graph: new_graph)
      |> push_graph(new_graph)

    ScenesState.update(__MODULE__, scene.assigns.state)

    {:noreply, scene}
  end

  # Keyboard controls
  @impl Scenic.Scene
  def handle_input({:key, {:key_left, 1, _}}, _context, scene) do
    {:noreply, update_snake_direction(scene, {-1, 0})}
  end

  def handle_input({:key, {:key_right, 1, _}}, _context, scene) do
    {:noreply, update_snake_direction(scene, {1, 0})}
  end

  def handle_input({:key, {:key_up, 1, _}}, _context, scene) do
    Logger.debug("Up!")
    {:noreply, update_snake_direction(scene, {0, -1})}
  end

  def handle_input({:key, {:key_down, 1, _}}, _context, scene) do
    {:noreply, update_snake_direction(scene, {0, 1})}
  end

  def handle_input(input, _context, scene) do
    Logger.debug(unknown_input: input)
    {:noreply, scene}
  end

  # Change the snake's current direction.
  defp update_snake_direction(scene, direction) do
    Logger.debug(scene)
    state = put_in(scene.assigns.state, [:objects, :snake, :direction], direction)

    ScenesState.update(__MODULE__, state)

    scene
    |> assign(state: state)
  end

  # oh no
  defp maybe_die(state = %{viewport: vp, objects: %{snake: %{body: snake}}, score: score}) do
    # If ANY duplicates were removed, this means we overlapped at least once
    if length(Enum.uniq(snake)) < length(snake) do
      ScenesState.reset(__MODULE__)
      ViewPort.set_root(vp, @game_over_scene, score)
    end

    state
  end

  # Draw the score HUD
  defp draw_score(graph, score) do
    graph
    |> text("Score: #{score}", fill: :white, translate: {@tile_size, @tile_size})
  end

  # Iterates over the object map, rendering each object
  defp draw_game_objects(graph, object_map) do
    Enum.reduce(object_map, graph, fn {object_type, object_data}, graph ->
      draw_object(graph, object_type, object_data)
    end)
  end

  # Snake's body is an array of coordinate pairs
  defp draw_object(graph, :snake, %{body: snake}) do
    Enum.reduce(snake, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :lime)
    end)
  end

  # Pellet is simply a coordinate pair
  defp draw_object(graph, :pellet, {pellet_x, pellet_y}) do
    draw_tile(graph, pellet_x, pellet_y, fill: :red, id: :pellet)
  end

  # Draw tiles as rounded rectangles to look nice
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    graph |> rounded_rectangle({@tile_size, @tile_size, @tile_radius}, tile_opts)
  end

  # Move the snake to its next position according to the direction. Also limits the size.
  defp move_snake(%{objects: %{snake: snake}} = state) do
    [head | _] = snake.body
    new_head_pos = move(state, head, snake.direction)

    new_body = Enum.take([new_head_pos | snake.body], snake.size)

    state
    |> put_in([:objects, :snake, :body], new_body)
    |> maybe_eat_pellet(new_head_pos)
    |> maybe_die()
  end

  defp maybe_eat_pellet(state = %{objects: %{pellet: pellet_coords}}, snake_head_coords)
       when pellet_coords == snake_head_coords do
    state =
      state
      |> randomize_pellet()
      |> add_score(@pellet_score)
      |> grow_snake()

    ScenesState.update(__MODULE__, state)

    state
  end

  # No pellet in sight. :(
  defp maybe_eat_pellet(state, _), do: state

  # Place the pellet somewhere in the map. It should not be on top of the snake.
  defp randomize_pellet(state = %{tile_width: w, tile_height: h}) do
    pellet_coords = {
      Enum.random(0..(w - 1)),
      Enum.random(0..(h - 1))
    }

    validate_pellet_coords(state, pellet_coords)
  end

  # Keep trying until we get a valid position
  defp validate_pellet_coords(state = %{objects: %{snake: %{body: snake}}}, coords) do
    if coords in snake,
      do: randomize_pellet(state),
      else: put_in(state, [:objects, :pellet], coords)
  end

  # Increments the player's score.
  defp add_score(state, amount) do
    update_in(state, [:score], &(&1 + amount))
  end

  # Increments the snake size.
  defp grow_snake(state) do
    update_in(state, [:objects, :snake, :size], &(&1 + 1))
  end

  defp move(%{tile_width: w, tile_height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
    {rem(pos_x + vec_x + w, w), rem(pos_y + vec_y + h, h)}
  end
end
