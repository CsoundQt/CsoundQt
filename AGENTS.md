# Project notes

## Qt requirement

- CsoundQt requires **Qt >= 6.7**. Qt5 is **not** supported anymore.
- Do **not** add Qt5 compatibility code. No `#if QT_VERSION >= QT_VERSION_CHECK(5, ...)`
  fallbacks, no `QVariant::convert(int)` / `QVariant::type()`, etc.
- Use modern Qt6 APIs directly, e.g. `QVariant::convert(QMetaType)` / `QVariant::metaType()`.
- `qcs.pro` already requires Qt6. The CMake build's version check is stale (see below).

## Known stale Qt5 leftovers to clean up

- `CMakeLists.txt` (~line 52): the version guard has an inverted/incorrect message —
  the `else()` branch (i.e. Qt6) says `FATAL_ERROR "Only Qt5 is currently supported"`.
  It should require `Qt >= 6.7`.
- `src/types.h` (~line 112) and `src/qutegraph.cpp` (~line 1516): `QT_VERSION >= 5.14`
  guards for `ENDL`/`SKIP_EMPTY_PARTS` can be removed.

## Building this working copy

- qmake build directory: `build/Desktop_Qt_6_10_2-qt-6.10.2-release` (run `make` there).

## Csound gotchas (for examples)

- `kr` is a **built-in** Csound variable (control rate). Assigning to it fails with
  `Opcode given variables with two different types: r : k`. Use e.g. `kred`, `kgrn`.
- Use `sprintfk` (k-rate), not `sprintf`, when formatting with k-rate variables.
- Widget properties are addressed from Csound **without** the internal `CSQT_` prefix:
  `outvalue "<channel>/<property>", <value>` (e.g. `outvalue "knob/color", "#ff00ff"`).
  See `src/Examples/CsoundQt/C Widgets/Widget_Animation.csd`.

## 0dBFS

- A csd can set 0dBFS in **two** places:
  - In the **orchestra header**, as an assignment to the `0dbfs` variable, e.g.
    `0dbfs = 1`, `0dbfs=1.0`, `0dbfs = 32768` (any spacing).
  - In the **`<CsOptions>`** tag, as the command-line flag `--0dbfs=<value>`.
- If neither is present, Csound uses its own default, which can be configured
  globally or per project in a `.csound7rc` file.
- CsoundQt's Settings/Advanced **"Fallback 0dBFS = 1.0"** checkbox (default
  **checked**) passes `--0dbfs=1` **only when the csd does not set 0dbfs itself**
  (in either place above). It is equivalent to having `--0dbfs=1` in a
  `.csound7rc`, without overriding a csd that sets its own value. Unchecked,
  CsoundQt passes nothing and Csound's default takes over.
- Implementation: `CsoundOptions::fallbackDbfs` (the persisted setting),
  `CsoundOptions::csdSetsDbfs` (per-run, set in `CsoundQt::play()` from the
  document text via `CsoundOptions::textSetsDbfs()`), and the flag itself is
  added in `CsoundOptions::generateCmdLineFlagsList()`.

## Commits

When commiting yourself, think that commits are where we build a knowledge base 
for future development. Be clear about what was the idea behind the commit or part of the commit:

* was it a bug fix? A new feature? 
* What needed to be fixed, what did you try that did not work (if applicable)
* how did you fix it, was there some valuable interaction with the human?
