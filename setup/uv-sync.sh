#!/usr/bin/env bash
set -euo pipefail

UV_BIN="${UV_BIN:-uv}"
if ! command -v "${UV_BIN}" >/dev/null 2>&1; then
  echo "uv command not found. Install uv (mise install uv) or set UV_BIN." >&2
  exit 1
fi

platform="$(uname -s)"
arch="$(uname -m)"
uv_platform=""

case "${platform}" in
  Darwin)
    if [[ "${arch}" == "arm64" ]]; then
      uv_platform="aarch64-apple-darwin"
    else
      uv_platform="x86_64-apple-darwin"
    fi
    # Avoid CUDA wheels when resolving on macOS
    export UV_TORCH_BACKEND="${UV_TORCH_BACKEND:-cpu}"
    ;;
  Linux)
    if [[ "${arch}" == "x86_64" ]]; then
      uv_platform="x86_64-unknown-linux-gnu"
    elif [[ "${arch}" == "aarch64" ]]; then
      uv_platform="aarch64-unknown-linux-gnu"
    fi
    ;;
esac

args=(sync --no-lock)
if [[ -n "${uv_platform}" ]]; then
  args+=(--python-platform "${uv_platform}")
fi

"${UV_BIN}" "${args[@]}"
