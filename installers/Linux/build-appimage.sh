#!/usr/bin/env bash
#
# Build a self-contained CsoundQt AppImage, derived from the Flatpak build
# in flatpak/io.github.CsoundQt.CsoundQt.yml.
#
# Like the Flatpak it builds, from source, and bundles:
#   - liblo            (static, for OSC support)
#   - csound           (Csound 7 engine + its own plugins)
#   - csound-plugins   (external plugin collection incl. jsusfx)
#   - csound-manual    (offline manual)
#   - CsoundQt
#
# and packages them into a single AppImage via linuxdeploy (+ Qt plugin).
#
# The AppImage is NOT sandboxed, so unlike the Flatpak it does not define
# FLATPAK_BUILD: "Run in Terminal" uses the user's configured terminal (the
# host's, no bundled foot needed) and the manual is auto-detected under
# $APPDIR/usr/share/doc/csound-manual/html.
#
# Usage:
#   ./installers/Linux/build-appimage.sh [--install-deps]
#
# Environment overrides:
#   QT_INSTALL_PREFIX   Qt 6 install to use (default: downloaded into $WORK_DIR)
#   QT_VERSION          Qt version to download (default: 6.11.2)
#   WORK_DIR            working directory (default: <repo>/build-appimage)
#   JOBS                parallel build jobs (default: nproc)
#   VERSION             version string for the AppImage name
#
# glibc requirement: the Qt official binaries used here require glibc >= 2.34
# (Qt >= 6.9 is built on RHEL 9). Build on a distro with glibc >= 2.34 (e.g.
# Ubuntu 22.04) so the resulting AppImage runs on any system with glibc >= 2.34.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

WORK_DIR="${WORK_DIR:-$ROOT/build-appimage}"
APPDIR="$WORK_DIR/AppDir"
SRC_DIR="$WORK_DIR/src"
TOOLS_DIR="$WORK_DIR/tools"
DOWNLOADS_DIR="$WORK_DIR/downloads"
JOBS="${JOBS:-$(nproc)}"
VERSION="${VERSION:-7.0.1}"

# --- versions, pinned to the same commits as the Flatpak manifest -----------
LIBLO_VERSION="0.35"
LIBLO_URL="https://github.com/radarsat1/liblo/releases/download/$LIBLO_VERSION/liblo-$LIBLO_VERSION.tar.gz"
LIBLO_SHA256="9acc4f7e5a24f33472e9acd7e409b7bd6810a46f0a1f3cfeecea22d60f3aae13"

CSOUND_COMMIT="${CSOUND_COMMIT:-48a2912307fbb7133b12b22e5685aa1121ece737}"
CSOUND_REPO="https://github.com/csound/csound.git"

CSOUND_PLUGINS_COMMIT="${CSOUND_PLUGINS_COMMIT:-398d785b046e3f5c9c121a2ec28559c330195740}"
CSOUND_PLUGINS_REPO="https://github.com/csound-plugins/csound-plugins"
JSUSFX_COMMIT="${JSUSFX_COMMIT:-bcc9cd7b910ee7bba5b4cd2649448ade2ec15712}"
JSUSFX_REPO="https://github.com/asb2m10/jsusfx"

MANUAL_URL="https://github.com/csound/manual/releases/download/latest/csound7-manual-offline.zip"
MANUAL_SHA256="a1eb732942a651635ae838e142f339cde5c3822e33236ffea7c9afca613e932d"

# --- Qt ---------------------------------------------------------------------
QT_VERSION="${QT_VERSION:-6.11.2}"
QT_ARCH="linux_gcc_64"
QT_INSTALL_PREFIX="${QT_INSTALL_PREFIX:-$WORK_DIR/qt/$QT_VERSION/gcc_64}"
QMAKE="$QT_INSTALL_PREFIX/bin/qmake"

