# Ardour for Windows x86_64 with Nix

This repository contains a Nix flake that prepares a reproducible MinGW-based
development shell for building Ardour for Windows x86_64 from Linux.

The flake started as a minimal shell with several stubbed dependencies, but the
current setup replaces those shortcuts with real cross-compiled dependencies
resolved through `pkgsCross.mingwW64` and `pkg-config`, following the same
general approach used in the macOS arm64 companion repository where implicit
build inputs had to be made explicit.

## Intended use

This repository is intended to provide developers with a reproducible
dependency-resolution and verification environment for the Windows build. It is
not intended to distribute finished artifacts, and if you build artifacts from
this repository, please do not redistribute them.

## Current status

- `nix develop --impure .#default` now resolves real MinGW dependencies instead
  of generating fake `pkg-config` stubs for missing libraries.
- `rubberband` is provided by a custom package derived from nixpkgs so the
  Windows cross build no longer fails on the unsupported cross-JDK dependency
  pulled in by the stock package.
- The development shell exports MinGW toolchain variables together with
  `PKG_CONFIG_PATH`, `NIX_CFLAGS_COMPILE`, and `NIX_LDFLAGS` derived from the
  realized target dependency closure.
- First shell entry is still expensive because it realizes a large MinGW
  closure.
- A full end-to-end `waf configure` and build verification has not yet been
  recorded in this repository.

## Repository layout

- `flake.nix`
  Main MinGW dev-shell and dependency-resolution recipe.
- `rubberband.nix`
  Custom `rubberband` package used to avoid the unsupported cross-JDK path in
  nixpkgs while keeping a real Windows library package.
- `ardour/`
  Ardour source tree used from this workspace.

## How the flake is structured

Unlike the macOS arm64 repository, this flake is currently organized as a
single development-shell stage rather than a multi-stage packaging pipeline.

### 1. `devShell`

The default shell is a `pkgs.mkShell` that prepares the Windows cross-build
environment.

It does the following:

- Imports `nixpkgs` with `allowBroken` and `allowUnsupportedSystem` enabled so
  cross packages that are usable in practice can still be evaluated.
- Uses `pkgs.pkgsCross.mingwW64` as the source of target libraries and MinGW
  compiler tools.
- Builds a target library set that includes the libraries Ardour's Windows Waf
  configure step is expected to discover.
- Uses a shell-time `nix build --impure --no-link` over the propagated closure
  of those libraries so the `.pc`, header, and library trees exist before
  configure runs.
- Selects the MinGW `pkg-config` wrapper and exports it as `PKG_CONFIG`.
- Computes `PKG_CONFIG_PATH`, `PKG_CONFIG_LIBDIR`, `NIX_CFLAGS_COMPILE`, and
  `NIX_LDFLAGS` from the realized closure instead of hard-coding individual
  store paths.
- Exports `CC`, `CXX`, `AR`, `RANLIB`, `STRIP`, and `WINDRES` for the MinGW
  toolchain.
- Repairs the local `ardour/.git` link shape expected by the source tree when
  used from this workspace layout.

This stage exists because Ardour's Windows build expects more than just a
compiler on `PATH`: it also depends on correctly discoverable `.pc` files,
headers, and library directories for a fairly large MinGW dependency set.

## Dependency selection

The current flake uses a mixed strategy.

### Dependencies kept from nixpkgs

The following are taken directly from `pkgsCross.mingwW64`:

- `boost`
- `glib`
- `glibmm`
- `libsndfile`
- `curl`
- `libarchive`
- `liblo`
- `taglib`
- `vamp-plugin-sdk`
- `fftw`
- `fftwFloat`
- `aubio`
- `libpng`
- `pango`
- `cairomm`
- `pangomm`
- `lv2`
- `libxml2`
- `libwebsockets`
- `jack2`
- `portaudio`
- `lrdf`
- `libsamplerate`
- `serd`
- `sord`
- `sratom`
- `lilv`
- `libogg`
- `flac`
- `libvorbis`
- `libusb1`
- `cppunit`
- `readline`
- `ncurses`
- `fontconfig`
- `freetype`
- `windows.mcfgthreads`

This is intentionally conservative. The immediate goal here is not to redesign
Ardour's Windows dependency stack, but to make the existing cross-build inputs
real and discoverable without local stubs.

### Dependencies customized for this repository

The following dependency is intentionally overridden:

- `rubberband`

#### Why `rubberband` is custom

The stock nixpkgs `pkgsCross.mingwW64.rubberband` package pulls in
`jdk_headless` through its Meson configuration path. That becomes a hard
evaluation failure on `x86_64-windows` because the MinGW cross JDK is marked as
unsupported.

Ardour only needs the native C/C++ `rubberband` library for this build, so the
custom recipe in `rubberband.nix` follows the nixpkgs package closely while
disabling JNI with:

- `-Djni=disabled`

It also disables tests:

- `-Dtests=disabled`

That keeps the package aligned with the upstream source while removing the
cross-JDK blocker that previously forced stub-based workarounds.

## Implicit dependencies made explicit

The most important outcome of the recent cleanup was confirming that the
Windows build was failing not because Ardour lacked dependency support, but
because the shell had been hiding missing cross-build inputs behind ad hoc
stubs.

The current flake makes the following implicit requirements explicit:

- A real MinGW `pkg-config` wrapper must be used, not the host wrapper.
- The full target dependency closure must be realized before configure runs, so
  referenced `.pc` files actually exist in the store.
- Include and library search paths must be exported from that closure rather
  than assumed by the build system.
- `readline` is now provided by real cross packages together with `ncurses`
  instead of a fake local definition.
- `gio-windows-2.0` and the surrounding GLib discovery path now come from real
  cross GLib packages instead of handwritten `.pc` shims.
- `rubberband` now resolves to a real Windows library package instead of being
  stubbed out.

## Why some official differences remain

This repository is still narrower in scope than the macOS arm64 companion
repository.

- It currently focuses on dependency resolution and shell setup, not on
  producing a finished Windows installer or redistributable bundle.
- Some Windows-specific packaging details from Ardour's official release
  process, such as DrMingw integration and final artifact assembly, are not yet
  modeled here.
- The shell is designed to support proper `waf configure` discovery first, then
  later build and packaging work can be layered on top.

## Trial-and-error history summarized

The recent iterations boiled down to three main findings.

- The old shell could appear to move forward only because several missing
  dependencies were being faked locally.
- Replacing those fakes with real MinGW packages exposed that the actual hard
  blocker was nixpkgs `rubberband` depending on an unsupported cross JDK.
- Once `rubberband` was re-packaged without JNI, the shell could go back to a
  cleaner model where dependency discovery is driven by actual `.pc`, header,
  and library outputs from Nix packages.

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
python3 ./waf configure --dist-target=mingw --no-dr-mingw
```

The exact Waf flags you want may still depend on how closely you want to match
Ardour's official Windows packaging flow. The shell is intended to provide the
dependency-resolution layer those commands expect.

## Result layout

At the moment this repository does not produce a final packaged Windows result
tree comparable to the macOS repository's staged outputs.

The main concrete outputs today are:

- the development shell itself
- the realized MinGW dependency closure in the Nix store
- the custom `rubberband` derivation used by that shell

## If you want to go further

The next logical steps are:

- record a clean `waf configure` invocation that succeeds inside this shell
- verify a full Windows build, not just dependency realization
- decide which parts of Ardour's official Windows packaging flow should be
  reproduced inside Nix and which should remain external
