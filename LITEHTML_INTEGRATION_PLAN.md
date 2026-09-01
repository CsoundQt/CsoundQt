# Plan: Replace QtWebEngine documentation rendering with litehtml in CsoundQt

Status: **In progress — Phases 0–6 implemented; Phase 7 (verification) partially done**
Last updated: 2026-09-01

## Progress log

- **Phase 0 done**: litehtml submodule added at `third_party/litehtml`, pinned to
  `c287df65` (v0.10). Committed (`ddf8fc0f`).
- **Phase 1 done**: `src/litehtmlcontainer.{h,cpp}`, `src/litehtmlview.{h,cpp}`,
  `src/searchindex.{h,cpp}` ported from the spike, with history/zoom/status-signal
  additions and demo coupling removed. Compile-checked.
- **Phase 2 done**: `DockHelp` rewritten to host `LiteHtmlView`; public API kept;
  `dockhelp.ui` toolbar + find bar wired (whole-word enabled); viewer signals
  forwarded to the host; `searchToolButton` added.
- **Phase 3 done**: whole-manual search — roots registered in
  `CsoundQt::setupHelpPanel` (`docDir` + `risset->rissetHtmlDocs`), lazy load,
  two-tier exact/prefix, in-dock panel, deep-link to anchors.
- **Phase 4 done**: `qcs.pro` default build has **no WebEngine**; `src.pri`
  includes the new files + `litehtml.pri`; CMake updated (C++17, WebEngine
  optional, litehtml subdir). **qmake default build verified**: compiles, links,
  `ldd` shows no WebEngine/WebChannel; app starts.
  - *CMake caveat (pre-existing):* the top-of-file Qt version gate rejects Qt6
    (`message(FATAL_ERROR "Only Qt5 is currently supported")`), so a full CMake
    build cannot run here. The litehtml/WebEngine edits are correct for when that
    gate is fixed.
  - *html_support build:* unchanged code path (same `webenginewidgets` in the
    html_support block); not locally verifiable because the Debian Qt package
    ships no qmake webengine mkspecs — covered by the new CI job.
- **Phase 6 done**: about-dialog text reworded (and the dead `CSQT_QHTML` typo
  guard fixed to `CSQT_QTHTML`).
- **Phase 5 done (manifest + CI)**: flatpak no longer uses the qtwebengine base /
  `QTWEBENGINEPROCESS_PATH`; `testbuild-qt6.yml` default jobs drop WebEngine and a
  new `buildjob-htmlsupport-linux` job keeps the HTML5 GUI compile-tested.
- **Phase 7 partial**: build + no-WebEngine-link + startup verified. Manual
  interaction (find/selection/zoom/search across roots, `.csd`/external links,
  resizing) validated in the spike against the same index files; a final manual
  pass in the GUI is recommended before release.

## Remaining / notes

- Full CMake build blocked by the pre-existing Qt6 gate (out of scope here).
- Flatpak manifest `commit:` is a release commit and was left unchanged; it must
  be bumped when these changes are pushed.
- Ported selection is run-granularity (not character-precise), a known trade-off.


## 1. Goal

Drop the QtWebEngine dependency for the embedded documentation viewer and replace
it with **litehtml** (a small, pure-C++, in-process HTML/CSS renderer), plus an
offline **whole-manual search** over multiple manual roots (built-in Csound manual
and Risset plugin manuals), reusing the `search/search_index.json` files that the
MkDocs-based manuals already ship.

The interactive **HTML5 GUI** feature (`<html>` elements in CSDs, `CsoundHtmlView`)
requires a real JS engine and stays on QtWebEngine, but only behind the existing
optional `html_support` build flag. A default build will have **zero** WebEngine
dependency.

## 2. What was validated in the spike (`/tmp/opencode/qtlite`)

A working prototype (`liteviewer` + `qt_container` + `search_index`) proved:

- litehtml renders the real MkDocs Material manual well: CSS variables, grouped
  selectors, Pygments syntax highlighting, code backgrounds, local images,
  `:checked` tab handling (after the two preprocessing steps below).
- Two required HTML preprocessing steps in the viewer's `loadFile`:
  1. **Extract `<article class="md-content__inner">`** — the raw page with the
     left nav sidebar reliably hangs litehtml's `render()`.
  2. **Flatten `tabbed-set`** — the "Modern"/"Classic" tabs rely on `:nth-child`
     combinators litehtml can't match; convert to stacked `<h3>label</h3> + block`.
