{
  description = "x86_64-linux -> windows x86_64 cross compile template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        localSystem = system;
      };

      winPkgs = pkgs.pkgsCross.mingwW64;

      windresWrapper = pkgs.writeShellScriptBin "windres" ''
        exec ${winPkgs.stdenv.cc.targetPrefix}windres "$@"
      '';
    in
    {
      packages.${system}.hello-win = winPkgs.hello;

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          winPkgs.pkg-config
          winPkgs.stdenv.cc
          windresWrapper
        ];

        buildInputs = [
          winPkgs.zlib
        ];

        shellHook = ''
          echo "target: ${winPkgs.stdenv.hostPlatform.config}"
          echo "cc: $CC"
          echo "windres: $(which windres)"
        '';
      };
    };
}
