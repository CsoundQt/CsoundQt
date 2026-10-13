# Build instructions for CsoundQt

These instructions build the **`csoundqt7`** branch (CsoundQt 7), which requires
**Csound 7** and **Qt 6**. Report problems at
<https://github.com/CsoundQt/CsoundQt/issues>.

# Windows

## Prerequisites

1. **Csound 7** — download from <https://csound.com/download.html> and run the
   installer. Keep the default location (`C:\Program Files\Csound7`); the
   commands below assume it.
2. **Qt 6** — download the Qt online installer from
   <https://www.qt.io/download-open-source/> and run it (a free Qt account is
   required). Under the latest **Qt 6.7 or newer** select `MSVC 2022 64-bit`,
   and also select **Qt Creator**. Default install path:
   `C:\Qt\6.8.3\msvc2022_64`; replace `6.8.3` below with the installed version.
3. **Visual Studio 2022** — install *Visual Studio Community 2022*
   (<https://visualstudio.microsoft.com/vs/community/>) with the *Desktop
   development with C++* workload. This provides the compiler and the terminal
   used below.
4. **Git** — <https://git-scm.com/download/win>, default options.

## Build from a terminal

Open Start menu → **Developer PowerShell for VS 2022** (this has the compiler on
`PATH`; a plain PowerShell does not), then run:

```powershell
$env:Path = "C:\Qt\6.8.3\msvc2022_64\bin;$env:Path"

git clone --recursive -b csoundqt7 https://github.com/CsoundQt/CsoundQt.git
cd CsoundQt

qmake qcs.pro CONFIG+=rtmidi CONFIG+=release `
    "CSOUND_API_INCLUDE_DIR=C:/Program Files/Csound7/include/csound" `
    "CSOUND_INTERFACES_INCLUDE_DIR=C:/Program Files/Csound7/include/csound" `
    "CSOUND_LIBRARY_DIR=C:/Program Files/Csound7/lib"
nmake

Copy-Item "C:\Program Files\Csound7\bin\csound64.dll" bin\
Copy-Item "C:\Program Files\Csound7\plugins64" bin\plugins64 -Recurse
windeployqt --qmldir src\QML bin\CsoundQt-d-cs7.exe

.\bin\CsoundQt-d-cs7.exe
```

To rebuild after editing code, run the build and run commands again from the
`CsoundQt` directory.

## Build with Qt Creator

1. Open Qt Creator.
2. **File ▸ Open File or Project…** → select `qcs.pro` → **Open**.
3. Tick the `MSVC2022 64bit` kit → **Configure Project**.
4. Create `config.user.pri` in the `CsoundQt` folder containing:
   ```
   CSOUND_API_INCLUDE_DIR = C:/Program Files/Csound7/include/csound
   CSOUND_INTERFACES_INCLUDE_DIR = C:/Program Files/Csound7/include/csound
   CSOUND_LIBRARY_DIR = C:/Program Files/Csound7/lib
   ```
   Then **Build ▸ Run qmake**.
5. Run (Ctrl+R).
6. Before the first run, copy `csound64.dll` from `C:\Program Files\Csound7\bin`
   into the `bin` directory listed under **Projects ▸ Build Settings**.

## Notes

- `qcs.pro` calls `windeployqt6`, which Qt does not ship; run `windeployqt`
  manually (as above) or create a `windeployqt6.exe` alias.
- To build from a shell other than the Developer PowerShell, MSVC's `link.exe`
  must come before Git Bash's; otherwise linking fails.
- Installer: `installers\Windows\csoundqt7-x64.iss` (Inno Setup), driven by
  `CSOUNDQT_VERSION`, `CSOUNDQT_APPNAME` and `CSOUNDQT_STAGING_DIR`.

# macOS

## Prerequisites

1. **Csound 7** — download from <https://csound.com/download.html> and run the
   installer. It installs `/Applications/Csound/CsoundLib64.framework`, which
   the build finds automatically.
2. **Qt 6** — download the Qt online installer from
   <https://www.qt.io/download-open-source/> and run it (a free Qt account is
   required). Under **Qt 6.10 or newer** (required with Xcode 26; 6.7 is the
   minimum) select `macOS`, and also select **Qt Creator**. Default install
   path: `~/Qt/6.8.3/macos`; replace `6.8.3` below with the installed version.
3. **Command-line tools** — run `xcode-select --install`. This provides clang,
   `make` and Git.

## Build from a terminal

```bash
export PATH="$HOME/Qt/6.8.3/macos/bin:$PATH"

git clone --recursive -b csoundqt7 https://github.com/CsoundQt/CsoundQt.git
cd CsoundQt

qmake qcs.pro CONFIG+=rtmidi CONFIG+=release
make -j$(sysctl -n hw.logicalcpu)

open bin/CsoundQt-d-cs7.app
```

To rebuild after editing code, run the build and run commands again from the
`CsoundQt` directory.

## Build with Qt Creator

1. Open Qt Creator.
2. **File ▸ Open File or Project…** → select `qcs.pro` → **Open**.
3. Tick the `macOS` kit → **Configure Project**.
4. Run (Cmd+R).

## Notes

- `qcs-macx.pro` sets `QMAKE_APPLE_DEVICE_ARCHS = arm64`. Edit that line for
  `x86_64` or a universal binary.
- To use a Csound in a non-default location, set
  `CSOUND_LIBRARY_DIR=/path/CsoundLib64.framework/Versions/Current` and
  `CSOUND_INCLUDE_DIR=/path/CsoundLib64.framework/Versions/Current/Headers`.
- `make install` runs `macdeployqt` for a self-contained `.app`;
  `CONFIG+=bundle_csound` embeds `CsoundLib64.framework`. Put the offline
  [manual](https://github.com/csound/manual/releases/download/latest/csound7-manual-offline.zip)
  in `Contents/Resources/Manual`. Verify with
  `installers/MacOS/test-app-bundle.sh`; sign and notarise with
  `installers/MacOS/sign-and-notarize.sh`.

# Linux

CsoundQt needs a recent version of csound 7. Build/installation instructions for that are
out of scope here.

Install the Qt 6 development packages (Debian/Ubuntu shown), then build and
install:

```bash
sudo apt-get install build-essential git qt6-base-dev qt6-declarative-dev
# add qt6-webengine-dev for CONFIG+=html_support

git clone --recursive -b csoundqt7 https://github.com/CsoundQt/CsoundQt.git
cd CsoundQt

qmake6 qcs.pro CONFIG+=rtmidi CONFIG+=release
make -j$(nproc)
./bin/CsoundQt-d-cs7

sudo make install          # optional, installs under /usr/local
```

Notes:

- At the moment of this writing, distro packages of Csound are Csound 6; 
  build Csound 7 from source (<https://github.com/csound/csound/blob/develop/BUILD.md>).
- For a user-local install:
  `qmake6 qcs.pro INSTALL_DIR=~ SHARE_DIR=~/.local/share && make install`.
- To use a Csound build tree that is not installed, set `CSOUND_SOURCE_TREE` to
  the Csound source directory.

# Reference

## Build options

Pass as `CONFIG+=...`:

- `rtmidi` — MIDI support (recommended)
- `html_support` — `<html>` GUI element via Qt WebEngine
- `record_support` — recording support (usually enabled automatically)
- `debugger` — Csound debugger
- `no_splash` — no splash screen
- `release` — optimised build

## Pointing at a custom Csound

Csound is searched in default locations (`/usr/local`, `/usr` on Linux;
`/Applications/Csound/CsoundLib64.framework` and Homebrew on macOS). To use
another location, set any of these on the qmake command line or in
`config.user.pri` in the source root:

- `CSOUND_INCLUDE_DIR` — directory with `csound.h`
- `CSOUND_INTERFACES_INCLUDE_DIR` — directory with `csound.hpp`
- `CSOUND_LIBRARY_DIR` — directory with the Csound library

```
# config.user.pri (example: ~/.local prefix)
CSOUND_INCLUDE_DIR = ~/.local/include/csound
CSOUND_INTERFACES_INCLUDE_DIR = ~/.local/include/csound
CSOUND_LIBRARY_DIR = ~/.local/lib
```

Build the **`csoundqt7`** branch:

    $ git clone --recursive -b csoundqt7 https://github.com/CsoundQt/CsoundQt.git

`--recursive` fetches the required submodules `litehtml` (manual viewer) and
`rtmidi` (MIDI).

