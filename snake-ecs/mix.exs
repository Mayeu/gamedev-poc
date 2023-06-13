defmodule Snake.MixProject do
  use Mix.Project

  def project do
    [
      app: :snake,
      version: "0.1.0",
      elixir: "~> 1.14",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: Coverex.Task]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Game, []},
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.11.0"},
      {:scenic_driver_local, "~> 0.11.0"},
      {:typed_struct, "~> 0.3.0"},
      {:qex, "~> 0.5"},
      {:membrane_core, "~> 0.10"},
      {:membrane_file_plugin, "~> 0.12"},
      {:membrane_portaudio_plugin, "~> 0.13"},
      {:membrane_ffmpeg_swresample_plugin, "~> 0.15"},
      {:membrane_mp3_mad_plugin, "~> 0.13.0"},
      {:coverex, "~> 1.4.15", only: :test},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:gradient, github: "esl/gradient", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.3", only: :test}
    ]
  end
end
