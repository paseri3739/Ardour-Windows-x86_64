{
  description = "x86_64-linux -> windows x86_64 cross compile template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        localSystem = system;
      };

      winPkgs = pkgs.pkgsCross.mingwW64;

      mkMsys2MingwPackage =
        {
          pname,
          version,
          sha256,
          fixPkgConfig ? false,
        }:
        pkgs.stdenvNoCC.mkDerivation {
          inherit pname version;

          src = pkgs.fetchurl {
            url = "https://repo.msys2.org/mingw/mingw64/${pname}-${version}-any.pkg.tar.zst";
            inherit sha256;
          };

          nativeBuildInputs = [
            pkgs.gnutar
            pkgs.zstd
          ];

          dontUnpack = true;
          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            runHook preInstall

            mkdir -p "$out"
            tar --zstd -xf "$src"
            mv mingw64/* "$out"/
            rmdir mingw64
          ''
          + pkgs.lib.optionalString fixPkgConfig ''
            if [ -d "$out/lib/pkgconfig" ]; then
              for pc in "$out"/lib/pkgconfig/*.pc; do
                substituteInPlace "$pc" --replace-fail '/mingw64' "$out"
              done
            fi
          ''
          + ''
            runHook postInstall
          '';
        };

      msys2Glib = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-glib2";
        version = "2.88.0-1";
        sha256 = "1jqjyb8n3r8ign9gjj04xg11xs45xv8kd6cmc0b5d7knymqkmavf";
        fixPkgConfig = true;
      };

      msys2Boost = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-boost";
        version = "1.90.0-3";
        sha256 = "1rv12k145n09hmslrbcffxfwgp0rl6d828rkv6ybgxvqfi45py0w";
      };

      msys2BoostLibs = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-boost-libs";
        version = "1.90.0-3";
        sha256 = "11g2n9i31q8psw2crq5g2hvhnbxhpl51yqijqjm3ggjrdkx5ili8";
      };

      msys2Libsigcxx = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libsigc++";
        version = "2.12.1-1";
        sha256 = "1fy3xxxdp2ghskw4xj7g5h5gs62bf9nkmd2wm7yqlf4bapb6095k";
        fixPkgConfig = true;
      };

      msys2Glibmm = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-glibmm";
        version = "2.66.8-2";
        sha256 = "1vzmdy81wzl3cwlwnbhqa1vqw01pczawhyjva73kia8gxhbivnlp";
        fixPkgConfig = true;
      };

      msys2Libsndfile = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libsndfile";
        version = "1.2.2-1";
        sha256 = "1jkxgr1alyb327i7r2wadc95zv0wamnl5s1b2jbgnx64c6zakxi8";
        fixPkgConfig = true;
      };

      msys2Curl = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-curl";
        version = "8.16.0-1";
        sha256 = "0w88xv3p95yi2bnvi6jl9qplfqv9mimhls3mp54c300j8cy9a0ay";
        fixPkgConfig = true;
      };

      msys2Libarchive = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libarchive";
        version = "3.8.4-1";
        sha256 = "13svpy51qxlb0fi8iq50himm67lf9np42fs98q041rwaz2igd221";
        fixPkgConfig = true;
      };

      msys2Liblo = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-liblo";
        version = "0.34-1";
        sha256 = "04qifzhicn9glrzw6v4nyray5q16lahh1sryka2g9fcdv5w4dp0n";
        fixPkgConfig = true;
      };

      msys2Taglib = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-taglib";
        version = "2.2.1-1";
        sha256 = "09kd49zmnpbn7nfdmxzwrwym0kmknmh3dxspf6dsy9aw3mr56qzc";
        fixPkgConfig = true;
      };

      windresWrapper = pkgs.writeShellScriptBin "windres" ''
        exec ${winPkgs.stdenv.cc.targetPrefix}windres "$@"
      '';

      mingwPkgConfigPath = pkgs.lib.concatStringsSep ":" [
        "${msys2Glib}/lib/pkgconfig"
        "${msys2Libsigcxx}/lib/pkgconfig"
        "${msys2Glibmm}/lib/pkgconfig"
        "${msys2Libsndfile}/lib/pkgconfig"
        "${msys2Curl}/lib/pkgconfig"
        "${msys2Libarchive}/lib/pkgconfig"
        "${msys2Liblo}/lib/pkgconfig"
        "${msys2Taglib}/lib/pkgconfig"
        "${winPkgs.windows.mcfgthreads.dev}/lib/pkgconfig"
      ];

      pkgConfigWrapper = pkgs.writeShellScriptBin "pkg-config" ''
        export PKG_CONFIG_PATH="${mingwPkgConfigPath}''${PKG_CONFIG_PATH:+:''${PKG_CONFIG_PATH}}"
        export PKG_CONFIG_LIBDIR="${mingwPkgConfigPath}"
        exec ${winPkgs.buildPackages.pkg-config}/bin/${winPkgs.stdenv.cc.targetPrefix}pkg-config "$@"
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          winPkgs.stdenv.cc
          winPkgs.buildPackages.pkg-config
          windresWrapper
          pkgConfigWrapper
        ];

        buildInputs = [
          msys2Boost
          msys2BoostLibs
          msys2Glib
          msys2Libsigcxx
          msys2Glibmm
          msys2Libsndfile
          msys2Curl
          msys2Libarchive
          msys2Liblo
          msys2Taglib
        ];

        shellHook = ''
          export PKG_CONFIG=${pkgConfigWrapper}/bin/pkg-config
          export PKG_CONFIG_PATH=${mingwPkgConfigPath}''${PKG_CONFIG_PATH:+:''${PKG_CONFIG_PATH}}
          export PKG_CONFIG_LIBDIR=${mingwPkgConfigPath}

          echo "target: ${winPkgs.stdenv.hostPlatform.config}"
          echo "cc: $CC"
          echo "windres: $(which windres)"
          echo "pkg-config: $(which pkg-config)"
        '';
      };
    };
}
