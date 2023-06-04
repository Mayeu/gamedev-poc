defmodule Scenes.GameOver do
  require Logger
  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives, only: [text: 3, update_opts: 2]

  @text_opts [id: :gameover, fill: :white, text_align: :center]

  @graph Graph.build(font: :roboto, font_size: 36, clear_color: :black)
         |> text("Game Over!", @text_opts)

  @game_scene Scenes.Game

  @impl Scenic.Scene
  def init(scene, score, opts) do
    {:ok, viewport} = ViewPort.info(:main_viewport)
    {vp_width, vp_height} = viewport.size

    position = {vp_width / 2, vp_height / 2}

    graph =
      @graph
      |> Graph.modify(:gameover, &update_opts(&1, translate: position))

    state = %{
      graph: graph,
      viewport: viewport,
      on_cooldown: true,
      score: score
    }

    Process.send_after(self(), :end_cooldown, 2000)

    scene =
      scene
      |> assign(state: state)
      |> push_graph(graph)

    :ok = request_input(scene, :key)

    {:ok, scene}
  end

  # Prevent player from hitting any key instantly, starting a new game
  def handle_info(:end_cooldown, scene = %Scenic.Scene{assigns: %{state: state}}) do
    graph =
      state.graph
      |> Graph.modify(
        :gameover,
        &text(
          &1,
          "Game Over!\n" <>
            "You scored #{state.score}.\n" <>
            "Press any key to try again.",
          @text_opts
        )
      )

    scene =
      scene
      |> assign(state: %{state | on_cooldown: false, graph: graph})
      |> push_graph(graph)

    {:noreply, scene}
  end

  # If cooldown has passed, we can restart the game.
  @impl Scenic.Scene
  def handle_input({:key, _}, _context, %Scenic.Scene{
        assigns: %{state: %{on_cooldown: false} = state}
      }) do
    restart_game(state)
    {:noreply, state}
  end

  def handle_input(event, _context, scene) do
    Logger.debug("Unknown input")
    Logger.debug(event: event)
    Logger.debug(state: scene.assigns.state)
    {:noreply, scene}
  end

  defp restart_game(%{viewport: vp}) do
    ViewPort.set_root(vp, @game_scene, fresh_start: true)
  end
end
