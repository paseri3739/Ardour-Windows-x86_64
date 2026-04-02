#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

image_name="${IMAGE_NAME:-ardour-linux-cross}"
nix_volume="${NIX_VOLUME:-ardour-nix}"
platform="${DOCKER_PLATFORM:-linux/amd64}"
flake_target="${FLAKE_TARGET:-.#ardour-windows-build}"
host_output_dir="${HOST_OUTPUT_DIR:-$repo_root/result}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not in PATH" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "docker is not available. Start Docker Desktop or colima first." >&2
  exit 1
fi

if ! docker image inspect "$image_name" >/dev/null 2>&1 || [ "${REBUILD_IMAGE:-0}" = "1" ]; then
  docker build --platform "$platform" -t "$image_name" "$repo_root"
fi

copy_output=1
for arg in "$@"; do
  case "$arg" in
    --dry-run|--json|--print-out-paths|--no-link)
      copy_output=0
      ;;
  esac
done

if [ "$copy_output" -eq 0 ]; then
  docker run --rm \
    --platform "$platform" \
    -v "$repo_root":/work \
    -v "$nix_volume":/nix \
    -w /work \
    "$image_name" \
    nix build "$flake_target" -L "$@"
  exit 0
fi

store_path="$(
  docker run --rm \
    --platform "$platform" \
    -v "$repo_root":/work \
    -v "$nix_volume":/nix \
    -w /work \
    "$image_name" \
    sh -lc '
      target="$1"
      shift
      nix build "$target" -L "$@" >&2
      nix path-info "$target"
    ' sh "$flake_target" "$@"
)"

tmp_output_dir="${host_output_dir}.tmp.$$"
rm -rf "$tmp_output_dir"
mkdir -p "$tmp_output_dir"

docker run --rm \
  --platform "$platform" \
  -v "$repo_root":/work \
  -v "$nix_volume":/nix \
  -w /work \
  "$image_name" \
  tar -C "$store_path" -cf - . \
  | tar -C "$tmp_output_dir" -xf -

chmod -R u+w "$tmp_output_dir"

rm -rf "$host_output_dir"
mv "$tmp_output_dir" "$host_output_dir"

printf '%s\n' "$store_path" > "$host_output_dir/.store-path"
echo "host output: $host_output_dir"
