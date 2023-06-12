defmodule Game do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:snake, :viewport)

    # start the application with the viewport
    children = [
      # Process Group
      # To manage groups of entities in the store
      # Or, one can export ERL_FLAGS="-kernel start_pg true"
      %{
        id: :pg,
        start: {:pg, :start_link, []}
      },
      {Scenic, [main_viewport_config]},
      PubSub.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
