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

      pkgConfigWrapper = pkgs.writeShellScriptBin "pkg-config" ''
        exec ${winPkgs.pkg-config}/bin/pkg-config "$@"
      '';
    in
    {
      packages.${system}.hello-win = winPkgs.hello;

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          winPkgs.stdenv.cc
          winPkgs.pkg-config
          windresWrapper
          pkgConfigWrapper
        ];

        buildInputs = [
          winPkgs.boost
          # まず glib は外す
        ];

        shellHook = ''
          export PKG_CONFIG=${pkgConfigWrapper}/bin/pkg-config

          echo "target: ${winPkgs.stdenv.hostPlatform.config}"
          echo "cc: $CC"
          echo "windres: $(which windres)"
          echo "pkg-config: $(which pkg-config)"
        '';
      };
    };
}
