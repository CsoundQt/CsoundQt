#!/usr/bin/env bash
#
# Build and run the unit tests in tests/.
#
# Every test is a standalone qmake project: no full CsoundQt build and no
# Csound runtime is needed. test_opcodes is the only one that needs the Csound
# API *headers* (at compile time); it is skipped when they cannot be found.
#
# Each test gets its own build directory. Several tests compile the same
# sources (codescan.cpp, highlighter.cpp, editorthemes.cpp), so a single shared
# output directory (as a TEMPLATE=subdirs wrapper over these .pro files would
# produce) makes them overwrite each other's object files.
#
# Usage:
#   tests/run-tests.sh                       # build and run all tests
#   tests/run-tests.sh --only codescan -v    # one test, full output
#   tests/run-tests.sh --build-dir /tmp/t --clean
#   tests/run-tests.sh --list
#
# On Windows run this in Git Bash (CI uses `shell: bash`, which is Git Bash)
# from a shell that has the MSVC environment, e.g. the "x64 Native Tools
# Command Prompt". With a MinGW Qt, pass `--make mingw32-make`.
#
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# Tests that are executed (and must exit with status 0).
tests=(bracketmatcher codescan gotosource inspectorview opcodes scanservice externallauncher)
# Benchmarks: built, but only executed with --with-benchmark.
benchmarks=(benchmark_channeltext)

build_dir=${BUILD_DIR:-${TMPDIR:-/tmp}/csoundqt-tests}
qmake_bin=${QMAKE:-}
make_bin=${MAKE:-}
jobs=""
only=""
clean=0
strict=0
verbose=0
list_only=0
run_benchmark=0

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    Darwin)               os=macos ;;
    *)                    os=unix ;;
esac

# QT_QPA_PLATFORM=offscreen is required for the widget/GUI tests on headless
# machines (CI) and works everywhere else, too.
export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-offscreen}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'EOF'
Build and run the unit tests in tests/ (qmake only).

Options:
  --build-dir DIR    Where to build. Default: $TMPDIR/csoundqt-tests
  --qmake PATH       qmake to use. Default: qmake6, then qmake (Qt >= 6.7)
  --make NAME        make program. Default: make / nmake / mingw32-make
  --only NAMES       Comma separated subset, e.g. --only codescan,opcodes
  -j, --jobs N       Parallel make jobs. Default: all CPUs
  --clean            Remove the build directories first
  --strict           Treat a skipped test (missing Csound headers) as failure
  --with-benchmark   Also run benchmark_channeltext (built either way)
  -v, --verbose      Show the full test output, also for passing tests
  -l, --list         List the available tests and exit
  -h, --help         Show this help

Environment:
  BUILD_DIR, QMAKE, MAKE, CSOUND_API_INCLUDE_DIR
EOF
}