# --- AppImage tooling -------------------------------------------------------
LINUXDEPLOY_VERSION="continuous"
LINUXDEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/$LINUXDEPLOY_VERSION/linuxdeploy-x86_64.AppImage"
LINUXDEPLOY_PLUGIN_QT_URL="https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/$LINUXDEPLOY_VERSION/linuxdeploy-plugin-qt-x86_64.AppImage"
APPIMAGETOOL_URL="https://github.com/AppImage/appimagetool/releases/download/$LINUXDEPLOY_VERSION/appimagetool-x86_64.AppImage"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() { printf '\033[1;32m[appimage]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[appimage] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

git_checkout() { # dir url commit
    local dir="$1" url="$2" commit="$3"
    if [ ! -d "$dir/.git" ]; then
        git clone --quiet "$url" "$dir"
    fi
    git -C "$dir" fetch --quiet --force origin "$commit" 2>/dev/null || true
    git -C "$dir" checkout --quiet --force "$commit"
}

download() { # url dest
    local url="$1" dest="$2"
    if [ ! -f "$dest" ]; then
        log "Downloading $(basename "$dest")"
        curl -L --fail --silent --show-error -C - -o "$dest" "$url"
    fi
}

# ---------------------------------------------------------------------------
# System build dependencies (Debian/Ubuntu)
# ---------------------------------------------------------------------------

# Install a pip package, tolerating PEP 668 externally-managed environments.
pip_user_install() {
    if python3 -m pip install --user --quiet "$@" 2>/dev/null; then
        return 0
    fi
    python3 -m pip install --user --quiet --break-system-packages "$@"
}

install_deps() {
    log "Installing system build dependencies (may require sudo)"
    local pkgs=(
        build-essential cmake ninja-build pkg-config git curl wget unzip file
        ccache desktop-file-utils flex bison
        libasound2-dev libjack-jackd2-dev libportmidi-dev libsndfile1-dev
        libsamplerate0-dev libcurl4-openssl-dev
        libgl1-mesa-dev libglu1-mesa-dev libegl1-mesa-dev
        # xcb/X11 runtime libs needed by libqxcb.so, which linuxdeploy-plugin-qt
        # always bundles. GitHub Actions images ship few of these, so list the
        # whole set to avoid one error per run.
        libxkbcommon-x11-0 libxcb-cursor0 libxcb-icccm4 libxcb-image0
        libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0
        libxcb-shm0 libxcb-sync1 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1
        libxcb1 libx11-xcb1 libx11-6 libxau6 libxdmcp6 libxext6 libxfixes3
        libxi6 libxrender1 libxtst6 libsm6 libice6
        python3 python3-pip
        libnss3
    )
    sudo apt-get update -y
    sudo apt-get install -y "${pkgs[@]}"
    # csound needs cmake >= 3.28; pip provides a newer one that shadows apt's.
    pip_user_install aqtinstall cmake ninja
    export PATH="$HOME/.local/bin:$PATH"
}

# ---------------------------------------------------------------------------
# Qt
# ---------------------------------------------------------------------------

fetch_qt() {
    if [ -x "$QMAKE" ]; then
        log "Using Qt at $QT_INSTALL_PREFIX"
        return 0
    fi
    log "Downloading Qt $QT_VERSION (with WebEngine) via aqtinstall"
    pip_user_install aqtinstall
    export PATH="$HOME/.local/bin:$PATH"
    python3 -m aqt install-qt linux desktop "$QT_VERSION" "$QT_ARCH" \
        -m qtwebengine qtwebchannel qtwebsockets qtpositioning \
        --outputdir "$WORK_DIR/qt"
    [ -x "$QMAKE" ] || die "Qt installation failed: $QMAKE not found"
}

# ---------------------------------------------------------------------------
# liblo (static, as in the Flatpak)
# ---------------------------------------------------------------------------

build_liblo() {
    local tarball="$DOWNLOADS_DIR/liblo-$LIBLO_VERSION.tar.gz"
    local srcdir="$SRC_DIR/liblo-$LIBLO_VERSION"
    download "$LIBLO_URL" "$tarball"
    echo "$LIBLO_SHA256  $tarball" | sha256sum -c --quiet || die "liblo checksum mismatch"
    if [ ! -d "$srcdir" ]; then
        tar -xzf "$tarball" -C "$SRC_DIR"
    fi
    log "Building liblo $LIBLO_VERSION"
    (
        cd "$srcdir"
        ./configure --prefix="$APPDIR/usr" \
            --enable-static --disable-shared \
            --disable-examples --disable-tools --disable-doc \
            CFLAGS="-fPIC -O2"
        make -j"$JOBS"
        make install
    )
}

# ---------------------------------------------------------------------------
# Csound
# ---------------------------------------------------------------------------

build_csound() {
    log "Building csound @ $CSOUND_COMMIT"
    git_checkout "$SRC_DIR/csound" "$CSOUND_REPO" "$CSOUND_COMMIT"
    (
        cd "$SRC_DIR/csound"
        cmake -B build-appimage -S . -G Ninja \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="$APPDIR/usr" \
            -DCMAKE_PREFIX_PATH="$APPDIR/usr" \
            -DCMAKE_INSTALL_LIBDIR=lib \
            -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE_LAUNCHER" \
            -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE_LAUNCHER" \
            -DBUILD_PLUGINS=ON \
            -DUSE_LIBLO=ON \
            -DUSE_ALSA=ON \
            -DUSE_PORTMIDI=ON \
            -DUSE_PORTAUDIO=OFF \
            -DUSE_PULSEAUDIO=OFF \
            -DUSE_PIPEWIRE=OFF \
            -DBUILD_OSC_OPCODES=ON \
            -DUSE_FLTK=OFF \
            -DBUILD_VIRTUAL_KEYBOARD=OFF \
            -DBUILD_JAVA_INTERFACE=OFF \
            -DBUILD_PYTHON_INTERFACE=OFF \
            -DINSTALL_PYTHON_INTERFACE=OFF \
            -DBUILD_LUA_INTERFACE=OFF \
            -DBUILD_CSBEATS=OFF \
            -DBUILD_STATIC_LIBRARY=OFF \
            -DBUILD_TESTS=OFF \
            -DBUILD_INSTALLER=OFF \
            -DBUILD_UTILITIES=OFF \
            -DUSE_JACK=ON
        cmake --build build-appimage --parallel "$JOBS"
        cmake --install build-appimage
    )
}

# ---------------------------------------------------------------------------
# External Csound plugins
# ---------------------------------------------------------------------------

build_csound_plugins() {
    log "Building csound-plugins @ $CSOUND_PLUGINS_COMMIT"
    git_checkout "$SRC_DIR/csound-plugins" "$CSOUND_PLUGINS_REPO" "$CSOUND_PLUGINS_COMMIT"
    git_checkout "$SRC_DIR/csound-plugins/src/jsfx/jsusfx" "$JSUSFX_REPO" "$JSUSFX_COMMIT"
    (
        cd "$SRC_DIR/csound-plugins"
        cmake -B build-appimage -S . -G Ninja \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_PREFIX_PATH="$APPDIR/usr" \
            -DAPIVERSION=7.0 \
            -DPORTABLE=ON \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
            -DCMAKE_C_FLAGS="-I$APPDIR/usr/include/csound" \
            -DCMAKE_CXX_FLAGS="-I$APPDIR/usr/include/csound" \
            -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE_LAUNCHER" \
            -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE_LAUNCHER"
        cmake --build build-appimage --parallel "$JOBS"
        # Plugin libs are written flat into the build dir; install them next
        # to csound's own plugins (mirrors the Flatpak manifest).
        install -Dm755 build-appimage/*.so \
            -t "$APPDIR/usr/lib/csound/plugins64-7.0/"
        install -Dm644 src/jsfx/jsusfx/LICENSE \
            "$APPDIR/usr/share/licenses/CsoundQt/csound-plugins/jsusfx-LICENSE"
    )
}

# ---------------------------------------------------------------------------
# CsoundQt
# ---------------------------------------------------------------------------

build_csoundqt() {
    log "Building CsoundQt from $ROOT"
    local src="$WORK_DIR/csoundqt-src"
    rm -rf "$src" "$WORK_DIR/csoundqt-build"
    mkdir -p "$src"
    # In-source build (like the Flatpak) so the bundled rtmidi submodule is
    # found via the relative src/../$RTMIDI_DIR pattern in src.pri.
    tar -C "$ROOT" --exclude=.git --exclude=.flatpak-builder \
        --exclude=Makefile --exclude=.qmake.stash --exclude='*.pro.user*' \
        --exclude=build --exclude=build-dir --exclude='build-*' \
        --exclude=bin --exclude=aqtinstall.log \
        -cf - . | tar -C "$src" -xf -
    local ccache_args=()
    if [ -n "$CCACHE_LAUNCHER" ]; then
        ccache_args=(QMAKE_CC="$CCACHE_LAUNCHER gcc" QMAKE_CXX="$CCACHE_LAUNCHER g++")
    fi
    (
        cd "$src"
        "$QMAKE" qcs.pro \
            CONFIG+=rtmidi CONFIG+=release CONFIG+=build64 \
            "${ccache_args[@]}" \
            CSOUND_API_INCLUDE_DIR="$APPDIR/usr/include/csound" \
            CSOUND_LIBRARY_DIR="$APPDIR/usr/lib" \
            INSTALL_DIR="$APPDIR/usr" \
            SHARE_DIR="$APPDIR/usr/share"
        make -j"$JOBS"
        make install
    )
}

# ---------------------------------------------------------------------------
# Offline Csound manual
# ---------------------------------------------------------------------------

install_manual() {
    log "Installing offline Csound manual"
    local zip="$DOWNLOADS_DIR/csound7-manual-offline.zip"
    download "$MANUAL_URL" "$zip"
    # echo "$MANUAL_SHA256  $zip" | sha256sum -c --quiet || die "manual checksum mismatch"
    rm -rf "$WORK_DIR/manual-extracted"
    mkdir -p "$WORK_DIR/manual-extracted"
    unzip -q "$zip" -d "$WORK_DIR/manual-extracted"
    mkdir -p "$APPDIR/usr/share/doc/csound-manual/html"
    cp -a "$WORK_DIR/manual-extracted"/csound7-manual-offline/. \
        "$APPDIR/usr/share/doc/csound-manual/html/"
}

# ---------------------------------------------------------------------------
# AppImage assembly (linuxdeploy + Qt plugin)
# ---------------------------------------------------------------------------

download_tools() {
    mkdir -p "$TOOLS_DIR"
    export APPIMAGE_EXTRACT_AND_RUN=1
    download "$LINUXDEPLOY_URL" "$TOOLS_DIR/linuxdeploy-x86_64.AppImage"
    download "$LINUXDEPLOY_PLUGIN_QT_URL" "$TOOLS_DIR/linuxdeploy-plugin-qt-x86_64.AppImage"
    download "$APPIMAGETOOL_URL" "$TOOLS_DIR/appimagetool-x86_64.AppImage"
    chmod +x "$TOOLS_DIR"/*.AppImage
    export PATH="$TOOLS_DIR:$PATH"
}

assemble_appimage() {
    log "Assembling AppImage"

    # Desktop file pointing at the actual binary (linuxdeploy requires this)
    cat > "$APPDIR/io.github.CsoundQt.CsoundQt.desktop" <<EOF
[Desktop Entry]
Name=CsoundQt
Comment=A frontend for Csound
Exec=CsoundQt-d-cs7
Icon=csoundqt
Type=Application
Categories=AudioVideo;Audio;
Keywords=csound;synthesis;music;audio;sound;MIDI;editor
MimeType=text/x-csound-sco;text/x-csound-orc;text/x-csound-csd;text/x-csound-udo;text/x-csound-inc;
EOF

    # Icon (linuxdeploy copies it into the AppDir)
    install -Dm644 "$ROOT/images/csoundqt.png" "$APPDIR/usr/share/icons/hicolor/512x512/apps/csoundqt.png"
    cp "$ROOT/images/csoundqt.png" "$APPDIR/csoundqt.png"

    # Hook to point Csound at the bundled plugins and binaries (mirrors the
    # Flatpak apprun-hooks behaviour). Sourced by the generated AppRun.
    mkdir -p "$APPDIR/apprun-hooks"
    cat > "$APPDIR/apprun-hooks/csound-env.sh" <<'EOF'
export OPCODE7DIR64="${APPDIR}/usr/lib/csound/plugins64-7.0/"
export PATH="${APPDIR}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${APPDIR}/usr/lib:${LD_LIBRARY_PATH:-}"
if [ -x "${APPDIR}/usr/libexec/QtWebEngineProcess" ]; then
    export QTWEBENGINEPROCESS_PATH="${APPDIR}/usr/libexec/QtWebEngineProcess"
elif [ -x "${APPDIR}/usr/lib/QtWebEngineProcess" ]; then
    export QTWEBENGINEPROCESS_PATH="${APPDIR}/usr/lib/QtWebEngineProcess"
fi
export NO_AT_BRIDGE=1
export AT_SPI_BUS_ADDRESS=disabled
# Prefer the Wayland platform plugin, fall back to xcb for X11-only sessions.
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland;xcb}"
# QtWebEngine (Chromium) often cannot initialize GPU/EGL in an AppImage (VM,
# headless, Wayland without DRM, or a bundled Mesa that clashes with the host
# driver). Force software rendering; the manual needs no GPU anyway.
export QTWEBENGINE_CHROMIUM_FLAGS="${QTWEBENGINE_CHROMIUM_FLAGS:---disable-gpu --use-angle=swiftshader}"
export QTWEBENGINE_DISABLE_SANDBOX=1
EOF

    # Chromium/QtWebEngine runtime bits
    mkdir -p "$APPDIR/usr/lib/nss"
    for lib in libsoftokn3.so libfreeblpriv3.so libfreebl3.so; do
        if [ -f "/usr/lib/x86_64-linux-gnu/nss/$lib" ]; then
            cp -a "/usr/lib/x86_64-linux-gnu/nss/$lib" "$APPDIR/usr/lib/nss/"
        fi
    done

    # The Qt Mimer SQL driver depends on the proprietary libmimerapi.so, which
    # linuxdeploy-plugin-qt cannot bundle; drop it so packaging does not fail.
    if [ -f "$QT_INSTALL_PREFIX/plugins/sqldrivers/libqsqlmimer.so" ]; then
        log "Removing Qt Mimer SQL driver (unresolvable dependency libmimerapi.so)"
        rm -f "$QT_INSTALL_PREFIX/plugins/sqldrivers/libqsqlmimer.so"
    fi

    # The QtPositioning NMEA plugin links libQt6SerialPort.so.6 (GPS over
    # serial), a module we do not install; drop it so packaging does not fail.
    if [ -f "$QT_INSTALL_PREFIX/plugins/position/libqtposition_nmea.so" ]; then
        log "Removing Qt Positioning NMEA plugin (unresolvable dependency libQt6SerialPort.so.6)"
        rm -f "$QT_INSTALL_PREFIX/plugins/position/libqtposition_nmea.so"
    fi

    export VERSION="$VERSION"
    export QML_SOURCES_PATHS="$ROOT/src/QML"
    export QMAKE="$QMAKE"
    # Remove stale Qt artifacts copied into the AppDir by a previous run:
    # qmake and linuxdeploy must resolve Qt against the actual
    # $QT_INSTALL_PREFIX, not old copies (which cause symbol lookup errors and
    # "mismatching Qt versions" plugin failures). linuxdeploy-plugin-qt writes
    # into usr/lib, usr/plugins, usr/qml, usr/translations, usr/libexec.
    rm -rf "$APPDIR/usr/lib/libQt6"* \
        "$APPDIR/usr/plugins" "$APPDIR/usr/qml" \
        "$APPDIR/usr/translations" "$APPDIR/usr/libexec" \
        "$APPDIR/usr/resources"
    # Qt install first so qmake/linuxdeploy always resolve Qt libs against the
    # correct Qt version; $APPDIR/usr/lib is where libcsound64 and its deps live
    # (jack, alsa, portmidi...) so linuxdeploy can bundle them transitively.
    export LD_LIBRARY_PATH="$QT_INSTALL_PREFIX/lib:$APPDIR/usr/lib:${LD_LIBRARY_PATH:-}"

    local extra_exec=()

    # Bundle a host library into the AppDir (resolving symlinks), unless it is
    # already present. Used for Wayland runtime deps linuxdeploy won't pull in.
    bundle_host_lib() { # soname
        local soname="$1"
        [ -e "$APPDIR/usr/lib/$soname" ] && return 0
        local lib
        lib="$(ldconfig -p 2>/dev/null | awk -v s="$soname" '$1==s {print $NF; exit}')"
        [ -n "$lib" ] || lib="/usr/lib/x86_64-linux-gnu/$soname"
        if [ -e "$lib" ]; then
            log "Bundling $soname from $lib"
            cp -aL "$lib" "$APPDIR/usr/lib/$soname"
        else
            log "WARNING: $soname not found; Wayland plugin may fail to load"
        fi
    }

    linuxdeploy-x86_64.AppImage --appdir "$APPDIR" \
        --executable "$APPDIR/usr/bin/CsoundQt-d-cs7" \
        --executable "$APPDIR/usr/bin/csound" \
        "${extra_exec[@]}" \
        --desktop-file "$APPDIR/io.github.CsoundQt.CsoundQt.desktop" \
        --icon-file "$APPDIR/csoundqt.png" \
        --plugin qt

    # linuxdeploy-plugin-qt only bundles the xcb platform plugin. Explicitly
    # add the Wayland platform plugin, its shell-integration and client-buffer
    # integration plugins, plus libQt6WaylandClient and host runtime deps, so
    # the app also runs on Wayland sessions (incl. EGL/OpenGL rendering).
    # (Copied after linuxdeploy so nothing gets pruned.)
    if [ -f "$QT_INSTALL_PREFIX/plugins/platforms/libqwayland.so" ]; then
        log "Bundling Qt Wayland platform + integration plugins"
        install -Dm755 "$QT_INSTALL_PREFIX/plugins/platforms/libqwayland.so" \
            "$APPDIR/usr/plugins/platforms/libqwayland.so"
        install -Dm755 "$QT_INSTALL_PREFIX"/plugins/wayland-shell-integration/*.so \
            -t "$APPDIR/usr/plugins/wayland-shell-integration/"
        install -Dm755 "$QT_INSTALL_PREFIX"/plugins/wayland-graphics-integration-client/*.so \
            -t "$APPDIR/usr/plugins/wayland-graphics-integration-client/"

        # libQt6WaylandClient must be the bundled Qt version, not the host's.
        install -Dm755 "$QT_INSTALL_PREFIX/lib/libQt6WaylandClient.so.6.11.2" \
            "$APPDIR/usr/lib/libQt6WaylandClient.so.6.11.2"
        ln -sf libQt6WaylandClient.so.6.11.2 \
            "$APPDIR/usr/lib/libQt6WaylandClient.so.6"

        # Host runtime deps of the Wayland stack.
        bundle_host_lib "libwayland-client.so.0"
        bundle_host_lib "libwayland-cursor.so.0"
        bundle_host_lib "libwayland-egl.so.1"
        bundle_host_lib "libxkbcommon.so.0"
        bundle_host_lib "libffi.so.8"
        bundle_host_lib "libEGL.so.1"
        bundle_host_lib "libGL.so.1"
        bundle_host_lib "libgbm.so.1"
    fi

    log "Creating final AppImage"
    export ARCH="x86_64"
    (
        cd "$WORK_DIR"
        appimagetool-x86_64.AppImage "$APPDIR"
        local produced
        produced="$(ls -1t *.AppImage 2>/dev/null | head -1 || true)"
        [ -n "$produced" ] || die "appimagetool produced no AppImage"
        if [ "$produced" != "CsoundQt-${VERSION}-x86_64.AppImage" ]; then
            mv -v "$produced" "CsoundQt-${VERSION}-x86_64.AppImage"
        fi
    )
}

# ---------------------------------------------------------------------------

main() {
    for arg in "$@"; do
        case "$arg" in
            --install-deps) INSTALL_DEPS=1 ;;
            *) die "unknown argument: $arg" ;;
        esac
    done

    if [ "${INSTALL_DEPS:-0}" = "1" ]; then
        install_deps
    fi

    command -v cmake >/dev/null || die "cmake not found (run with --install-deps)"
    command -v ninja  >/dev/null || die "ninja not found (run with --install-deps)"

    # ccache speeds up rebuilds; used by all three compilers below. Disabled
    # gracefully when ccache is not installed.
    if command -v ccache >/dev/null 2>&1; then
        CCACHE_LAUNCHER="$(command -v ccache)"
        export CCACHE_DIR="$WORK_DIR/.ccache"
        export CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-4G}"
        log "ccache enabled ($CCACHE_DIR)"
    else
        CCACHE_LAUNCHER=""
        log "ccache not found; skipping compiler cache"
    fi

    mkdir -p "$DOWNLOADS_DIR" "$SRC_DIR" "$APPDIR/usr"

    fetch_qt
    build_liblo
    build_csound
    build_csound_plugins
    build_csoundqt
    install_manual
    download_tools
    assemble_appimage

    log "Done: $WORK_DIR/CsoundQt-${VERSION}-x86_64.AppImage"
}

main "$@"
