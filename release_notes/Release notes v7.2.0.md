# CsoundQt 7.2.0 Release Notes

**CsoundQt 7.2.0** adds a completely new **waveform widget**, a **flat,
fully themeable button style**, **widget property messages from Csound**
(`outvalue "<channel>/<property>"`, which also makes widget animation possible),
a new inline **find bar**, and a new **runtime query** mechanism that lets
CsoundQt evaluate Csound code on the running performance thread and receive the
result. It also brings a round of performance work and packaging/CI improvements.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.2.0>.

## What's new

**Waveform widget** a new widget that draws the samples of a Csound f-table directly.
* Table number sent to its channel; cursor position read/written through a
  second channel and moved by clicking. The view follows the cursor when it
  moves out of view.
* multichannel tables are drawn one lane per channel, sharing the time axis
* Wheel zooms, Shift+wheel scrolls, Ctrl+drag pans. Persistence: the table is
  copied before the Csound instance is destroyed, so the waveform remains
  visible after the performance stops.
* Example: `C Widgets/Waveform_Widget.csd` (stereo soundfile, cursor sync, a
  looping `loscilx` player with a speed knob and a play/stop button).

**Flat button style** — buttons can now opt into a flat style that bypasses the
native widget:
* Fully configurable: background colour, background colour when pushed, border
  colour, text colour, text colour when pushed, border width and border radius.
  Pushed colours default to the normal colours when unset.
* Identical across platforms: the flat button is rendered by CsoundQt itself,
  so it looks exactly the same across all platforms

**Widget messages via `outvalue`** — any widget property can be changed from
Csound:
* `outvalue "<channel>/<property>", value`. The exact list is available through
  the new **"Show Properties"** button in a widget's Properties dialog.
* Numeric and string properties (position, size, visibility, colour, text, …)
  are supported; a property message never changes the widget's current value, so
  a widget can be animated while it keeps controlling its Csound channel.
* Widgets can now also be given a **unique name**, independent of their channel.
* Example: `C Widgets/Widget_Animation.csd`.

**New find bar** — the find/replace dialog is replaced by an inline floating
panel: incremental matching, automatic wrap-around, highlighting of all matches,
and jumping between matches.

**Internal: Querying Csound at runtime** — CsoundQt can evaluate Csound code on
the running performance thread and receive the result through a callback (Csound
7's `csoundPerformanceThreadEvalCodeWithData`). First use: the waveform's
automatic detection of table channel count and sample rate. Needs a recent
Csound 7 build.

## Improvements and fixes
* **Performance**: faster document loading; optimised widget refresh and graph
  rendering hot paths; FFT graphs decimate to the actual pixel resolution (large
  FFTs are as cheap to draw as small ones); optimised knob painting (and fixed
  its range handling); no re-highlighting when the syntax theme is unchanged;
  faster widget-editor selection and fixed multi-widget movement.
* **Controller widget**: fixed widgets sharing the same name on both channels,
  removed duplicated code and improved mouse handling.
* **Editor**: fixed insertion of non-ASCII text through the autocomplete menu.
* **Instant Startup**: startup time has been drastically reduced. The manual is
  loaded lazily when the help panel is first shown; risset detection was deferred
  and initialisation moved to the background.
* **Build option**: the splash screen is now optional.

## Packaging, platforms and CI
* **Linux**: self-contained **AppImage** (bundled Qt, Csound, manual and
  plugins), built by `installers/Linux/build-appimage.sh`.
* **Windows**: Inno Setup installer (`installers/Windows/csoundqt7-x64.iss`)
  with stable asset naming.
* **macOS**: `.dmg` builds with improved signing/notarisation and a bundle test
  script; universal builds.
* **Flatpak**: available via Flathub.
* **CI**: unified versioning, development prerelease handling, test builds, and
  cache keys that include the runner OS version.
* Coming from **7.0.0**? This release also includes everything from 7.0.1/7.0.2:
  the litehtml help viewer, whole-manual search, AppImage/Flatpak packaging and
  the channel-handling performance work.
