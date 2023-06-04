defmodule Snake do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:snake, :viewport)

    # start the application with the viewport
    children = [
      ScenesState,
      {Scenic, [main_viewport_config]},
      Snake.PubSub.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
