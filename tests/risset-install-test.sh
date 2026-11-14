#!/usr/bin/env bash
#
# Networked integration test for the Plugins window's risset installation.
#
# This mirrors the commands used by PluginsDialog:
#   1. install uv into a user-writable plugin directory,
#   2. install risset with uv into the same directory,
#   3. run "risset info --full" to verify it starts.
#
# It is intentionally not part of tests/run-tests.sh because it needs internet
# access. Run it manually or start the "Test Build qt 6" workflow with the
# "Run the networked risset installation test" input.
#
# GitHub-hosted runners normally have outbound network access; because the
# result also depends on astral.sh, PyPI and network conditions, this test is
# opt-in rather than part of every push.

set -euo pipefail

root=$(mktemp -d "${TMPDIR:-/tmp}/csoundqt-risset-test.XXXXXX")
cleanup() {
    rm -rf "$root"
}
trap cleanup EXIT

bin="$root/bin"
tools="$root/tools"
python="$root/python"
home="$root/home"
mkdir -p "$bin" "$tools" "$python" "$home"
export HOME="$home"
export XDG_DATA_HOME="$root/data"
export XDG_CONFIG_HOME="$root/config"
export XDG_CACHE_HOME="$root/cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"

installer="$root/uv-install.sh"
echo "Downloading the uv installer..."
curl -LsSf https://astral.sh/uv/install.sh -o "$installer"

echo "Installing uv into $bin..."
UV_UNMANAGED_INSTALL="$bin" \
UV_NO_MODIFY_PATH=1 \
UV_DISABLE_UPDATE=1 \
/bin/sh "$installer"

uv="$bin/uv"
test -x "$uv"

echo "Installing risset..."
UV_TOOL_BIN_DIR="$bin" \
UV_TOOL_DIR="$tools" \
UV_PYTHON_INSTALL_DIR="$python" \
UV_NO_PROGRESS=1 \
UV_COLOR=never \
UV_LINK_MODE=copy \
"$uv" tool install --force risset

risset="$bin/risset"
test -x "$risset"

echo "Checking risset..."
"$risset" info --full > "$root/info.json"
grep -q '"version"' "$root/info.json"
version=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$root/info.json" | head -1)
echo "risset installation test passed. ${version:-}"
