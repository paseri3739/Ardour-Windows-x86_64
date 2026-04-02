# Ardour Windows cross build

`flake.nix` is pinned to `x86_64-linux` as the host platform.

Native Linux:

```bash
nix build .#ardour-windows-build -L
```

Docker/Colima on macOS:

```bash
./build-macos.sh
```

This copies the final Nix output to `./result/`.
`result` is ignored by Git.

Optional:

```bash
REBUILD_IMAGE=1 ./build-macos.sh
FLAKE_TARGET='.#ardour-windows-base' ./build-macos.sh --dry-run
HOST_OUTPUT_DIR="$PWD/result-custom" ./build-macos.sh
```