version_ge() { # $1 >= $2, e.g. version_ge 6.10.2 6.7
    local -a a b
    IFS=. read -r -a a <<< "$1"
    IFS=. read -r -a b <<< "$2"
    local i x y
    for i in 0 1 2; do
        x=${a[i]:-0}
        y=${b[i]:-0}
        ((10#$x > 10#$y)) && return 0
        ((10#$x < 10#$y)) && return 1
    done
    return 0
}

detect_qmake() {
    if [ -n "$qmake_bin" ]; then
        command -v "$qmake_bin" >/dev/null 2>&1 \
            || die "qmake not found: $qmake_bin"
        local v
        v=$("$qmake_bin" -query QT_VERSION 2>/dev/null || true)
        version_ge "$v" 6.7 \
            || die "$qmake_bin uses Qt ${v:-unknown}; CsoundQt requires Qt >= 6.7"
        return
    fi

    local cand v
    for cand in qmake6 qmake-qt6 qmake; do
        command -v "$cand" >/dev/null 2>&1 || continue
        v=$("$cand" -query QT_VERSION 2>/dev/null || true)
        [ -n "$v" ] || continue
        if version_ge "$v" 6.7; then
            qmake_bin=$cand
            return
        fi
    done
    die "no qmake for Qt >= 6.7 found (tried qmake6, qmake-qt6, qmake).
       Qt 5 is not supported; point --qmake at a Qt 6 installation."
}

detect_make() {
    [ -n "$make_bin" ] && return
    if [ "$os" = windows ]; then
        if command -v nmake >/dev/null 2>&1; then
            make_bin=nmake
        elif command -v mingw32-make >/dev/null 2>&1; then
            make_bin=mingw32-make
        else
            die "neither nmake nor mingw32-make found.
       Run this from an MSVC developer prompt or pass --make."
        fi
    elif command -v make >/dev/null 2>&1; then
        make_bin=make
    elif command -v gmake >/dev/null 2>&1; then
        make_bin=gmake
    else
        die "no make found (tried make, gmake)"
    fi
}

detect_jobs() {
    [ -n "$jobs" ] && return
    if command -v nproc >/dev/null 2>&1; then
        jobs=$(nproc)
    elif command -v sysctl >/dev/null 2>&1; then
        jobs=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 1)
    else
        jobs=1
    fi
}

# Convert a POSIX path to something native tools (qmake, QtTest) understand.
# Only needed on Windows; MSYS would convert most arguments anyway, but being
# explicit avoids surprises with drive letters.
native_path() {
    if [ "$os" = windows ] && command -v cygpath >/dev/null 2>&1; then
        cygpath -m "$1"
    else
        printf '%s\n' "$1"
    fi
}

find_csound_include() {
    local -a cands=()
    local cand

    [ -n "${CSOUND_API_INCLUDE_DIR:-}" ] && cands+=("$CSOUND_API_INCLUDE_DIR")

    if command -v pkg-config >/dev/null 2>&1; then
        cand=$(pkg-config --cflags-only-I csound 2>/dev/null \
               | tr ' ' '\n' | sed -n 's/^-I//p' | head -1 || true)
        [ -n "$cand" ] && cands+=("$cand")
    fi

    case "$os" in
        windows)
            [ -n "${CSOUND_DIR:-}" ] && cands+=("$CSOUND_DIR/include/csound")
            [ -n "${GITHUB_WORKSPACE:-}" ] && cands+=("$GITHUB_WORKSPACE/csound7/include/csound")
            [ -n "${PROGRAMFILES:-}" ] && cands+=("$PROGRAMFILES/Csound7/include/csound")
            ;;
        macos)
            cands+=(/Library/Frameworks/CsoundLib64.framework/Headers
                    /Library/Frameworks/CsoundLib64.framework/Versions/Current/Headers
                    /usr/local/Frameworks/CsoundLib64.framework/Headers
                    /usr/local/include/csound
                    /opt/homebrew/include/csound
                    /opt/homebrew/opt/csound/Frameworks/CsoundLib64.framework/Versions/Current/Headers)
            ;;
        *)
            cands+=(/usr/local/include/csound /usr/include/csound)
            ;;
    esac

    for cand in "${cands[@]}"; do
        if [ -f "$cand/csound.h" ]; then
            printf '%s\n' "$cand"
            return 0
        fi
    done
    return 1
}

selected() { # name -> is it requested via --only?
    [ -z "$only" ] && return 0
    local wanted
    for wanted in ${only//,/ }; do
        [ "$wanted" = "$1" ] && return 0
    done
    return 1
}

# Windows: Git Bash has GNU coreutils' `link` in /usr/bin, which shadows MSVC's
# link.exe, and /usr/bin also has a `make` that does not understand MSVC
# Makefiles. Drop those entries before invoking the real build tool.
run_make() {
    if [ "$os" = windows ]; then
        local filtered="" p
        while IFS= read -r p; do
            case "$p" in
                */usr/bin|/usr/bin|*/bin|/bin|*/mingw*/bin) ;;
                *) filtered="${filtered}:${p}" ;;
            esac
        done < <(printf '%s' "$PATH" | tr ':' '\n')
        env PATH="${filtered#:}" "$make_bin" "$@"
    else
        "$make_bin" "$@"
    fi
}

totals_of() { # build dir -> "Totals: ..." line
    local out=$1 file line
    for file in "$out/results.txt" "$out/run.log"; do
        [ -f "$file" ] || continue
        line=$(grep -m1 '^Totals:' "$file" || true)
        if [ -n "$line" ]; then
            printf '%s\n' "$line"
            return 0
        fi
    done
    printf 'no Totals line\n'
}

passed=0
failed=0
skipped=0
failed_names=()

record() {
    local status=$1 name=$2 detail=$3
    case "$status" in
        PASS) passed=$((passed + 1)) ;;
        SKIP) skipped=$((skipped + 1)) ;;
        *)    failed=$((failed + 1)); failed_names+=("$name") ;;
    esac
    printf '%-4s %-16s %s\n' "$status" "$name" "$detail"
}

