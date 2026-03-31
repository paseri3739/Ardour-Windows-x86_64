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
                if grep -q '/mingw64' "$pc"; then
                  substituteInPlace "$pc" --replace-fail '/mingw64' "$out"
                fi
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

      msys2VampPluginSdk = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-vamp-plugin-sdk";
        version = "2.10.0-4";
        sha256 = "0d2q50nfp90sxnija6rznp0ighpfb08vyc19xwqfa0wqf2yq0fy2";
        fixPkgConfig = true;
      };

      msys2Rubberband = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-rubberband";
        version = "3.3.0-1";
        sha256 = "0cajlcip657nl8mn1fabr5qkwh32ghzszn7gjqrl8ih185f4h7g6";
        fixPkgConfig = true;
      };

      msys2Fftw = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-fftw";
        version = "3.3.10-5";
        sha256 = "1v5ldkziwdvi07v3lhg4pm3sh1247c4a90cnhhp0qg5hjlxn1lcg";
        fixPkgConfig = true;
      };

      msys2Libsamplerate = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libsamplerate";
        version = "0.2.2-1";
        sha256 = "1dpqa6jr5hck5q326y47vraxw3s28h1gl42dm3r8sbx2n672sjs5";
        fixPkgConfig = true;
      };

      msys2Libusb = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libusb";
        version = "1.0.28-1";
        sha256 = "1bykzp5vilggnjl7146jqzcja710hh3c98ff6va63hairg3yw7m6";
        fixPkgConfig = true;
      };

      msys2Aubio = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-aubio";
        version = "0.4.9-10";
        sha256 = "sha256-Ms87e3od79rqo49QDF2aCdcYiJ3XvN9+U/rrsHH0aHk=";
        fixPkgConfig = true;
      };

      msys2Libpng = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libpng";
        version = "1.6.56-1";
        sha256 = "sha256-t9dHEbqXdGcuVHdhRTvNaGPFkAr0WXl8+Aj8rwbmvzs=";
        fixPkgConfig = true;
      };

      msys2Pango = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-pango";
        version = "1.56.4-3";
        sha256 = "sha256-H+4BljXgSRLt8q5D4Gb8g9G9S3QEllBLz+zGagCI9Sc=";
        fixPkgConfig = true;
      };

      msys2Harfbuzz = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-harfbuzz";
        version = "13.2.1-1";
        sha256 = "sha256-xBUh+SN0QlB6s7TiRvA6A6h0yydn63hNvRxEoemK/ug=";
        fixPkgConfig = true;
      };

      msys2Cairo = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-cairo";
        version = "1.18.4-4";
        sha256 = "sha256-FIcSBWLkJgGoRi2ZUwmPaFxROZmi5HKjUk+pZDS+MpA=";
        fixPkgConfig = true;
      };

      msys2Cairomm = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-cairomm";
        version = "1.14.5-2";
        sha256 = "sha256-tXE/EW9ilUZQjWYvvY5nVgDCYYfuBfrZ+oB7R8rg83g=";
        fixPkgConfig = true;
      };

      msys2Pangomm = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-pangomm";
        version = "2.46.4-2";
        sha256 = "sha256-JB9zq3o8qu1AkFW/fSXEgUozyDMh5UrYqA69ooO0uaA=";
        fixPkgConfig = true;
      };

      msys2Lv2 = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-lv2";
        version = "1.18.10-1";
        sha256 = "sha256-NEQ3Q323zgqkOnxya6M1d293qrv6W6dIz0qrh26q/Tw=";
        fixPkgConfig = true;
      };

      msys2Libxml2 = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libxml2";
        version = "2.15.2-1";
        sha256 = "sha256-qcNu+CppxlWruch7LO+9/4Yl06vQZe5hxOJwn20pGR4=";
        fixPkgConfig = true;
      };

      msys2GettextRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-gettext-runtime";
        version = "1.0-1";
        sha256 = "sha256-vmjX8mBjMoS5EMWIxtgu4wSoHIgXpobSzZ34P4csJ68=";
      };

      msys2Libiconv = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libiconv";
        version = "1.19-1";
        sha256 = "sha256-IeM00JEfJd510+GOBpdki87PqWWCVtYAytCCfXGcLzU=";
      };

      msys2DrMingw = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-drmingw";
        version = "0.9.11-2";
        sha256 = "sha256-P7Cqx97jxZHuTVQhkVAlUmLOCLLFYRY6kXzwt90pUi8=";
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
        "${msys2VampPluginSdk}/lib/pkgconfig"
        "${msys2Fftw}/lib/pkgconfig"
        "${msys2Libsamplerate}/lib/pkgconfig"
        "${msys2Libusb}/lib/pkgconfig"
        "${msys2Rubberband}/lib/pkgconfig"
        "${msys2Aubio}/lib/pkgconfig"
        "${msys2Libpng}/lib/pkgconfig"
        "${msys2Pango}/lib/pkgconfig"
        "${msys2Harfbuzz}/lib/pkgconfig"
        "${msys2Cairo}/lib/pkgconfig"
        "${msys2Cairomm}/lib/pkgconfig"
        "${msys2Pangomm}/lib/pkgconfig"
        "${msys2Lv2}/lib/pkgconfig"
        "${msys2Libxml2}/lib/pkgconfig"
        "${winPkgs.windows.mcfgthreads.dev}/lib/pkgconfig"
      ];

      mingwLibraryPath = pkgs.lib.concatStringsSep ":" [
        "${msys2Boost}/lib"
        "${msys2BoostLibs}/lib"
        "${msys2Glib}/lib"
        "${msys2Libsigcxx}/lib"
        "${msys2Glibmm}/lib"
        "${msys2Libsndfile}/lib"
        "${msys2Curl}/lib"
        "${msys2Libarchive}/lib"
        "${msys2Liblo}/lib"
        "${msys2Taglib}/lib"
        "${msys2VampPluginSdk}/lib"
        "${msys2Fftw}/lib"
        "${msys2Libsamplerate}/lib"
        "${msys2Libusb}/lib"
        "${msys2Rubberband}/lib"
        "${msys2Aubio}/lib"
        "${msys2Libpng}/lib"
        "${msys2Pango}/lib"
        "${msys2Harfbuzz}/lib"
        "${msys2Cairo}/lib"
        "${msys2Cairomm}/lib"
        "${msys2Pangomm}/lib"
        "${msys2Lv2}/lib"
        "${msys2Libxml2}/lib"
        "${msys2GettextRuntime}/lib"
        "${msys2Libiconv}/lib"
        "${msys2DrMingw}/lib"
        "${winPkgs.windows.mingw_w64_pthreads}/lib"
      ];

      mingwLdFlags = pkgs.lib.concatStringsSep " " [
        "-L${msys2Boost}/lib"
        "-L${msys2BoostLibs}/lib"
        "-L${msys2Glib}/lib"
        "-L${msys2Libsigcxx}/lib"
        "-L${msys2Glibmm}/lib"
        "-L${msys2Libsndfile}/lib"
        "-L${msys2Curl}/lib"
        "-L${msys2Libarchive}/lib"
        "-L${msys2Liblo}/lib"
        "-L${msys2Taglib}/lib"
        "-L${msys2VampPluginSdk}/lib"
        "-L${msys2Fftw}/lib"
        "-L${msys2Libsamplerate}/lib"
        "-L${msys2Libusb}/lib"
        "-L${msys2Rubberband}/lib"
        "-L${msys2Aubio}/lib"
        "-L${msys2Libpng}/lib"
        "-L${msys2Pango}/lib"
        "-L${msys2Harfbuzz}/lib"
        "-L${msys2Cairo}/lib"
        "-L${msys2Cairomm}/lib"
        "-L${msys2Pangomm}/lib"
        "-L${msys2Lv2}/lib"
        "-L${msys2Libxml2}/lib"
        "-L${msys2GettextRuntime}/lib"
        "-L${msys2Libiconv}/lib"
        "-L${msys2DrMingw}/lib"
        "-L${winPkgs.windows.mingw_w64_pthreads}/lib"
      ];

      ccWrapper = pkgs.writeShellScriptBin "${winPkgs.stdenv.cc.targetPrefix}gcc-msys2" ''
        exec ${winPkgs.stdenv.cc.targetPrefix}gcc ${mingwLdFlags} "$@"
      '';

      cxxWrapper = pkgs.writeShellScriptBin "${winPkgs.stdenv.cc.targetPrefix}g++-msys2" ''
        exec ${winPkgs.stdenv.cc.targetPrefix}g++ ${mingwLdFlags} "$@"
      '';

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
          msys2VampPluginSdk
          msys2Fftw
          msys2Libsamplerate
          msys2Libusb
          msys2Rubberband
          msys2Aubio
          msys2Libpng
          msys2Pango
          msys2Harfbuzz
          msys2Cairo
          msys2Cairomm
          msys2Pangomm
          msys2Lv2
          msys2Libxml2
          msys2GettextRuntime
          msys2Libiconv
          winPkgs.windows.mingw_w64_pthreads
          msys2DrMingw
        ];

        shellHook = ''
          export CC=${ccWrapper}/bin/${winPkgs.stdenv.cc.targetPrefix}gcc-msys2
          export CXX=${cxxWrapper}/bin/${winPkgs.stdenv.cc.targetPrefix}g++-msys2
          export AR=${winPkgs.stdenv.cc.targetPrefix}ar
          export RANLIB=${winPkgs.stdenv.cc.targetPrefix}ranlib
          export STRIP=${winPkgs.stdenv.cc.targetPrefix}strip
          export WINDRES=${windresWrapper}/bin/windres
          export PKG_CONFIG=${pkgConfigWrapper}/bin/pkg-config
          export PKG_CONFIG_PATH=${mingwPkgConfigPath}''${PKG_CONFIG_PATH:+:''${PKG_CONFIG_PATH}}
          export PKG_CONFIG_LIBDIR=${mingwPkgConfigPath}
          export LIBRARY_PATH=${mingwLibraryPath}''${LIBRARY_PATH:+:''${LIBRARY_PATH}}
          export NIX_LDFLAGS="${mingwLdFlags} ''${NIX_LDFLAGS:+$NIX_LDFLAGS}"

          echo "target: ${winPkgs.stdenv.hostPlatform.config}"
          echo "cc: $CC"
          echo "windres: $(which windres)"
          echo "pkg-config: $(which pkg-config)"
        '';
      };
    };
}
