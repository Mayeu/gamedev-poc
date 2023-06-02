{pkgs}:


pkgs.mkShell {
  buildInputs = with pkgs; [
    # Basic buildtools
    gnumake
    coreutils
    findutils
    bash

    # Elixir
    elixir_1_14

    # For Scenic
    glfw  # GLFW3
    glew # An OpenGL extension loading library for C/C++
    pkg-config
    gcc
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Cocoa
  ];
}
