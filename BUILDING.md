# Build instructions for CsoundQt

- [Getting the sources](#getting-the-sources)
- [Requirements](#requirements)
- [Building with qmake](#building-with-qmake)
- [Build options](#build-options)
- [Installing](#installing)
- [CMake (experimental)](#cmake-experimental)
- [Notes for Linux](#notes-for-linux)
- [Notes for macOS](#notes-for-macos)
- [Notes for Windows](#notes-for-windows)

Please help improving these instructions and report any issue to
<https://github.com/CsoundQt/CsoundQt/issues>. Thanks!

> **Note:** These instructions are for the `csoundqt7` branch (CsoundQt 7),
> which requires **Csound 7** and **Qt 6**. For CsoundQt 1.x (Csound 6,
> Qt 5), see the `develop` branch.

## Getting the sources

The source files for CsoundQt can be browsed and downloaded from GitHub:
<https://github.com/CsoundQt/CsoundQt>. Source releases are in the
[Releases section](https://github.com/CsoundQt/CsoundQt/releases).

Clone the repository and check out the `csoundqt7` branch:

    $ git clone https://github.com/CsoundQt/CsoundQt.git
    $ cd CsoundQt
    $ git checkout csoundqt7

If you want RtMidi support (recommended), also pull the `rtmidi` submodule:

    $ git submodule update --init --recursive

## Requirements

- **Csound 7** — must be installed before building. On macOS and Windows you
  can use the prebuilt installers from <https://csound.com/download.html>;
  on Linux it is often preferable to build it yourself, see
  <https://github.com/csound/csound/blob/develop/BUILD.md>.
- **Qt 6** (tested with Qt 6.5) — with the modules `widgets`, `concurrent`,
  `network`, `printsupport`, `quickwidgets`, `quickcontrols2` and, for HTML
  support, `webenginewidgets` and `webchannel`. You can use the Qt
  installation from your system's package manager or the Qt online installer
  from <https://www.qt.io/download-open-source/>.
- **RtMidi** (optional, recommended) — improves MIDI I/O stability and
  allows associating widgets with MIDI controllers. The sources are included
  as a git submodule (`rtmidi/`); on Linux a system-installed RtMidi is
  used if found.
- **libsndfile** (optional) — allows recording the realtime output of
  Csound to a file.

PythonQt support was **removed** in CsoundQt 7 and is no longer a build
option.

## Building with qmake

The easiest way to build CsoundQt is to open `qcs.pro` in **Qt Creator**
and build it there. On the command line:

    $ qmake6 qcs.pro   # or just qmake, if it points to Qt 6
    $ make

The qmake project files search for the Csound headers and library in
standard locations:

- Linux: `/usr/local/include/csound`, `/usr/include/csound`,
  `/usr/local/lib`, `/usr/lib`
- macOS: `/Applications/Csound/CsoundLib64.framework` (from the Csound
  installer), Homebrew locations, `~/Library/Frameworks`

If your Csound installation is elsewhere, pass the paths on the qmake
command line:

    $ qmake6 qcs.pro "CSOUND_INCLUDE_DIR = <path to csound.h>" "CSOUND_LIBRARY_DIR = <path to libcsound64>"

or create a file named `config.user.pri` in the source root (here assuming csound is installed in 
at the ``~/.local`` prefix):

```
CSOUND_INCLUDE_DIR = ~/.local/include/csound
CSOUND_LIBRARY_DIR = ~/.local/lib
```

If you built Csound from source without installing it, you can instead set
`CSOUND_SOURCE_TREE` to the Csound source directory.

The executable is written to `bin/` and named `CsoundQt-d-cs7`
(`-debug` suffix for debug builds).

## Build options

Pass these to qmake as `CONFIG+=...`:

- `CONFIG+=rtmidi` — build with RtMidi support (requires the submodule or
  a system RtMidi on Linux)
- `CONFIG+=html_support` — support for the `<html>` element in csd files
  via Qt WebEngine
- `CONFIG+=record_support` — recording support (enabled via
  `perfThread_build` when available)
- `CONFIG+=debugger` — build the Csound debugger

Example:

    $ qmake6 qcs.pro CONFIG+=rtmidi CONFIG+=html_support

See the header comments of `qcs.pro` for the full list of variables and
options.

## Installing

On Linux you can install CsoundQt system-wide with:

    $ sudo make install

This installs the executable, a `csoundqt` symlink, desktop file, icons,
MIME types, examples and templates. The default prefix is `/usr/local`;
override with `INSTALL_DIR` and `SHARE_DIR`, e.g. for a user-local install:

    $ qmake6 qcs.pro INSTALL_DIR=~ SHARE_DIR=~/.local/share
    $ make install

On macOS, `make install` runs `macdeployqt` and produces a self-contained
`CsoundQt-d-cs7.app` bundle. The bundle does **not** include Csound by
default — Csound 7 must be installed separately. Use `CONFIG+=bundle_csound`
to include the `CsoundLib64.framework` in the bundle.

## CMake (experimental)

A `CMakeLists.txt` exists, but CMake support is **in progress and not yet
ready** — it currently only supports Linux and lags behind the qmake build.
Use qmake unless you want to help developing the CMake build.

## Notes for Linux

Using the Qt 6 development packages from your distribution is recommended.
On Debian/Ubuntu, for example:

    $ sudo apt install qt6-base-dev qt6-declarative-dev qt6-webengine-dev \
        qt6-tools-dev libasound2-dev libjack-dev

If qmake reports "Unknown module(s) in QT: ...", install the corresponding
Qt 6 `-dev` package with your package manager.

With RtMidi support, CsoundQt uses ALSA (and JACK if `libjack` is found),
so the ALSA development headers (`libasound2-dev` on Debian/Ubuntu) are
required.


### Outdated: 

CsoundQt looks for the **Csound manual** in
`/usr/share/doc/csound-manual/html/` and `/usr/share/doc/csound-doc/html/`.
If you installed the manual via a package manager it should be there.
Otherwise use *Download Csound Manual* in the *Help* menu and set the path
in *Configure -> Environment*.

## Notes for macOS

The default paths in `qcs-macx.pro` are set up for **Csound 7 from the
macOS installer** (`/Applications/Csound/CsoundLib64.framework`); Homebrew
installations are searched as a fallback. The build targets `arm64` by
default (see `QMAKE_APPLE_DEVICE_ARCHS` in `qcs-macx.pro`).

If the menu is missing the **Scripts** item on first start, set the
*Python Script directory* in *Configure > Environment* to the
`src/Scripts` directory of your CsoundQt sources, then restart CsoundQt.

## Notes for Windows

See [Building_on_Windows.md](Building_on_Windows.md). Note that this
document has not yet been fully updated for CsoundQt 7 / Qt 6 — it still
refers to Qt 5 and Csound 6 in places, but the general workflow (MSVC,
`config.user.pri`, `windeployqt`) applies. Help updating it is welcome.
