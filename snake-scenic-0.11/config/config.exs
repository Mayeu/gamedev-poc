# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# connect the app's asset module to Scenic
config :scenic, :assets, module: Snake.Assets

# Configure the main viewport for the Scenic application
config :snake, :viewport,
  name: :main_viewport,
  size: {800, 600},
  theme: :dark,
  default_scene: Scenes.Game,
  drivers: [
    [
      module: Scenic.Driver.Local,
      name: :local,
      window: [resizeable: false, title: "snake"],
      on_close: :stop_system
    ]
  ]

# Setup live reload
case Mix.env() do
  :dev ->
    config :exsync,
      reload_timeout: 75,
      reload_callback: {ScenicLiveReload, :reload_current_scenes, []}

    config :logger, :console, level: :debug

  _ ->
    nil
end

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