- Viewer features implemented and verified: culled painting (fast scroll),
  kinetic/inertia scrolling, text selection (run-granularity) + Ctrl+C / Ctrl+A,
  in-page find (Ctrl+F) with next/prev, anchor deep-linking, host link signals,
  and multi-root whole-manual search.
- Whole-manual search: parses `search/search_index.json` (config + docs), builds a
  per-root presence inverted index (~0.7 s for both real indexes, one-time lazy),
  searches all roots in parallel, merges by score with source labels, resolves
  results to `root + location` and scrolls to the `#fragment`.
  - **Two-tier query**: exact matches on each keystroke; pressing **Enter** adds
    prefix matches ("perli" → perlin) at reduced weight.
- litehtml builds as two static libs: `litehtml` (C++) + `gumbo` (C, bundled
  HTML parser). Headers require **C++17**.

## 3. Target architecture

### New files in `src/`

| File | Purpose | Source (spike) |
|---|---|---|
| `src/litehtmlview.h/.cpp` | The document viewer `QWidget`: rendering, scroll+inertia, selection, in-page find, history, zoom, link signals, anchor scroll | `liteviewer.cpp` `LiteView` (adapted) |
| `src/litehtmlcontainer.h/.cpp` | litehtml `document_container` drawing via `QPainter`, records text fragments for selection/search | `qt_container.h/.cpp` |
| `src/searchindex.h/.cpp` | Multi-root `SearchIndexManager`: lazy load, inverted index, parallel search, prefix mode, `resolvePath` | `search_index.h/.cpp` |

### Rewritten

| File | Change |
|---|---|
| `src/dockhelp.h/.cpp` | Host the `LiteView` widget instead of `QWebEngineView`/`HelpPage`; keep the public API used by `csoundqt.cpp`; keep `dockhelp.ui` toolbar + find bar |
| `qcs.pro`, `CMakeLists.txt`, `src/src.pri` | Build the new files + litehtml; drop `webenginewidgets` from the default build |
| `flatpak/io.github.CsoundQt.CsoundQt.yml` | Add a litehtml module; drop the `io.qt.qtwebengine.BaseApp` base and `QTWEBENGINEPROCESS_PATH` (for the non-HTML build) |
| `.github/workflows/testbuild-qt6.yml` | Build/vendor litehtml; remove `qtwebengine` from the default job (keep for an html_support job if wanted) |

### Vendored dependency

Add **litehtml as a git submodule** at `third_party/litehtml` (matches the existing
`rtmidi` submodule pattern), pinned to the version the spike was built against.
Bundled `gumbo` is compiled as part of litehtml's build.

## 4. Phased steps (ordered; each phase is independently verifiable)

### Phase 0 — Vendor litehtml

1. `git submodule add https://github.com/litehtml/litehtml.git third_party/litehtml`.
2. Verify the pinned revision builds the same as the spike (`/tmp/opencode/litehtml`).
3. Commit the submodule pointer + `.gitmodules` entry.

### Phase 1 — Port the viewer sources into `src/`

Adapt the spike code to repo conventions (project naming style, no demo `main()`):

1. `src/litehtmlcontainer.{h,cpp}` — port as-is; rename types (`QtContainer` →
   `LiteHtmlContainer`, `QtFontData` → internal struct).
2. `src/litehtmlview.{h,cpp}` — port `LiteView` with these adaptations:
   - Remove the demo `MainWindow`/`main()` coupling; replace `emitLinkMessage`
     (which reached for a `QMainWindow`) with a `statusMessage(QString)` signal.
   - **Add browser-style history** (back/forward stack) — needed by
     `DockHelp::browseBack/browseForward` (not in the spike demo).
   - **Add zoom** (`zoomIn/zoomOut`, re-render at new default font size) — needed
     by `DockHelp::changeFontSize`.
   - Keep the two preprocessing steps (`extractArticle` + `flattenTabs`), fragment
     capture on layout invalidation, selection/find/anchor-scroll/link signals.
   - Expose: `loadFile(path, fragment)`, `back/forward`, `hasFocus`, `focusText`,
     `findBar` (in-page), `setSearchManagerRoots(...)`, `scrollToAnchor`.
   - Signals: `externalLinkRequested(QUrl)`, `exampleFileRequested(QString)`,
     `statusMessage(QString)`.
