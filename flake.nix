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
    in
    {
      packages.${system}.hello-win = winPkgs.hello;

      devShells.${system}.default = winPkgs.callPackage (
        {
          mkShell,
          pkg-config,
          cmake,
          file,
          zlib,
        }:
        mkShell {
          nativeBuildInputs = [
            pkg-config
            cmake
            file
          ];

          buildInputs = [
            zlib
          ];

          shellHook = ''
            echo "target: ${winPkgs.stdenv.hostPlatform.config}"
            echo "cc: $CC"
          '';
        }
      ) { };
    };
}
