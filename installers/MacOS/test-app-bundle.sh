#!/usr/bin/env bash
#
# macOS smoke test for a built CsoundQt .app bundle.
#
# Run this after the app has been built (and, ideally, after macdeployqt has
# deployed the Qt libraries into the bundle). It verifies that:
#
#   1. The bundle is self-contained: every Qt framework the executable links
#      against lives inside Contents/Frameworks and is reached through an
#      @rpath, with no dangling references back to the Qt installation used
#      to build it (e.g. $HOME/Qt/...). If this is broken the app will only
#      run on machines that happen to have that exact Qt install.
#   2. The cocoa platform plugin is bundled (Contents/PlugIns/platforms).
#   3. The app can actually be launched and stays alive for a few seconds.
#
# The shipped DMG contains the CsoundLib64 .pkg next to the app, and the app
# is deliberately linked against the framework it installs to
# /Applications/Csound. So, before the launch test, that framework must be
# present: pass CSOUND_PKG and the script installs it (end-user equivalent).
#
# Usage:
#   test-app-bundle.sh <path-to-CsoundQt.app>
#
# Environment:
#   CSOUND_PKG            path to the CsoundLib64*.pkg to install when the
#                         framework is missing from /Applications/Csound
#   SMOKE_WAIT_SECONDS     how many seconds the app must stay alive (default 15)

set -euo pipefail

APP="${1:-}"
if [ -z "${APP}" ]; then
    echo "usage: $0 <path-to-CsoundQt.app>" >&2
    exit 2
fi
APP="$(cd "$(dirname "${APP}")" && pwd)/$(basename "${APP}")"
WAIT_SECONDS="${SMOKE_WAIT_SECONDS:-15}"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

[ -d "${APP}" ] || fail "app bundle not found: ${APP}"
[ -d "${APP}/Contents/MacOS" ] || fail "no Contents/MacOS inside ${APP}"

EXEC="$(defaults read "${APP}/Contents/Info" CFBundleExecutable 2>/dev/null || true)"
if [ -z "${EXEC}" ]; then
    EXEC="$(basename "${APP%.app}")"
fi
BIN="${APP}/Contents/MacOS/${EXEC}"
[ -x "${BIN}" ] || fail "main executable missing/not executable: ${BIN}"

echo "== Checking Qt deployment in ${APP} =="

FW_DIR="${APP}/Contents/Frameworks"
if [ ! -d "${FW_DIR}" ]; then
    fail "Contents/Frameworks is missing - Qt libraries were not bundled (macdeployqt did not run)"
fi

# Every Qt framework the executable links against must live inside the bundle
# and be referenced through @rpath. A reference to the build-time Qt install
# (an absolute path) means the app will not start on a machine without it.
problems=0
while read -r dep; do
    case "${dep}" in
        *Qt*framework*)
            if [[ "${dep}" == @rpath/* ]]; then
                fw="${dep#@rpath/}"
                fw="${fw%%/*}"                 # e.g. QtCore.framework
                if [ ! -e "${FW_DIR}/${fw}/${fw%.framework}" ]; then
                    echo "  error: referenced framework not bundled: ${fw}"
                    problems=$((problems + 1))
                fi
            else
                echo "  error: Qt dependency still points outside the bundle: ${dep%% *}"
                problems=$((problems + 1))
            fi
            ;;
    esac
done < <(otool -L "${BIN}")
[ "${problems}" -eq 0 ] || fail "Qt frameworks are not bundled/deployed"

if ! grep -q '@executable_path/../Frameworks' <<<"$(otool -l "${BIN}")"; then
    fail "no @executable_path/../Frameworks rpath - Qt frameworks cannot be found at runtime"
fi

if [ ! -f "${APP}/Contents/PlugIns/platforms/libqcocoa.dylib" ]; then
    fail "cocoa platform plugin missing (Contents/PlugIns/platforms/libqcocoa.dylib)"
fi

echo "  Qt deployment OK (frameworks and platform plugin bundled)"

# ---------------------------------------------------------------- launch --
CSOUND_FW="/Applications/Csound/CsoundLib64.framework"
if [ ! -d "${CSOUND_FW}" ]; then
    if [ -n "${CSOUND_PKG:-}" ] && [ -f "${CSOUND_PKG}" ]; then
        echo "== Installing ${CSOUND_PKG} to provide Csound at runtime =="
        sudo installer -pkg "${CSOUND_PKG}" -target /
    else
        fail "Csound framework not found at ${CSOUND_FW}. Install the Csound .pkg (or set CSOUND_PKG) before launching the app."
    fi
fi

# Process liveness helper: a reaped-dead process is fine, but an unreaped
# zombie would keep passing kill -0, so inspect the ps state as well.
is_alive() {
    local st
    st="$(ps -o stat= -p "$1" 2>/dev/null)" || return 1
    case "${st}" in
        *Z*) return 1 ;;   # zombie
        *)   return 0 ;;
    esac
}

echo "== Launching ${BIN} (must stay alive ${WAIT_SECONDS}s) =="
LOG="$(mktemp)"
"${BIN}" >"${LOG}" 2>&1 &
PID=$!

elapsed=0
while [ "${elapsed}" -lt "${WAIT_SECONDS}" ] && is_alive "${PID}"; do
    sleep 1
    elapsed=$((elapsed + 1))
done

if is_alive "${PID}"; then
    echo "  app is running after ${WAIT_SECONDS}s"
    kill "${PID}" 2>/dev/null || true
    shutdown=0
    while is_alive "${PID}" && [ "${shutdown}" -lt 5 ]; do
        sleep 1
        shutdown=$((shutdown + 1))
    done
    if is_alive "${PID}"; then
        kill -9 "${PID}" 2>/dev/null || true
    fi
    wait "${PID}" 2>/dev/null || true
else
    set +e
    wait "${PID}"
    rc=$?
    set -e
    echo "----- app log -----" >&2
    cat "${LOG}" >&2
    echo "--------------------" >&2
    rm -f "${LOG}"
    fail "app exited (rc=${rc}) after ${elapsed}s - it cannot be launched"
fi

rm -f "${LOG}"
echo "PASS: ${APP} is self-contained and launches on macOS"
