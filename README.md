# Ardour for Windows x86_64 with Nix

This repository contains a Nix flake that prepares a reproducible MinGW-based
development shell for building Ardour for Windows x86_64 from Linux.

The current setup avoids fake dependency stubs and uses real libraries,
headers, and pkg-config metadata for Windows cross builds.

## Intended use

This repository is intended to provide developers with a reproducible
dependency-resolution and verification environment for the Windows build. It is
not intended to distribute finished artifacts, and if you build artifacts from
this repository, please do not redistribute them.

## Current status

- `nix develop --impure .#default` provides a MinGW toolchain plus explicit
  Windows dependency paths.
- The regex workaround was replaced with a real source build of
  `mingw-libgnurx` (from Ardour's Windows build dependency list), and the
  previous local `regex.h` compatibility shim was removed.
- PortAudio is built from source (`svn1963`) with ASIO support, and
  `pa_asio.h` is installed into the package output for Waf detection.
- `waf configure` has been observed to succeed in this environment (for example
  with `--dist-target=mingw --ptformat --with-backends=jack,portaudio,dummy
  --optimize --cxx17`).
- Full `waf` compile/link completion is still expected to be validated per
  working tree and option set.

## Repository layout

- `flake.nix`
  Main MinGW dev-shell and dependency-resolution recipe.
- `ardour/`
  Ardour source tree used from this workspace.

## How the flake is structured

The flake is organized around a single development shell (`devShell`) for
Windows cross compilation.

### 1. `devShell`

The default shell (`pkgs.mkShell`) prepares the Windows cross-build environment.

It does the following:

- Uses `pkgs.pkgsCross.mingwW64` for the cross compiler and core toolchain.
- Imports many target runtime/development libraries from MSYS2 binary packages
  (`mingw-w64-x86_64-*`) into the Nix store.
- Provides wrappers for `gcc`, `g++`, `windres`, and `pkg-config` so compile,
  link, and pkg-config lookups consistently target MinGW outputs.
- Exports explicit `PKG_CONFIG_PATH` and `PKG_CONFIG_LIBDIR` for the intended
  target `.pc` set.
- Exports explicit include and library search paths through `CPPFLAGS`,
  `CFLAGS`, `CXXFLAGS`, `LIBRARY_PATH`, and `NIX_LDFLAGS`.

This shell exists because Ardour's Windows build expects not just a compiler,
but also correctly discoverable `.pc` files, headers, and libraries for a large
dependency set.

## Dependency strategy

The current flake uses three sources:

- `pkgsCross.mingwW64` for compiler/toolchain and selected base libraries.
- MSYS2 MinGW binary packages imported into Nix for many user-space libraries
  Ardour checks with pkg-config.
- Small local derivations where needed for compatibility:
  `mingw-libgnurx` (real GNU regex library), `termcap` compatibility symlink,
  and source-built PortAudio `svn1963` including ASIO support.

`lrdf` remains not found in this setup (same as before) and is treated as an
optional dependency for this workflow.

## Implicit dependencies made explicit

The shell now encodes these requirements explicitly:

- Use MinGW-targeted `pkg-config`, not host `pkg-config`.
- Keep MinGW `.pc` providers in `PKG_CONFIG_LIBDIR` so Waf checks resolve
  consistently.
- Export include and link paths explicitly for the selected target stack.
- Provide real Windows regex via `mingw-libgnurx` (`regex.h`, `libregex.a`) in
  place of a compatibility header shim.
- Provide `pa_asio.h` from the PortAudio package so Ardour's optional ASIO
  check can succeed when enabled.

Note on ASIO headers: Ardour's PortAudio backend checks for `pa_asio.h` and
includes that header directly. For this workflow, installing `pa_asio.h` is
the relevant requirement; copying the whole ASIO SDK into the dev shell include
path is not required by Ardour's current source checks.

## Known differences from Ardour official packaging

This repository is focused on reproducible build inputs and compile workflow,
not on reproducing the entire official Windows release pipeline.

- Installer assembly and final redistribution layout are out of scope here.
- Optional dependency/version deltas may exist versus official nightly build
  hosts.
- The shell primarily targets reliable `waf configure` and subsequent
  compilation from this workspace.

## Notes from recent fixes

- Windows regex now comes from a real `libgnurx` source build, aligned with
  Ardour nightly dependency notes.
- The previous `regex.h -> <regex>` compatibility trick was removed.
- PortAudio ASIO exposure is handled by shipping `pa_asio.h` in the package
  output used by the shell.

## Usage

### Development shell

Enter the shell with:

```bash
nix develop --impure .#default
```

From there, run Ardour's Windows configure/build commands inside `ardour/`.
For example:

```bash
cd ardour
python3 ./waf configure --dist-target=mingw --ptformat --with-backends=jack,portaudio,dummy --optimize --cxx17
```

The exact Waf flags still depend on your target workflow. The shell is intended
to provide the dependency-resolution layer those commands expect.

## Outputs today

At the moment this repository does not produce a final packaged Windows
installer. The main outputs are:

- the development shell
- the resolved MinGW dependency set in the Nix store
- local helper derivations used by the shell (`mingw-libgnurx`,
  `mingw-termcap-compat`, source-built PortAudio)

## Suggested next checks

- complete and record a full `./waf` build from this shell
- capture any remaining link/runtime deltas against official nightly build logs
- decide whether final installer packaging should stay external or move into
  Nix derivations