build_and_run() {
    local name=$1 run=$2
    local pro="$script_dir/$name.pro"
    local out="$build_dir/$name"
    local bin candidate csound_include qmake_args=() make_args=() totals rc

    if [ ! -f "$pro" ]; then
        record FAIL "$name" "missing $pro"
        return
    fi

    csound_include=""
    if [ "$name" = opcodes ]; then
        if ! csound_include=$(find_csound_include); then
            if [ "$strict" = 1 ]; then
                record FAIL "$name" "Csound API headers not found (set CSOUND_API_INCLUDE_DIR)"
            else
                record SKIP "$name" "Csound API headers not found (set CSOUND_API_INCLUDE_DIR)"
            fi
            return
        fi
    fi

    [ "$clean" = 1 ] && rm -rf "$out"
    mkdir -p "$out"

    qmake_args=(CONFIG+=release)
    if [ -n "$csound_include" ]; then
        qmake_args+=("CSOUND_API_INCLUDE_DIR=$(native_path "$csound_include")")
    fi

    if ! ( cd "$out" && "$qmake_bin" "$(native_path "$pro")" "${qmake_args[@]}" ) \
            >"$out/qmake.log" 2>&1; then
        record FAIL "$name" "qmake failed"
        sed 's/^/     /' "$out/qmake.log" | tail -20
        return
    fi

    # nmake has no -j.
    [ "$make_bin" != nmake ] && make_args=(-j"$jobs")

    if ! ( cd "$out" && run_make "${make_args[@]}" ) >"$out/build.log" 2>&1; then
        record FAIL "$name" "build failed"
        sed 's/^/     /' "$out/build.log" | tail -30
        return
    fi

    if [ "$run" = 0 ]; then
        record PASS "$name" "built (not run)"
        return
    fi

    # Not `find ... | head -1`: under `set -o pipefail` the SIGPIPE from head
    # would abort the script. `-print -quit` is not available in BSD find.
    bin=""
    if [ "$os" = windows ]; then
        while IFS= read -r candidate; do bin=$candidate; break; done \
            < <(find "$out" -maxdepth 2 -type f -iname "test_$name.exe")
    else
        while IFS= read -r candidate; do bin=$candidate; break; done \
            < <(find "$out" -maxdepth 2 -type f -name "test_$name")
    fi
    if [ -z "$bin" ]; then
        record FAIL "$name" "executable not found"
        { ls -R "$out" | sed 's/^/     /' | head -40; } || true
        return
    fi

    set +e
    ( cd "$out" && "$bin" -o results.txt,txt ) >"$out/run.log" 2>&1
    rc=$?
    set -e

    totals=$(totals_of "$out")
    if [ "$rc" -eq 0 ]; then
        record PASS "$name" "$totals"
        if [ "$verbose" = 1 ]; then
            cat "$out/results.txt"
        fi
    else
        record FAIL "$name" "exit $rc, $totals"
        cat "$out/results.txt" 2>/dev/null || cat "$out/run.log"
    fi
    return 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --build-dir)      build_dir=$2; shift 2 ;;
        --build-dir=*)    build_dir=${1#*=}; shift ;;
        --qmake)          qmake_bin=$2; shift 2 ;;
        --qmake=*)        qmake_bin=${1#*=}; shift ;;
        --make)           make_bin=$2; shift 2 ;;
        --make=*)         make_bin=${1#*=}; shift ;;
        -j|--jobs)        jobs=$2; shift 2 ;;
        -j*)              jobs=${1#-j}; shift ;;
        --only)           only=$2; shift 2 ;;
        --only=*)         only=${1#*=}; shift ;;
        --clean)          clean=1; shift ;;
        --strict)         strict=1; shift ;;
        --with-benchmark) run_benchmark=1; shift ;;
        -v|--verbose)     verbose=1; shift ;;
        -l|--list)        list_only=1; shift ;;
        -h|--help)        usage; exit 0 ;;
        *)                die "unknown option: $1 (see --help)" ;;
    esac
done

if [ "$list_only" = 1 ]; then
    printf '%s\n' "${tests[@]}" "${benchmarks[@]}"
    exit 0
fi

# Relative build directories are resolved against the current directory.
case "$build_dir" in
    /*|[A-Za-z]:[/\\]*) ;;
    *) build_dir="$PWD/$build_dir" ;;
esac

detect_qmake
detect_make
detect_jobs

printf 'qmake:     %s (Qt %s)\n' "$qmake_bin" "$("$qmake_bin" -query QT_VERSION)"
if [ "$make_bin" = nmake ]; then
    printf 'make:      %s\n' "$make_bin"
else
    printf 'make:      %s -j%s\n' "$make_bin" "$jobs"
fi
printf 'build dir: %s\n\n' "$build_dir"

for name in "${tests[@]}"; do
    selected "$name" || continue
    build_and_run "$name" 1
done

for name in "${benchmarks[@]}"; do
    selected "$name" || continue
    build_and_run "$name" "$run_benchmark"
done

printf '\n%d test(s): %d passed, %d failed, %d skipped\n' \
    "$((passed + failed + skipped))" "$passed" "$failed" "$skipped"
if [ "$failed" -gt 0 ]; then
    printf 'failed: %s\n' "${failed_names[*]}"
    exit 1
fi
exit 0