3. `src/searchindex.{h,cpp}` — port as-is (`SearchIndexManager`).
4. Wire a small self-test (optional, like the spike's headless tests) or rely on
   Phase 7 manual tests.

### Phase 2 — Rewrite `DockHelp`

Keep the public API used by `csoundqt.cpp` (verified callers: lines 123, 201, 425,
488, 691, 783, 817, 832, 1073, 1250, 1272, 1537, 1841, 2606, 2659, 2687, 3015,
3052, 3534, 4404–4461, 4641, 4646):

- `loadFile(fileName, anchor)` → `m_view->loadFile(fileName, anchor)`; "Not found"
  path renders the message in the viewer.
- `browseBack/browseForward` → viewer history.
- `showManual/showGen/showOverview/showOpcodeQuickRef` → load the corresponding
  file in the viewer. *(Pre-existing issue: these target `ScoreGenRef.html`,
  `PartOpcodesOverview.html`, `MiscQuickref.html`, which don't exist in the current
  MkDocs manual — decide whether to remap targets in this phase.)*
- `copy()` → viewer copy selection.
- `changeFontSize(±)` → viewer zoom.
- `setIconTheme` — unchanged (toolbar icons).
- `hasFocus/focusText` → forward to the viewer.
- `toggleFindBarVisible(show)` → show the viewer's in-page find box.
- Signals: connect `LiteView::externalLinkRequested` → `requestExternalBrowser`;
  `LiteView::exampleFileRequested` → `openManualExample`; `LiteView::statusMessage`
  → main-window status bar (or keep a dock label).
- Keep `dockhelp.ui` toolbar (back/forward/home/find-toggle) and the find bar
  (`findLine`, `caseBox`, `wholeWordBox`, next/prev). Wire to the viewer's find.
  **Enable `wholeWordBox`** (was disabled under WebEngine).
- Remove `HelpPage`, `QWebEngineView/QWebEnginePage/QWebEngineSettings` includes.

### Phase 3 — Whole-manual search in `DockHelp`

1. Add `SearchIndexManager` and a search panel UI to `DockHelp`:
   - A "Search manual" tool button + a `QLineEdit` + `QListWidget` panel (or a
     compact popup anchored to the toolbar).
   - Two-tier behavior: exact on each keystroke; prefix matches on Enter.
   - Results rows: `title [source]`, tooltip = snippet + location.
2. Root discovery (lazy, once per session, no refresh until restart):
   - **Built-in:** `docDir` (the manual root already resolved in
     `CsoundQt::setupHelpPanel`), only if `docDir + "/search/search_index.json"`
     exists.
   - **Risset:** `risset->rissetHtmlDocs` (already parsed from `risset info`
     `htmldocs` in `Risset::initIndex`), only if its `search_index.json` exists
     and `risset->isInstalled`.
3. Result activation → `m_view->loadFile(resolvePath)` + `scrollToAnchor(fragment)`.

### Phase 4 — Build system

**qmake (`qcs.pro`, `src/src.pri`, new `third_party/litehtml/litehtml.pri`):**
- New `litehtml.pri` lists all litehtml + gumbo sources, includes, and `-fPIC`
  as needed; include it from `src/src.pri` (like the `rtmidi` block).
- `qcs.pro`: remove `webenginewidgets` from the unconditional `QT +=` (line 61).
  Leave the `html_support` block (110–115) adding `webenginewidgets webchannel`
  and `CSQT_QTHTML` unchanged (that is the HTML5-GUI-only build).
- Add the new `src/litehtmlview.cpp`, `src/litehtmlcontainer.cpp`,
  `src/searchindex.cpp` to `src.pri` (always built).

**CMake (`CMakeLists.txt`):**
- Bump `CMAKE_CXX_STANDARD` from 11 to **17** (litehtml headers require it).
- Remove `WebEngineWidgets` from the unconditional `find_package` (lines 46–47)
  and `target_link_libraries` (line 92); keep them inside
  `CSQT_BUILD_HTML_SUPPORT` (lines 139–140).
- `add_subdirectory(third_party/litehtml)`; link `litehtml` and `gumbo`
  (bundled, `EXTERNAL_GUMBO` stays OFF).
- Add the three new `.cpp` files to `PROJECT_SOURCES`.
- Add a CMake option (e.g. `CSQT_BUILD_HTML_SUPPORT`) already exists; keep.

### Phase 5 — Packaging

- **Flatpak:** add a `litehtml` module (cmake-ninja, install lib + headers) before
  CsoundQt; remove `base: io.qt.qtwebengine.BaseApp` and the
  `QTWEBENGINEPROCESS_PATH` env from `finish-args`; CsoundQt qmake build links
  litehtml from `/app`.
- **AppImage/CI (`.github/workflows/testbuild-qt6.yml`):** init submodules
  (`git submodule update --init --recursive`, already done for rtmidi), add a
  litehtml build step; drop `qtwebengine` from the default modules list; add a
  separate html_support job (with `qtwebengine`) if we want to keep CI coverage
  for the HTML5 GUI.
- **macOS/Windows installers:** add litehtml to the build; WebEngine entitlements
  notes in release notes can be removed for the default build.

### Phase 6 — HTML5 GUI stays optional on WebEngine

- Keep `CsoundHtmlView`, the wrappers, and all `CSQT_QTHTML`/`QCS_QTHTML` code
  untouched; they compile only with `html_support`.
- `src/csoundqt.cpp:3192` about-dialog text ("Html support based on QtWebEngine")
  — guard/reword to reflect the optional HTML5 GUI.

### Phase 7 — Verification

Automated:
- Default build (qmake + CMake) links **no** `QtWebEngine*`.
- `html_support` build still compiles `CsoundHtmlView`.
- Headless self-tests for: article extraction + tab flattening, fragment capture
  vs painted draw, selection/copy text, in-page find match rects, search over both
  real indexes (`reverb`, `perli`+Enter, `GENious`), `resolvePath` → existing file.

Manual (test matrix):
- Open manual; navigation via content links, Back/Forward, Home.
- Ctrl+F in-page find + next/prev + whole-word + Esc clears selection.
- Text selection + Ctrl+C; click clears selection; Esc clears.
- Zoom (Ctrl+/Ctrl-), resize re-renders correctly.
- `.csd` example link → opens in editor; external link → host browser.
- Whole-manual search: both roots, source labels, Enter prefix, result deep-link.
- Risset absent → only built-in root; built-in manual absent → graceful message.

## 5. Decisions needed before/while implementing

**Resolved (2026-09-01):**
1. **litehtml vendoring**: git submodule at `third_party/litehtml`.
2. **Stale help targets** (`showGen/showOverview/showOpcodeQuickRef`): leave
   untouched for now (separate future fix).
3. **Search UI placement**: inside the `DockHelp` dock (in-dock panel).
4. **HTML5 GUI CI coverage**: default CI job becomes WebEngine-free; add one
   small `html_support` job so `CsoundHtmlView` stays compile-tested.
5. **Monospace font**: system fallback now; configurable font later.

Remaining minor questions may be resolved during implementation with sensible
defaults and noted here.

## 6. Risks

- **qmake build of litehtml** (no upstream `.pri`): need to hand-write the source
  list; mitigate by generating it from litehtml's `CMakeLists.txt` SOURCE lists.
- **C++ standard bump (11 → 17)** in CMake affects the whole target; low risk,
  but verify no old code depends on C++11-only behavior.
- **litehtml render pathologies** (nav sidebar hang) are avoided by the mandatory
  article extraction; keep the extraction in `LiteView::loadFile` and cover it with
  the headless test.
- **`docDir` for the built-in search root**: only add the root when
  `search/search_index.json` exists; some users point `csdocdir` at older manuals.
- **Fonts**: Roboto Mono absent on many systems → monospace fallback (Hack/DejaVu).
- **Behavior regression vs WebEngine**: run the Phase 7 matrix; selection is
  run-granularity (not character-precise) — a known, accepted trade-off.

## 7. Interruption/resume notes

- Each phase compiles/verifies independently; commit after each phase.
- If interrupted mid-phase, the repo state is documented by this file + the phase
  checklist above; Phase 0/1 commits are reversible (submodule removal + revert
  of the new `src/*` files).
- The spike at `/tmp/opencode/qtlite` is the reference implementation; keep it
  intact until Phase 2 is complete.
