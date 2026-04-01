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

      baseWinPthreads =
        if pkgs.lib.hasAttrByPath [ "windows" "pthreads" ] winPkgs then
          winPkgs.windows.pthreads
        else
          winPkgs.windows.mingw_w64_pthreads;

      mkMsys2MingwPackage =
        {
          pname,
          version,
          sha256,
          fixPkgConfig ? false,
          postInstall ? "",
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
          + postInstall
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
        postInstall = ''
          substituteInPlace "$out/lib/pkgconfig/cairo.pc" \
            --replace-fail 'Cflags: -I''${includedir}/cairo' \
                           'Cflags: -I''${includedir}/cairo -I${msys2Freetype}/include/freetype2 -I${msys2Fontconfig}/include'
        '';
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

      msys2Serd = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-serd";
        version = "0.32.8-1";
        sha256 = "sha256-IIA5mLbCjWzezjGQs3ByzSBlK9J9bbul4Ya7dXxeICw=";
        fixPkgConfig = true;
        postInstall = ''
          ln -sfn serd-0/serd "$out/include/serd"
        '';
      };

      msys2Sord = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-sord";
        version = "0.16.22-1";
        sha256 = "sha256-eIGOhk0v6vF1Mi4e0bF9IpUutuvoRhWpBu50jNKLPjI=";
        fixPkgConfig = true;
        postInstall = ''
          ln -sfn sord-0/sord "$out/include/sord"
        '';
      };

      msys2Sratom = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-sratom";
        version = "0.6.22-1";
        sha256 = "sha256-YfirzJTCEX2aTfChkh0VcRMoAPioJmKOJ1jlTTmXm3I=";
        fixPkgConfig = true;
        postInstall = ''
          ln -sfn sratom-0/sratom "$out/include/sratom"
        '';
      };

      msys2Lilv = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-lilv";
        version = "0.26.4-1";
        sha256 = "sha256-z15AJ8lT8alKehmS5u9Xj/1L+O7ceIgwqtJRfTY2m7Q=";
        fixPkgConfig = true;
        postInstall = ''
          ln -sfn lilv-0/lilv "$out/include/lilv"
        '';
      };

      msys2Libogg = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libogg";
        version = "1.3.6-1";
        sha256 = "sha256-fvnsFkA+FImjfDpc5YsINAi6aUxoguZzY54iUN+Yu4s=";
        fixPkgConfig = true;
      };

      msys2Flac = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-flac";
        version = "1.5.0-1";
        sha256 = "sha256-1rL/gLlu62e75QBVK91LLlIc+F45tFKCWmRAVLh8BTs=";
        fixPkgConfig = true;
      };

      msys2Libvorbis = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libvorbis";
        version = "1.3.7-2";
        sha256 = "sha256-ISKNL+DaMUlYDDyLR9dQmsNiWa/w/5WRZGfx0AuHAhw=";
        fixPkgConfig = true;
      };

      msys2Fontconfig = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-fontconfig";
        version = "2.17.1-1";
        sha256 = "sha256-gd06AK1B9Uwf2RQNad606KuuWgqHpoDIBrx2IQsEom4=";
        fixPkgConfig = true;
      };

      msys2Freetype = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-freetype";
        version = "2.14.3-1";
        sha256 = "sha256-s+MQ9FfJA0j9FLjBCF6cA2AW0WiBKmV/7CH0lvfj3pk=";
        fixPkgConfig = true;
      };

      msys2Cppunit = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-cppunit";
        version = "1.15.1-3";
        sha256 = "sha256-SYNEqkaOs2vxPd1YmS6TvaWM5qevwxCCR0Iw27751+g=";
        fixPkgConfig = true;
      };

      msys2Readline = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-readline";
        version = "8.3.003-1";
        sha256 = "sha256-uUPX4qYaxuAwTqwRzc7hU3CowszuW4RIf4rWweED1mw=";
        fixPkgConfig = true;
      };

      msys2Ncurses = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-ncurses";
        version = "6.6-2";
        sha256 = "sha256-HW+Z8gIVb6Lfyu/J9UzZO5Mi/dM+RKXl+pS/ya/4rq4=";
        fixPkgConfig = true;
      };

      steinbergAsioSdk = pkgs.fetchFromGitHub {
        owner = "audiosdk";
        repo = "asio";
        rev = "496a0765b8bb9c26f764f22f9a9712a937177db2";
        hash = "sha256-rUpLQsdvLVHxKGV57Pm3jTx6/avc6KMzzNzJ4BIjg+A=";
      };

      termcapCompat = winPkgs.stdenv.mkDerivation {
        pname = "mingw-termcap-compat";
        version = "1.3.1";

        src = pkgs.fetchurl {
          url = "http://ftpmirror.gnu.org/termcap/termcap-1.3.1.tar.gz";
          hash = "sha256-kaDiLlOHykRntbyxjt8cUbkwJi/UZtX9o5bdnSZxkQA=";
        };

        dontConfigure = true;

        buildPhase = ''
          runHook preBuild

          ${winPkgs.stdenv.cc.targetPrefix}gcc \
            -include io.h \
            -include fcntl.h \
            -DSTDC_HEADERS \
            -DHAVE_STRING_H \
            -c termcap.c tparam.c

          ${winPkgs.stdenv.cc.targetPrefix}ar rcs libtermcap.a termcap.o tparam.o

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/include"
          mkdir -p "$out/lib"
          install -m 644 termcap.h "$out/include/termcap.h"
          install -m 644 libtermcap.a "$out/lib/libtermcap.a"
          runHook postInstall
        '';
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

      msys2ZlibRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-zlib";
        version = "1.3.2-2";
        sha256 = "9e75842a070ba648e986e12424e1c92c9d7d77200e85f6a34eeb600819f2e694";
        fixPkgConfig = true;
      };

      msys2Pcre2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-pcre2";
        version = "10.47-1";
        sha256 = "7c9e3cd47af02a096c0c1810d1021f63c5fb1d22dbec91fa019d8b37eda00d98";
        fixPkgConfig = true;
      };

      msys2LibffiRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libffi";
        version = "3.5.2-1";
        sha256 = "138e44d2752bc8072070c05f1c1387dc8883a0f7f9e38f0bcb272e16264722c4";
        fixPkgConfig = true;
      };

      msys2ZixRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-zix";
        version = "0.8.0-1";
        sha256 = "9c26df48de7229b5837ce9de275a76670c54a531d637a63bbaef975bafc95c34";
        fixPkgConfig = true;
      };

      msys2BrotliRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-brotli";
        version = "1.2.0-1";
        sha256 = "f5f2f7e723a08378241d15f0537386950c1a48e2d82bc47bedd632bd61852aba";
        fixPkgConfig = true;
      };

      msys2Bzip2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-bzip2";
        version = "1.0.8-3";
        sha256 = "653ec97c18dc139ca94e2b4b9d161a9b4d9e77ceb18dfb064eb95ef2a71171b6";
        fixPkgConfig = true;
      };

      msys2ExpatRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-expat";
        version = "2.7.5-1";
        sha256 = "ffa76e6ef6a2db721b5266da4e862d53beb6ba69ecde71f2954109cd7db5609b";
        fixPkgConfig = true;
      };

      msys2Graphite2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-graphite2";
        version = "1.3.14-3";
        sha256 = "7a34b730ebdb7b4be8df91c2ddc9ff4965bd3f8359bb248cb774b5d099fdf5b1";
        fixPkgConfig = true;
      };

      msys2FribidiRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-fribidi";
        version = "1.0.16-1";
        sha256 = "82d4f9e431082d2ac2fa7b9eddd73aa0c073bf8ae66b7d137195797ec543dffa";
        fixPkgConfig = true;
      };

      msys2LibdatrieRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libdatrie";
        version = "0.2.14-1";
        sha256 = "fbbf30e9a911c1139ba5c38c5ae008309dd912f6c6b1e05f4310ec698e1b1339";
        fixPkgConfig = true;
      };

      msys2LibthaiRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libthai";
        version = "0.1.30-1";
        sha256 = "e8cfad91934e24e9a88221b66f2d1c5a310c952ef86631107a632d3ff1738211";
        fixPkgConfig = true;
      };

      msys2McfgthreadLibsRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-mcfgthread-libs";
        version = "2.3.2-1";
        sha256 = "96bdd9c0b4ce47d00be3857a06639a97b00665a231c74a5262899852b8f9078f";
      };

      msys2Libb2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libb2";
        version = "0.98.1-3";
        sha256 = "3c898f08c5f19e25dc6d7e39aa36b6f323141f0e62c5c50f089cd3f89711854c";
      };

      msys2OpenSSLRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-openssl";
        version = "3.6.1-3";
        sha256 = "2788cc26b89a5c73eb73704263aa81acb6b24c73bf8424a688eedd6714902e5c";
      };

      msys2Libidn2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libidn2";
        version = "2.3.8-4";
        sha256 = "f98a157446f9ac35465022e329cdaf6169b0c9fa19837e9d80aff9d4e5109013";
      };

      msys2LibunistringRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libunistring";
        version = "1.3-1";
        sha256 = "25291dc1e1ded3427b6d047ca33fd4ede0b37c5703810ba9f57c931e0276b151";
      };

      msys2Lz4Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-lz4";
        version = "1.10.0-1";
        sha256 = "a4c5a3bcd26111554c87591275b8a681bfa4473d1607647e24c22ef6213c055c";
      };

      msys2XzRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-xz";
        version = "5.8.2-1";
        sha256 = "139d6cb7d176a4525c591f5efc909f1f33f6ae01a0f63aaa44888954cd166e9b";
      };

      msys2LameRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-lame";
        version = "3.100-3";
        sha256 = "083e74a93c2fa764c26d73b5a21e2f5055242bc13997d8dbe6a6c2b4577d6b03";
      };

      msys2Mpg123Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-mpg123";
        version = "1.33.4-1";
        sha256 = "cec31c616c12dd4dbfefa58c3038b75f043dce5a115f746c174cd59706049eaa";
      };

      msys2Nghttp2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-nghttp2";
        version = "1.68.1-1";
        sha256 = "6f230e215d222b5866d8c311db0dc9723750c8ca6d67e11e12ac419d0be8a276";
      };

      msys2Nghttp3Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-nghttp3";
        version = "1.15.0-1";
        sha256 = "fc4cd97728eb66beda500f51d52f502353c50137478c60a05b3f6fef344f18b6";
      };

      msys2Ngtcp2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-ngtcp2";
        version = "1.22.0-1";
        sha256 = "48457afca5f2b47a219d85ba7219e49aefad33ec201dc3c20e74349dc00be751";
      };

      msys2OpusRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-opus";
        version = "1.6.1-1";
        sha256 = "8ff5a273c811e64c5af4c886b6f5d7a8aefca30ef2c7942a7e0a7e62c49e1c25";
      };

      msys2PixmanRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-pixman";
        version = "0.46.4-1";
        sha256 = "236af6cb0ae89c6ef57b2a3199df72e6688d709238f640dd7fe66fdb50e7dfbd";
      };

      msys2LibpslRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libpsl";
        version = "0.21.5-3";
        sha256 = "2a86f7ce3cd3fabff7eb8e5c0d3eb1134808881a44c3838e1b518b75cb402e35";
      };

      msys2Libssh2Runtime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libssh2";
        version = "1.11.1-2";
        sha256 = "83d0b99f79e930b30eb642382662686b696d64ceb927c2606debd79cb6ff670a";
      };

      msys2ZstdRuntime = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-zstd";
        version = "1.5.7-1";
        sha256 = "589c6e808b0bf34872d9ed6f5393a6df389d2ae6e3d1fdb18b8bccfca701f851";
      };

      msys2DrMingw = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-drmingw";
        version = "0.9.11-2";
        sha256 = "sha256-P7Cqx97jxZHuTVQhkVAlUmLOCLLFYRY6kXzwt90pUi8=";
      };

      msys2Jack2 = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-jack2";
        version = "1.9.22-1";
        sha256 = "1xr2cf55cc0dwd5fzd283x1yl7k5r5c7nr0fb3sjjv40xx8kpyq4";
        fixPkgConfig = true;
      };

      msys2Libwebsockets = mkMsys2MingwPackage {
        pname = "mingw-w64-x86_64-libwebsockets";
        version = "4.4.1-2";
        sha256 = "18k98a9ybl5mn0xs1gnx8d2yj7v372yhzfnppq1n1kx00ylsg1g6";
        fixPkgConfig = true;
      };

      msys2Portaudio = winPkgs.stdenv.mkDerivation rec {
        pname = "mingw-w64-x86_64-portaudio";
        version = "svn1963";

        src = pkgs.fetchurl {
          url = "http://ardour.org/files/deps/portaudio-svn1963.tgz";
          hash = "sha256-me0+KQ4C/BUBC4/Vwxh94yqR+g0Y+ovKMavn3EsMDdY=";
        };

        arWrapper = pkgs.writeShellScriptBin "ar" ''
          exec ${winPkgs.stdenv.cc.targetPrefix}ar "$@"
        '';

        ranlibWrapper = pkgs.writeShellScriptBin "ranlib" ''
          exec ${winPkgs.stdenv.cc.targetPrefix}ranlib "$@"
        '';

        nativeBuildInputs = [
          pkgs.autoconf
          pkgs.automake
          pkgs.libtool
          pkgs.which
          arWrapper
          ranlibWrapper
        ];

        configurePhase = ''
          runHook preConfigure

          export AR=${winPkgs.stdenv.cc.targetPrefix}ar
          export RANLIB=${winPkgs.stdenv.cc.targetPrefix}ranlib

          cp -r ${steinbergAsioSdk} ./asiosdk
          chmod -R u+w ./asiosdk

          ./configure \
            --build=${pkgs.stdenv.hostPlatform.config} \
            --host=${winPkgs.stdenv.hostPlatform.config} \
            --prefix=$out \
            --with-host_os=mingw32 \
            --with-winapi=wmme,asio \
            --with-asiodir=$PWD/asiosdk

          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          make lib/libportaudio.la portaudio-2.0.pc
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          make install
          install -m 644 include/pa_asio.h $out/include/pa_asio.h
          runHook postInstall
        '';
      };

      mingwLibgnurx = winPkgs.stdenv.mkDerivation rec {
        pname = "mingw-libgnurx";
        version = "2.5.1";

        src = pkgs.fetchurl {
          url = "http://sourceforge.net/projects/mingw/files/Other/UserContributed/regex/mingw-regex-2.5.1/mingw-libgnurx-2.5.1-src.tar.gz";
          hash = "sha256-cUe3+AbsPQB4Q7OOGfQqW3xliUpX/8KXp2sNzV9nXXY=";
        };

        configureFlags = [
          "--build=${pkgs.stdenv.hostPlatform.config}"
          "--host=${winPkgs.stdenv.hostPlatform.config}"
        ];
      };

      patchedWinPthreads = baseWinPthreads.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace mingw-w64-libraries/winpthreads/include/sched.h \
            --replace-fail 'sched_getscheduler(pid_t pid)' 'sched_getscheduler(_pid_t pid)' \
            --replace-fail 'sched_setscheduler(pid_t pid, int pol, const struct sched_param *param)' 'sched_setscheduler(_pid_t pid, int pol, const struct sched_param *param)'
        '';
      });

      windresWrapper = pkgs.writeShellScriptBin "windres" ''
        exec ${winPkgs.stdenv.cc.targetPrefix}windres "$@"
      '';

      mingwPkgConfigPath = pkgs.lib.concatStringsSep ":" [
        "${winPkgs.zlib.dev}/lib/pkgconfig"
        "${winPkgs.openssl.dev}/lib/pkgconfig"
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
        "${msys2Serd}/lib/pkgconfig"
        "${msys2Sord}/lib/pkgconfig"
        "${msys2Sratom}/lib/pkgconfig"
        "${msys2Lilv}/lib/pkgconfig"
        "${msys2Libogg}/lib/pkgconfig"
        "${msys2Flac}/lib/pkgconfig"
        "${msys2Libvorbis}/lib/pkgconfig"
        "${msys2Fontconfig}/lib/pkgconfig"
        "${msys2Freetype}/lib/pkgconfig"
        "${msys2Cppunit}/lib/pkgconfig"
        "${msys2Readline}/lib/pkgconfig"
        "${msys2Ncurses}/lib/pkgconfig"
        "${msys2Libxml2}/lib/pkgconfig"
        "${msys2Jack2}/lib/pkgconfig"
        "${msys2Libwebsockets}/lib/pkgconfig"
        "${msys2Portaudio}/lib/pkgconfig"
        "${winPkgs.windows.mcfgthreads.dev}/lib/pkgconfig"
      ];

      mingwLibraryPath = pkgs.lib.concatStringsSep ":" [
        "${mingwLibgnurx}/lib"
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
        "${msys2Serd}/lib"
        "${msys2Sord}/lib"
        "${msys2Sratom}/lib"
        "${msys2Lilv}/lib"
        "${msys2Libogg}/lib"
        "${msys2Flac}/lib"
        "${msys2Libvorbis}/lib"
        "${msys2Fontconfig}/lib"
        "${msys2Freetype}/lib"
        "${msys2Cppunit}/lib"
        "${msys2Readline}/lib"
        "${msys2Ncurses}/lib"
        "${termcapCompat}/lib"
        "${msys2Libxml2}/lib"
        "${msys2Jack2}/lib"
        "${msys2Libwebsockets}/lib"
        "${msys2Portaudio}/lib"
        "${msys2GettextRuntime}/lib"
        "${msys2Libiconv}/lib"
        "${msys2DrMingw}/lib"
        "${patchedWinPthreads}/lib"
      ];

      mingwLdFlags = pkgs.lib.concatStringsSep " " [
        "-L${mingwLibgnurx}/lib"
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
        "-L${msys2Serd}/lib"
        "-L${msys2Sord}/lib"
        "-L${msys2Sratom}/lib"
        "-L${msys2Lilv}/lib"
        "-L${msys2Libogg}/lib"
        "-L${msys2Flac}/lib"
        "-L${msys2Libvorbis}/lib"
        "-L${msys2Fontconfig}/lib"
        "-L${msys2Freetype}/lib"
        "-L${msys2Cppunit}/lib"
        "-L${msys2Readline}/lib"
        "-L${msys2Ncurses}/lib"
        "-L${termcapCompat}/lib"
        "-L${msys2Libxml2}/lib"
        "-L${msys2Jack2}/lib"
        "-L${msys2Libwebsockets}/lib"
        "-L${msys2Portaudio}/lib"
        "-L${msys2GettextRuntime}/lib"
        "-L${msys2Libiconv}/lib"
        "-L${msys2DrMingw}/lib"
        "-L${patchedWinPthreads}/lib"
      ];

      mingwTailLibs = pkgs.lib.concatStringsSep " " [
        "-lregex"
        "-lfftw3f_threads"
        "-lsratom-0"
        "-lsord-0"
        "-lserd-0"
      ];

      mingwWrapperCppFlags = pkgs.lib.concatStringsSep " " [
        "-I${mingwLibgnurx}/include"
      ];

      ccWrapper = pkgs.writeShellScriptBin "${winPkgs.stdenv.cc.targetPrefix}gcc-msys2" ''
        linking=1
        for arg in "$@"; do
          case "$arg" in
            -c|-E|-S)
              linking=0
              break
              ;;
          esac
        done

        if [ "$linking" -eq 1 ]; then
          exec ${winPkgs.stdenv.cc.targetPrefix}gcc ${mingwWrapperCppFlags} ${mingwLdFlags} "$@" ${mingwTailLibs}
        else
          exec ${winPkgs.stdenv.cc.targetPrefix}gcc ${mingwWrapperCppFlags} ${mingwLdFlags} "$@"
        fi
      '';

      cxxWrapper = pkgs.writeShellScriptBin "${winPkgs.stdenv.cc.targetPrefix}g++-msys2" ''
        linking=1
        for arg in "$@"; do
          case "$arg" in
            -c|-E|-S)
              linking=0
              break
              ;;
          esac
        done

        if [ "$linking" -eq 1 ]; then
          exec ${winPkgs.stdenv.cc.targetPrefix}g++ ${mingwWrapperCppFlags} ${mingwLdFlags} "$@" ${mingwTailLibs}
        else
          exec ${winPkgs.stdenv.cc.targetPrefix}g++ ${mingwWrapperCppFlags} ${mingwLdFlags} "$@"
        fi
      '';

      pkgConfigWrapper = pkgs.writeShellScriptBin "pkg-config" ''
        export PKG_CONFIG_PATH="${mingwPkgConfigPath}''${PKG_CONFIG_PATH:+:''${PKG_CONFIG_PATH}}"
        export PKG_CONFIG_LIBDIR="${mingwPkgConfigPath}"
        exec ${winPkgs.buildPackages.pkg-config}/bin/${winPkgs.stdenv.cc.targetPrefix}pkg-config "$@"
      '';

      runtimeOnlyWinDllDeps = [
        msys2Pcre2Runtime
        msys2LibffiRuntime
        msys2ZixRuntime
        msys2ZlibRuntime
        msys2BrotliRuntime
        msys2Bzip2Runtime
        msys2ExpatRuntime
        msys2Graphite2Runtime
        msys2FribidiRuntime
        msys2LibdatrieRuntime
        msys2LibthaiRuntime
        msys2McfgthreadLibsRuntime
        msys2Libb2Runtime
        msys2OpenSSLRuntime
        msys2Libidn2Runtime
        msys2LibunistringRuntime
        msys2Lz4Runtime
        msys2XzRuntime
        msys2LameRuntime
        msys2Mpg123Runtime
        msys2Nghttp2Runtime
        msys2Nghttp3Runtime
        msys2Ngtcp2Runtime
        msys2OpusRuntime
        msys2PixmanRuntime
        msys2LibpslRuntime
        msys2Libssh2Runtime
        msys2ZstdRuntime
      ];

      ardourVersion = "9.2";
      ardourSource = pkgs.fetchFromGitHub {
        owner = "Ardour";
        repo = "ardour";
        rev = ardourVersion;
        fetchSubmodules = true;
        hash = "sha256-zbEfEuWdhlKtYE0gVB/N0dFrcmNoJqgEMuvQ0wdmRpM=";
      };

      # External runtime assets that tools/x-win/package.sh downloads during packaging.
      harvidWindowsArchive = pkgs.fetchurl {
        url = "http://ardour.org/files/video-tools/harvid_w64-v0.9.1.tar.xz";
        hash = "sha256-YsZWW31WZ1hjqGl1+Q0HZP5Snjy6afnLDnlyl8UnnE8=";
      };

      xjadeoWindowsArchive = pkgs.fetchurl {
        url = "http://ardour.org/files/video-tools/xjadeo_w64-v0.8.15.tar.xz";
        hash = "sha256-mcy9r5SsgIC7YfcvdL9+KCKFdCAPG8GBst6u9Q5FTyM=";
      };

      x42GmSynthWindowsArchive = pkgs.fetchurl {
        url = "http://x42-plugins.com/x42/win/x42-gmsynth-lv2-w64-v0.6.4.zip";
        hash = "sha256-DtJ8XvDX9fsxTlDLN/T8sTPdzD59oL/51G/oT598V8E=";
      };

      ardourBundledMediaArchive = pkgs.fetchurl {
        url = "http://stuff.ardour.org/loops/ArdourBundledMedia.zip";
        hash = "sha256-oA3gBnHNwymyyjXCpcQVCvPWWIFH+dyi496nUqouI0w=";
      };
    in
    {
      packages.${system} =
        let
          ardourWindowsBase = winPkgs.stdenv.mkDerivation {
            pname = "ardour-windows";
            version = "9.2.0";

            src = ardourSource;

            nativeBuildInputs = [
              pkgs.python3
              pkgs.gcc
              pkgs.perl
              pkgs.gettext
              winPkgs.stdenv.cc
              winPkgs.buildPackages.pkg-config
              windresWrapper
              pkgConfigWrapper
            ];

            buildInputs = [
              mingwLibgnurx
              winPkgs.zlib
              winPkgs.zlib.dev
              winPkgs.openssl.out
              winPkgs.openssl.dev
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
              msys2Serd
              msys2Sord
              msys2Sratom
              msys2Lilv
              msys2Libogg
              msys2Flac
              msys2Libvorbis
              msys2Fontconfig
              msys2Freetype
              msys2Cppunit
              msys2Readline
              msys2Ncurses
              termcapCompat
              msys2Libxml2
              msys2GettextRuntime
              msys2Libiconv
              msys2Jack2
              msys2Libwebsockets
              msys2Portaudio
              patchedWinPthreads
              msys2DrMingw
            ];

            preConfigure = ''
                          # Generate revision.cc if it doesn't exist (GitHub archive doesn't include it)
                          if [ ! -f libs/ardour/revision.cc ]; then
                            mkdir -p libs/ardour
                            cat > libs/ardour/revision.cc << 'EOF'
              #include "ardour/revision.h"
              namespace ARDOUR { const char* revision = "9.2"; const char* date = "$(date -R)"; }
              EOF
                          fi

                          export CC=${ccWrapper}/bin/${winPkgs.stdenv.cc.targetPrefix}gcc-msys2
                          export CXX=${cxxWrapper}/bin/${winPkgs.stdenv.cc.targetPrefix}g++-msys2
                          export CPP=${winPkgs.stdenv.cc.targetPrefix}cpp
                          export AR=${winPkgs.stdenv.cc.targetPrefix}ar
                          export AS=${winPkgs.stdenv.cc.targetPrefix}as
                          export RANLIB=${winPkgs.stdenv.cc.targetPrefix}ranlib
                          export STRIP=${winPkgs.stdenv.cc.targetPrefix}strip
                          export WINDRES=${windresWrapper}/bin/windres
                          export PKG_CONFIG=${pkgConfigWrapper}/bin/pkg-config
                          export PKG_CONFIG_PATH=${mingwPkgConfigPath}''${PKG_CONFIG_PATH:+:''${PKG_CONFIG_PATH}}
                          export PKG_CONFIG_LIBDIR=${mingwPkgConfigPath}
                          export CPPFLAGS="-I${mingwLibgnurx}/include -I${winPkgs.zlib.dev}/include -I${winPkgs.openssl.dev}/include -I${msys2Freetype}/include/freetype2 -I${msys2Fontconfig}/include -I${msys2Serd}/include -I${msys2Sord}/include -I${msys2Sratom}/include -I${msys2Lilv}/include ''${CPPFLAGS:+$CPPFLAGS}"
                          export CFLAGS="$CPPFLAGS ''${CFLAGS:+$CFLAGS}"
                          export CXXFLAGS="$CPPFLAGS ''${CXXFLAGS:+$CXXFLAGS}"
                          export LIBRARY_PATH=${mingwLibraryPath}''${LIBRARY_PATH:+:''${LIBRARY_PATH}}
                          export NIX_LDFLAGS="${mingwLdFlags} ''${NIX_LDFLAGS:+$NIX_LDFLAGS}"
            '';

            dontAddPrefix = true;

            prePatch = ''
              patchShebangs waf
            '';

            configurePhase = ''
              runHook preConfigure
              python ./waf configure \
                --dist-target=mingw \
                --ptformat \
                --with-backends=jack,portaudio,dummy \
                --optimize \
                --cxx17
              runHook postConfigure
            '';

            buildPhase = ''
              runHook preBuild
              python ./waf build
              python ./waf i18n
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r build $out/
              # Stage an install tree so runtime bundling can mirror package.sh PREFIX copies.
              python ./waf install --destdir="$out/prefix"
              runHook postInstall
            '';

            enableParallelBuild = true;

            dontFixup = true;
            dontStrip = true;
          };
        in
        {
          ardour-windows-base = ardourWindowsBase;

          ardour-windows-build = pkgs.stdenvNoCC.mkDerivation {
            pname = "ardour-windows-runtime";
            version = "9.2.0";

            dontUnpack = true;
            nativeBuildInputs = [
              pkgs.gnutar
              pkgs.unzip
              pkgs.xz
            ];
            buildInputs = runtimeOnlyWinDllDeps;

            installPhase = ''
                          runHook preInstall
                          mkdir -p $out
                          cp -r ${ardourWindowsBase}/build $out/

                          major="''${version%%.*}"
                          bundleName="ardour$major"
                          runtimeRoot="$out/runtime"
                          bundleLibDir="$runtimeRoot/lib/$bundleName"
                          buildRoot="${ardourWindowsBase}/build"
                          prefixStore="${ardourWindowsBase}/prefix"
                          prefixShareBundle="$(find "$prefixStore" -type d -path "*/share/$bundleName" | head -n1 || true)"
                          prefixEtcBundle="$(find "$prefixStore" -type d -path "*/etc/$bundleName" | head -n1 || true)"
                          prefixBinDir="$(find "$prefixStore" -type d -path "*/bin" | head -n1 || true)"
                          prefixRoot=""
                          if [ -n "$prefixShareBundle" ]; then
                            prefixRoot="$(dirname "$(dirname "$prefixShareBundle")")"
                          elif [ -n "$prefixBinDir" ]; then
                            prefixRoot="$(dirname "$prefixBinDir")"
                          fi

                          mkdir -p "$runtimeRoot/bin"
                          mkdir -p "$runtimeRoot/share"
                          mkdir -p "$runtimeRoot/lib/gtk-2.0/engines"
                          mkdir -p "$bundleLibDir/surfaces"
                          mkdir -p "$bundleLibDir/backends"
                          mkdir -p "$bundleLibDir/panners"
                          mkdir -p "$bundleLibDir/vamp"
                          mkdir -p "$bundleLibDir/suil"

                          # Copy main executables and Ardour-built DLLs to the executable directory.
                          cp "$buildRoot"/gtk2_ardour/ardour-*.exe "$runtimeRoot/bin/"
                          latest_ardour_exe="$(ls -t "$buildRoot"/gtk2_ardour/ardour-*.exe 2>/dev/null | head -n1 || true)"
                          if [ -n "$latest_ardour_exe" ] && [ -f "$latest_ardour_exe" ]; then
                            cp "$latest_ardour_exe" "$runtimeRoot/bin/Ardour.exe"
                          fi
                          cp "$buildRoot"/libs/gtkmm2ext/gtkmm2ext-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/midi++2/midipp-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/evoral/evoral-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/ardour/ardour-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/temporal/temporal-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/aaf/aaf-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/canvas/canvas-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/widgets/widgets-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/waveview/waveview-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/pbd/pbd-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/ptformat/ptformat-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/audiographer/audiographer-*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/ctrl-interface/midi_surface/ardour*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/ctrl-interface/control_protocol/ardour*.dll "$runtimeRoot/bin/"
                          cp "$buildRoot"/libs/fst/ardour-vst-scanner.exe "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/fst/ardour-vst3-scanner.exe "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/session_utils/*-*.exe "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/luasession/ardour*-lua.exe "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ztk/ztk-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ydk/ydk-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ytk/ytk-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ytkmm/ytkmm-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ydkmm/ydkmm-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ztkmm/ztkmm-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/ydk-pixbuf/ydk-pixbuf-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/tk/suil/suil-*.dll "$runtimeRoot/bin/" || true
                          cp "$buildRoot"/libs/clearlooks-newer/clearlooks.dll "$runtimeRoot/lib/gtk-2.0/engines/libclearlooks.la" || true

                          # Copy module/plugin DLLs to the expected bundle subdirectories.
                          find "$buildRoot"/libs/surfaces -iname "*.dll" -exec cp {} "$bundleLibDir/surfaces/" \;
                          find "$buildRoot"/libs/backends -iname "*.dll" -exec cp {} "$bundleLibDir/backends/" \;
                          find "$buildRoot"/libs/panners -iname "*.dll" -exec cp {} "$bundleLibDir/panners/" \;
                          cp -r "$buildRoot"/libs/LV2 "$bundleLibDir/" || true
                          chmod -R u+w "$bundleLibDir/LV2" 2>/dev/null || true
                          cp "$buildRoot"/libs/vamp-plugins/*ardourvampplugins*.dll "$bundleLibDir/vamp/libardourvampplugins.dll"
                          cp "$buildRoot"/libs/vamp-pyin/*ardourvamppyin*.dll "$bundleLibDir/vamp/libardourvamppyin.dll" || true
                          if [ -d "$buildRoot"/libs/tk/suil ]; then
                            cp "$buildRoot"/libs/tk/suil/suil_win_in_gtk2.dll "$bundleLibDir/suil/" || true
                          fi

                          # Deploy share assets in the same order as package.sh: share/<bundle>, share/locale, etc/<bundle> overlay.
                          mkdir -p "$runtimeRoot/share/$bundleName"
                          if [ -n "$prefixShareBundle" ] && [ -d "$prefixShareBundle" ]; then
                            cp -r "$prefixShareBundle" "$runtimeRoot/share/"
                            prefixShareRoot="$(dirname "$prefixShareBundle")"
                            if [ -d "$prefixShareRoot/locale" ]; then
                              cp -r "$prefixShareRoot/locale" "$runtimeRoot/share/"
                            fi
                          else
                            cp -r ${ardourSource}/share/* "$runtimeRoot/share/$bundleName/"
                          fi
                          if [ -n "$prefixEtcBundle" ] && [ -d "$prefixEtcBundle" ]; then
                            cp -r "$prefixEtcBundle"/* "$runtimeRoot/share/$bundleName/"
                          fi
                          chmod -R u+w "$runtimeRoot/share/$bundleName" 2>/dev/null || true
                          cp -r ${ardourSource}/gtk2_ardour/resources "$runtimeRoot/share/$bundleName/" || true
                          mkdir -p "$runtimeRoot/share/$bundleName/icons"
                          cp -r ${ardourSource}/gtk2_ardour/icons/cursor_square/* "$runtimeRoot/share/$bundleName/icons/" || true
                          cp ${ardourSource}/gtk2_ardour/ArdourMono.ttf "$runtimeRoot/share/$bundleName/" || true
                          cp ${ardourSource}/gtk2_ardour/ArdourSans.ttf "$runtimeRoot/share/$bundleName/" || true
                          cp ${ardourSource}/COPYING "$runtimeRoot/share/" || true
                          cp ${ardourSource}/gtk2_ardour/icons/Ardour.ico "$runtimeRoot/share/" || true
                          cp ${ardourSource}/gtk2_ardour/icons/ArdourBug.ico "$runtimeRoot/share/" || true
                          cp "$buildRoot"/gtk2_ardour/ardour.keys "$runtimeRoot/share/$bundleName/" || true
                          cp "$buildRoot"/gtk2_ardour/ardour.menus "$runtimeRoot/share/$bundleName/" || true
                          cp "$buildRoot"/gtk2_ardour/clearlooks.ardoursans.rc "$runtimeRoot/share/$bundleName/" || true
                          cp "$buildRoot"/gtk2_ardour/clearlooks.rc "$runtimeRoot/share/$bundleName/" || true
                          cp "$buildRoot"/gtk2_ardour/default_ui_config "$runtimeRoot/share/$bundleName/" || true
                          cp ${ardourSource}/system_config "$runtimeRoot/share/$bundleName/" || true

                          # Mirror external downloads from tools/x-win/package.sh inside the runtime tree.
                          mkdir -p "$runtimeRoot/video"
                          tar -xf ${harvidWindowsArchive} -C "$runtimeRoot/video/"
                          tar -xf ${xjadeoWindowsArchive} -C "$runtimeRoot/video/"

                          mkdir -p "$bundleLibDir/LV2"
                          ${pkgs.unzip}/bin/unzip -q -o -d "$bundleLibDir/LV2/" ${x42GmSynthWindowsArchive}

                          mkdir -p "$runtimeRoot/share/$bundleName/media"
                          rm -f "$runtimeRoot/share/$bundleName/media"/*.*
                          ${pkgs.unzip}/bin/unzip -q -o -d "$runtimeRoot/share/$bundleName/media/" ${ardourBundledMediaArchive}

                          # Bring in prefix bin/lib payloads before generic dependency scanning.
                          if [ -n "$prefixRoot" ] && [ -d "$prefixRoot" ]; then
                            if [ -d "$prefixRoot/bin" ]; then
                              cp -n "$prefixRoot/bin"/*.dll "$runtimeRoot/bin/" 2>/dev/null || true
                              cp -n "$prefixRoot/bin"/*.yes "$runtimeRoot/bin/" 2>/dev/null || true
                              if [ -f "$prefixRoot/bin/libportaudio-2.xp" ]; then
                                cp -n "$prefixRoot/bin/libportaudio-2.xp" "$runtimeRoot/bin/" || true
                              elif [ -f "$prefixRoot/bin/libportaudio-2.dll" ]; then
                                cp -n "$prefixRoot/bin/libportaudio-2.dll" "$runtimeRoot/bin/libportaudio-2.xp" || true
                              fi
                            fi
                            if [ -d "$prefixRoot/lib" ]; then
                              cp -n "$prefixRoot/lib"/*.dll "$runtimeRoot/bin/" 2>/dev/null || true
                            fi
                          fi

                          # Copy lv2 ttl metadata from dependency stack (PREFIX/lib/lv2 -> lib/<bundle>/LV2).
                          for libdir in $(echo "${mingwLibraryPath}" | tr ':' ' '); do
                            if [ -d "$libdir/lv2" ]; then
                              for lv2bundle in "$libdir"/lv2/*.lv2; do
                                [ -d "$lv2bundle" ] || continue
                                bn="$(basename "$lv2bundle")"
                                mkdir -p "$bundleLibDir/LV2/$bn"
                                cp -n "$lv2bundle"/*.ttl "$bundleLibDir/LV2/$bn/" 2>/dev/null || true
                              done
                            fi
                          done

                          # Copy dependency DLLs from all configured MinGW runtime/library paths.
                          for libdir in $(echo "${mingwLibraryPath}" | tr ':' ' '); do
                            if [ -d "$libdir" ]; then
                              cp -n "$libdir"/*.dll "$runtimeRoot/bin/" 2>/dev/null || true
                            fi
                            bindir="''${libdir%/lib}/bin"
                            if [ -d "$bindir" ]; then
                              cp -n "$bindir"/*.dll "$runtimeRoot/bin/" 2>/dev/null || true
                              cp -n "$bindir"/*.yes "$runtimeRoot/bin/" 2>/dev/null || true
                              if [ -f "$bindir/libportaudio-2.xp" ]; then
                                cp -n "$bindir/libportaudio-2.xp" "$runtimeRoot/bin/" || true
                              fi
                            fi
                          done
                          if [ ! -f "$runtimeRoot/bin/libportaudio-2.xp" ] && [ -f "$runtimeRoot/bin/libportaudio-2.dll" ]; then
                            cp -n "$runtimeRoot/bin/libportaudio-2.dll" "$runtimeRoot/bin/libportaudio-2.xp" || true
                          fi
                          if [ ! -f "$runtimeRoot/bin/libportaudio-2.xp" ] && [ -f "$runtimeRoot/bin/libportaudio.dll" ]; then
                            cp -n "$runtimeRoot/bin/libportaudio.dll" "$runtimeRoot/bin/libportaudio-2.xp" || true
                          fi

                          # Runtime-only dependencies are added in this phase to avoid polluting compile inputs.
                          for src in ${
                            pkgs.lib.concatStringsSep " " (map (p: "\"${p}\"") runtimeOnlyWinDllDeps)
                          }; do
                            if [ -d "$src" ]; then
                              find "$src" -type f -name "*.dll" -exec cp -n {} "$runtimeRoot/bin/" \;
                            fi
                          done

                          # Ensure compiler runtime DLLs are bundled as well.
                          for d in "${winPkgs.stdenv.cc.cc}/bin" "${winPkgs.stdenv.cc.cc.lib}/bin" "${winPkgs.stdenv.cc.cc.lib}/${winPkgs.stdenv.hostPlatform.config}/lib" "${patchedWinPthreads}/bin"; do
                            if [ -d "$d" ]; then
                              cp -n "$d"/*.dll "$runtimeRoot/bin/" 2>/dev/null || true
                            fi
                          done

                          # Keep behavior aligned with x-win packaging script.
                          rm -f "$runtimeRoot/bin"/libjack*.dll
                          rm -f "$runtimeRoot/bin"/dbghelp*.dll "$runtimeRoot/bin"/dbgcore*.dll
                          find "$runtimeRoot" -type f -name "*.dll.a" -delete 2>/dev/null || true

                          # Convenience launcher for Wine that sets ARDOUR_DLL_PATH for bundle runtime.
                          mkdir -p "$out/bin"
                          cat > "$out/bin/run-ardour-wine" << EOF
              #!/usr/bin/env bash
              set -euo pipefail
              root="\$(cd "\$(dirname "\$0")/.." && pwd)"
              dll_dir_unix="\$root/runtime/lib/$bundleName"
              exe="\$root/runtime/bin/Ardour.exe"
              if [ ! -f "\$exe" ]; then
                exe="\$(ls -1 "\$root"/runtime/bin/ardour-*.exe 2>/dev/null | head -n1)"
              fi

              if [ -z "\$exe" ] || [ ! -f "\$exe" ]; then
                echo "Executable not found under \$root/runtime/bin" >&2
                exit 1
              fi

              if command -v winepath >/dev/null 2>&1; then
                dll_dir_win="\$(winepath -w "\$dll_dir_unix")"
                bin_dir_win="\$(winepath -w "\$root/runtime/bin")"
                data_dir_win="\$(winepath -w "\$root/runtime/share/$bundleName")"
                export ARDOUR_DLL_PATH="\$dll_dir_win"
                export ARDOUR_DATA_PATH="\$data_dir_win"
                export WINEPATH="\$bin_dir_win''${WINEPATH:+;\$WINEPATH}"
              else
                echo "winepath not found; ARDOUR_DLL_PATH/WINEPATH were not translated." >&2
              fi

              exec wine "\$exe" "\$@"
              EOF
                          chmod +x "$out/bin/run-ardour-wine"

                          runHook postInstall
            '';
          };
        };

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.perl
          pkgs.gettext
          winPkgs.stdenv.cc
          winPkgs.buildPackages.pkg-config
          windresWrapper
          pkgConfigWrapper
        ];

        buildInputs = [
          mingwLibgnurx
          winPkgs.zlib
          winPkgs.zlib.dev
          winPkgs.openssl.out
          winPkgs.openssl.dev
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
          msys2Serd
          msys2Sord
          msys2Sratom
          msys2Lilv
          msys2Libogg
          msys2Flac
          msys2Libvorbis
          msys2Fontconfig
          msys2Freetype
          msys2Cppunit
          msys2Readline
          msys2Ncurses
          termcapCompat
          msys2Libxml2
          msys2GettextRuntime
          msys2Libiconv
          msys2Jack2
          msys2Libwebsockets
          msys2Portaudio
          patchedWinPthreads
          msys2DrMingw
        ];

        shellHook = ''
          export CC=${ccWrapper}/bin/${winPkgs.stdenv.cc.targetPrefix}gcc-msys2
          export CXX=${cxxWrapper}/bin/${winPkgs.stdenv.cc.targetPrefix}g++-msys2
          export CPP=${winPkgs.stdenv.cc.targetPrefix}cpp
          export AR=${winPkgs.stdenv.cc.targetPrefix}ar
          export AS=${winPkgs.stdenv.cc.targetPrefix}as
          export RANLIB=${winPkgs.stdenv.cc.targetPrefix}ranlib
          export STRIP=${winPkgs.stdenv.cc.targetPrefix}strip
          export WINDRES=${windresWrapper}/bin/windres
          export PKG_CONFIG=${pkgConfigWrapper}/bin/pkg-config
          export PKG_CONFIG_PATH=${mingwPkgConfigPath}''${PKG_CONFIG_PATH:+:''${PKG_CONFIG_PATH}}
          export PKG_CONFIG_LIBDIR=${mingwPkgConfigPath}
          export CPPFLAGS="-I${mingwLibgnurx}/include -I${winPkgs.zlib.dev}/include -I${winPkgs.openssl.dev}/include -I${msys2Freetype}/include/freetype2 -I${msys2Fontconfig}/include -I${msys2Serd}/include -I${msys2Sord}/include -I${msys2Sratom}/include -I${msys2Lilv}/include ''${CPPFLAGS:+$CPPFLAGS}"
          export CFLAGS="$CPPFLAGS ''${CFLAGS:+$CFLAGS}"
          export CXXFLAGS="$CPPFLAGS ''${CXXFLAGS:+$CXXFLAGS}"
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
