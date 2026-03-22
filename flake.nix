{
  description = "Minimal devShell for Ardour-Windows-x86_64";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.git
          pkgs.boost
          pkgs.glib
          pkgs.glibmm
          pkgs.libsndfile
          pkgs.curl
          pkgs.libarchive
          pkgs.liblo
          pkgs.taglib
          pkgs.vamp-plugin-sdk
          pkgs.rubberband
          pkgs.fftw
          pkgs.fftwFloat
          pkgs.aubio
          pkgs.libpng
          pkgs.pango
          pkgs.cairomm
          pkgs.pangomm
          pkgs.lv2
          pkgs.libxml2
          pkgs.libwebsockets
          pkgs.jack2
          pkgs.portaudio
          pkgs.lrdf
          pkgs.libsamplerate
          pkgs.serd
          pkgs.sord
          pkgs.sratom
          pkgs.lilv
          pkgs.libogg
          pkgs.flac
          pkgs.libvorbis
          pkgs.libusb1
          pkgs.cppunit
          pkgs.readline
          pkgs.fontconfig
          pkgs.freetype
          pkgs.pkg-config
          pkgs.pkgsCross.mingwW64.stdenv.cc
          pkgs.pkgsCross.mingwW64.stdenv.cc.bintools
        ];

        shellHook = ''
          mkdir -p .nix-shell-tools
          mkdir -p .nix-shell-tools/lib
          mkdir -p .nix-shell-tools/include
          mkdir -p .nix-shell-tools/pkgconfig
          ln -sfn "$(command -v x86_64-w64-mingw32-windres)" .nix-shell-tools/windres
          ln -sfn "${pkgs.pkgsCross.mingwW64.windows.mcfgthreads}/lib/libmcfgthread.a" .nix-shell-tools/lib/libpthread.a
          cat > .nix-shell-tools/include/exchndl.h <<'EOF'
          #ifndef EXCHNDL_H
          #define EXCHNDL_H
          #ifdef __cplusplus
          extern "C" {
          #endif
          void ExcHndlInit(void);
          void ExcHndlSetLogFileNameA(const char *path);
          #ifdef __cplusplus
          }
          #endif
          #endif
          EOF
          cat > .nix-shell-tools/include/pa_asio.h <<'EOF'
          #ifndef PA_ASIO_H
          #define PA_ASIO_H
          #endif
          EOF
          cat > .nix-shell-tools/exchndl.c <<'EOF'
          void ExcHndlInit(void) {}
          void ExcHndlSetLogFileNameA(const char *path) { (void) path; }
          EOF
          cat > .nix-shell-tools/empty.c <<'EOF'
          void __ardour_configure_stub(void) {}
          EOF
          cat > .nix-shell-tools/readline_stub.c <<'EOF'
          char *rl_readline_name = 0;
          int rl_insert(int count, int key) { (void) count; (void) key; return 0; }
          int rl_bind_key(int key, int (*fn)(int, int)) { (void) key; (void) fn; return 0; }
          char *readline(const char *prompt) { (void) prompt; return 0; }
          void add_history(const char *line) { (void) line; }
          EOF
          cat > .nix-shell-tools/pkgconfig/gio-windows-2.0.pc <<'EOF'
          prefix=/no-prefix
          exec_prefix=''${prefix}
          libdir=''${exec_prefix}/lib
          includedir=''${prefix}/include

          Name: gio-windows-2.0
          Description: shim pkg-config entry for gio Windows API support
          Version: 2.86.3
          Requires: gio-2.0
          Libs:
          Cflags:
          EOF
          x86_64-w64-mingw32-gcc -c .nix-shell-tools/exchndl.c -o .nix-shell-tools/exchndl.o
          x86_64-w64-mingw32-ar rcs .nix-shell-tools/lib/libexchndl.a .nix-shell-tools/exchndl.o
          x86_64-w64-mingw32-gcc -c .nix-shell-tools/empty.c -o .nix-shell-tools/empty.o
          x86_64-w64-mingw32-ar rcs .nix-shell-tools/lib/libmgwhelp.a .nix-shell-tools/empty.o
          x86_64-w64-mingw32-ar rcs .nix-shell-tools/lib/libintl.a .nix-shell-tools/empty.o
          x86_64-w64-mingw32-gcc -c .nix-shell-tools/readline_stub.c -o .nix-shell-tools/readline_stub.o
          x86_64-w64-mingw32-ar rcs .nix-shell-tools/lib/libreadline.a .nix-shell-tools/readline_stub.o
          x86_64-w64-mingw32-ar rcs .nix-shell-tools/lib/libtermcap.a .nix-shell-tools/empty.o
          export PATH="$PWD/.nix-shell-tools:$PATH"
          export PKG_CONFIG_PATH="$PWD/.nix-shell-tools/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
          export NIX_CFLAGS_COMPILE="-I$PWD/.nix-shell-tools/include ''${NIX_CFLAGS_COMPILE:-}"
          export NIX_LDFLAGS="-L$PWD/.nix-shell-tools/lib ''${NIX_LDFLAGS:-}"
          export CC=x86_64-w64-mingw32-gcc
          export CXX=x86_64-w64-mingw32-g++
          export AR=x86_64-w64-mingw32-ar
          export RANLIB=x86_64-w64-mingw32-ranlib
          export STRIP=x86_64-w64-mingw32-strip
          export WINDRES=windres

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
