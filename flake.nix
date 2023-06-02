{
  description = "Simple snake with Scenic 0.11";

  # Input schema
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Outputs schema
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # devShell is part of flake's output schema
        devShell = import ./shell.nix {inherit pkgs; };
    });
}
