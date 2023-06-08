{pkgs}:


pkgs.mkShell {
  shellHook = ''
     # For some reason, Exsync doesn't find mac_listener which exist.
     # So I'm exporting it to our path
     export PATH=./dep/file_system/priv/:$PATH
  '';

  buildInputs = with pkgs; [
    # Basic buildtools
    gnumake
    coreutils
    findutils
    bash
    graphviz

    # Elixir
    elixir_1_14

    # For Scenic
    glfw  # GLFW3
    glew # An OpenGL extension loading library for C/C++
    pkg-config
    gcc

    # For Membrane
    portaudio
    libmad
    ffmpeg_6-headless
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Cocoa
  ];
}
