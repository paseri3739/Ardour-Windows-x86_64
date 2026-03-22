{
  description = "Minimal devShell for Ardour-Windows-x86_64";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      overlay = final: prev: {
        openssl_3_6 = prev.openssl_3_6.overrideAttrs (old: {
          patches = pkgs.lib.filter (
            patch: !(pkgs.lib.hasSuffix "/3.5/fix-mingw-linking.patch" (toString patch))
          ) old.patches;
        });
        openssl = final.openssl_3_6;
        libsamplerate = prev.callPackage ./libsamplerate.nix { };
        rubberband = prev.callPackage ./rubberband.nix { };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowBroken = true;
        config.allowUnsupportedSystem = true;
      };
      crossPkgs = import nixpkgs {
        inherit system;
        crossSystem = pkgs.lib.systems.examples.mingwW64;
        overlays = [ overlay ];
        config.allowBroken = true;
        config.allowUnsupportedSystem = true;
      };
      buildPkgs = crossPkgs.buildPackages;
      targetLibraries = with crossPkgs; [
        boost
        glib
        glibmm
        libsndfile
        curl
        libarchive
        liblo
        taglib
        vamp-plugin-sdk
        rubberband
        fftw
        fftwFloat
        aubio
        libpng
        pango
        cairomm
        pangomm
        lv2
        libxml2
        libwebsockets
        jack2
        portaudio
        lrdf
        libsamplerate
        serd
        sord
        sratom
        lilv
        libogg
        flac
        libvorbis
        libusb1
        cppunit
        readline
        ncurses
        fontconfig
        freetype
        windows.mcfgthreads
      ];
      flakeRootExpr = builtins.toJSON (toString ./.);
      crossEvalPrelude = ''
        let
          hostPkgs = import (builtins.getFlake ${flakeRootExpr}).inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
          };
          overlay = final: prev: {
            openssl_3_6 = prev.openssl_3_6.overrideAttrs (old: {
              patches = hostPkgs.lib.filter (
                patch: !(hostPkgs.lib.hasSuffix "/3.5/fix-mingw-linking.patch" (toString patch))
              ) old.patches;
            });
            openssl = final.openssl_3_6;
            libsamplerate = prev.callPackage (/. + builtins.getEnv "LIBSAMPLERATE_NIX_FILE") { };
            rubberband = prev.callPackage (/. + builtins.getEnv "RUBBERBAND_NIX_FILE") { };
          };
          pkgs = import (builtins.getFlake ${flakeRootExpr}).inputs.nixpkgs {
            system = "x86_64-linux";
            crossSystem = hostPkgs.lib.systems.examples.mingwW64;
            overlays = [ overlay ];
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
          };
          crossPkgs = pkgs;
          targetLibraries = with crossPkgs; [
            boost
            glib
            glibmm
            libsndfile
            curl
            libarchive
            liblo
            taglib
            vamp-plugin-sdk
            rubberband
            fftw
            fftwFloat
            aubio
            libpng
            pango
            cairomm
            pangomm
            lv2
            libxml2
            libwebsockets
            jack2
            portaudio
            lrdf
            libsamplerate
            serd
            sord
            sratom
            lilv
            libogg
            flac
            libvorbis
            libusb1
            cppunit
            readline
            ncurses
            fontconfig
            freetype
            windows.mcfgthreads
          ];
          targetLibraryClosure = pkgs.lib.closePropagation targetLibraries;
        in
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.git
          pkgs.python3
          buildPkgs.pkg-config
          crossPkgs.stdenv.cc
          crossPkgs.stdenv.cc.bintools
        ];

        shellHook = ''
          mkdir -p .nix-shell-tools
          ln -sfn "$(command -v x86_64-w64-mingw32-windres)" .nix-shell-tools/windres
          export PATH="$PWD/.nix-shell-tools:$PATH"
          export LIBSAMPLERATE_NIX_FILE="$PWD/libsamplerate.nix"
          export RUBBERBAND_NIX_FILE="$PWD/rubberband.nix"

          for candidate in \
            "${buildPkgs.pkg-config}/bin/x86_64-w64-mingw32-pkg-config" \
            "${buildPkgs.pkg-config}/bin/pkg-config"
          do
            if [ -x "$candidate" ]; then
              export PKG_CONFIG="$candidate"
              break
            fi
          done

          if [ -z "''${PKG_CONFIG:-}" ]; then
            echo "error: mingw pkg-config wrapper not found in ${buildPkgs.pkg-config}/bin" >&2
            return 1
          fi

          NIXPKGS_ALLOW_BROKEN=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix build --impure --no-link --expr '${crossEvalPrelude}
            pkgs.lib.concatMap
              (pkg: [ (if pkg ? dev then pkg.dev else pkg) pkg ])
              (pkgs.lib.unique targetLibraryClosure)' >/dev/null

          export PATH="$(dirname "$PKG_CONFIG"):$PATH"
          export PKG_CONFIG_PATH="$(
            NIXPKGS_ALLOW_BROKEN=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix eval --impure --raw --expr '${crossEvalPrelude}
              pkgs.lib.concatStringsSep ":" (pkgs.lib.unique (builtins.filter (path: path != "") [
                (pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" targetLibraryClosure)
                (pkgs.lib.makeSearchPathOutput "dev" "share/pkgconfig" targetLibraryClosure)
                (pkgs.lib.makeSearchPathOutput "out" "lib/pkgconfig" targetLibraryClosure)
                (pkgs.lib.makeSearchPathOutput "out" "share/pkgconfig" targetLibraryClosure)
              ]))'
          )"
          export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
          export CC=x86_64-w64-mingw32-gcc
          export CXX=x86_64-w64-mingw32-g++
          export AR=x86_64-w64-mingw32-ar
          export RANLIB=x86_64-w64-mingw32-ranlib
          export STRIP=x86_64-w64-mingw32-strip
          export WINDRES=windres
          export NIX_CFLAGS_COMPILE="$(
            NIXPKGS_ALLOW_BROKEN=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix eval --impure --raw --expr '${crossEvalPrelude}
              pkgs.lib.concatStringsSep " " (map (path: "-I''${path}") (pkgs.lib.unique (builtins.filter (path: path != "") [
                (pkgs.lib.makeSearchPathOutput "dev" "include" targetLibraryClosure)
                (pkgs.lib.makeSearchPathOutput "out" "include" targetLibraryClosure)
              ])))'
          ) ''${NIX_CFLAGS_COMPILE:-}"
          export NIX_LDFLAGS="$(
            NIXPKGS_ALLOW_BROKEN=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix eval --impure --raw --expr '${crossEvalPrelude}
              pkgs.lib.concatStringsSep " " (map (path: "-L''${path}") (pkgs.lib.unique (builtins.filter (path: path != "") [
                (pkgs.lib.makeSearchPathOutput "dev" "lib" targetLibraryClosure)
                (pkgs.lib.makeSearchPathOutput "out" "lib" targetLibraryClosure)
              ])))'
          ) ''${NIX_LDFLAGS:-}"
          export PKG_CONFIG_SYSTEM_LIBRARY_PATH=
          export PKG_CONFIG_SYSTEM_INCLUDE_PATH=

          if [ -f ardour/.git ] && grep -q '^gitdir: ../.git/modules/ardour$' ardour/.git 2>/dev/null; then
            rm -f ardour/.git
            ln -s ../.git/modules/ardour ardour/.git
          elif [ ! -e ardour/.git ]; then
            ln -s ../.git ardour/.git
          fi
        '';
      };
    };
}
