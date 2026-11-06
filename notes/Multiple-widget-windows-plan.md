# Multiple simultaneous widget windows

Plan for letting several documents perform at the same time, each with its own
visible widget window.

Status: **plan only** – nothing in this document has been implemented yet, except
the prerequisite fix described in section 2.

Line numbers refer to the current working tree (after the "empty widget panel"
fix, commit `055131dc`).

---

## 1. Goals and non-goals

### Goals

1. Two or more documents can perform simultaneously and each of them can have
   its widget layout on screen in its own top-level window, at the same time.
2. Switching the active document tab has **no effect** on any widget window:
   nothing is shown, hidden, raised, moved or resized.
3. Widget window visibility is a property of the document, independent of
   whether the document is performing. Stopping a document does **not** hide
   its window; the user closes it when they no longer want it.
4. The widget window title is always the document name.
5. The geometry of an independent widget window survives tab switches and is
   written back to the document when it is saved.
6. A background document that finishes its performance updates its own tab
   icon, without disturbing the state of the current document.
7. Transport controls inside a widget window (`_Play`, `_Stop`, `_Pause`,
   `_Render`) act on the document that owns that window.
8. Starting a second performance is refused with a notification banner when
   the audio backend cannot support it (ALSA without PipeWire).
9. MIDI continues to be broadcast to all documents; the existing
   *MIDI CC to current page only* option is honoured.

### Non-goals (for this iteration)

* Restoring widget window visibility across application restarts.
* Supporting more than one widget layout per document (`m_widgetLayouts` is
  still effectively a one-element list; see `BaseDocument::getWidgetLayout()`).
* Changing the virtual keyboard behaviour: it stays bound to the current
  document (`CsoundQt::virtualMidiIn()` → current page).
* Changing the docked widget panel behaviour: docked mode keeps exactly one
  panel, shared by the current document.

---

## 2. Prerequisite: the empty widget panel (already fixed)

While investigating, a related bug was found and fixed: with
*Show widgets in separate window* enabled, the docked `WidgetPanel` was still
shown as an empty surface with its "Widgets" tab.

Causes and fix (`src/csoundqt.cpp` / `src/csoundqt.h`, commit `055131dc`):

* `applyDefaultDockLayout()` showed the panel unconditionally on a first run
  (no saved dock layout).
* The constructor only *skipped* showing the panel in independent mode, so a
  panel restored as visible by a saved dock layout stayed visible.
* `testAudioSetup()` showed the panel unconditionally.
* Nothing moved the layout out of the panel when the mode was switched at
  runtime.

The fix hides the panel in independent mode, and adds
`CsoundQt::applyWidgetModeChange()` which moves the layout between the dock
and the standalone windows when the setting changes.

This matters for this plan: `applyWidgetModeChange()` is the place where the
"layout lives here" question is answered, and it will have to be extended when
the visibility rules change (section 4).

---

## 3. What already exists

* **One engine per document.** `BaseDocument` creates a `CsoundEngine` in its
  constructor (`src/basedocument.cpp:39`); the engine creates its own
  `CSOUND*` (`src/csoundengine.cpp:58`).
* **One top-level widget window per document.** `BaseDocument::newWidgetLayout()`
  (`src/basedocument.cpp:242`) creates a `WidgetLayout` with
  `Qt::Window` flags and keeps it hidden until it is shown.
* **Simultaneous playback already exists.** `CsoundQt::play()` only calls
  `stopAllOthers()` when `m_options->simultaneousRun` is false
  (`src/csoundqt.cpp:3016`). The option lives in *Settings → General →
  Allow simultaneous play* (`src/configdialog.ui:1473`). Note that it is
  persisted with a default of `false`
  (`src/csoundqt.cpp:7818`: `settings.value("simultaneousRun", "").toBool()`),
  so it has to be enabled explicitly; `CsoundOptions` itself defaults to
  `true` (`src/csoundoptions.cpp:89`).
* **MIDI is already broadcast.** `MidiHandler::passMidiMessage()`
  (`src/midihandler.cpp:64`) forwards every message to every registered
  listener page; every page is registered in `makeNewPage()`
  (`src/csoundqt.cpp:8575`). `acceptsMidiCC` is set per page in
  `changePage()`.

## 4. What blocks it today

### 4.1 `changePage()` hides and shows windows

`CsoundQt::changePage()` (`src/csoundqt.cpp:1273`) is called whenever the
active tab changes. Today it:

```cpp
        disconnect(documentPages[curPage], SIGNAL(stopSignal()),0,0);
        auto page = documentPages[curPage];
        page->hideWidgets();                       // <-- hides the outgoing window
        if (!m_options->widgetsIndependent) {
            ...
            widgetPanel->takeWidgetLayout(panelGeometry);
        } else {
            page->setWidgetLayoutOuterGeometry(QRect());
        }
```

and for the incoming document:

```cpp
        if (!m_options->widgetsIndependent) {
            WidgetLayout *w = page->getWidgetLayout();
            widgetPanel->addWidgetLayout(w);
            setWidgetPanelGeometry();
        } else {
            WidgetLayout *w = page->getWidgetLayout();
            w->adjustWidgetSize();                // <-- moves/resizes the window
        }
        ...
            else {
                page->showWidgets(showWidgetsAct->isChecked());  // <-- shows it
            }
```

So switching tabs hides the outgoing document's window, re-applies the stored
geometry to the incoming one and shows it depending on a global action state.

### 4.2 `showWidgetsAct` is global, but should be per document

`showWidgetsAct` is a single checkable action. In docked mode it means "the
dock panel is visible"; in independent mode it must mean "the *current
document's* window is visible". `connectActions()`
(`src/csoundqt.cpp:6872`) connects it to `toggleWidgetsPanel()` and to the
current document's `WidgetLayout::windowStatus(bool)` signal.

### 4.3 Background documents lose their stop notification

`connectActions()` starts with `disconnect(doc, 0, 0, 0)`
(`src/csoundqt.cpp:6908`), which removes every outgoing connection of the
document, including `stopSignal() → markStopped()`. `changePage()` also
disconnects the outgoing document's `stopSignal`
(`src/csoundqt.cpp:1292`). As a result, when a background document's
performance ends, nothing updates its tab icon.

### 4.4 Stopping a background document clears the current document's UI

`CsoundQt::stop(int index)` (`src/csoundqt.cpp:3454`) always ends with
`markStopped()`, which unconditionally does `runAct->setChecked(false)`,
`recAct->setChecked(false)`, `updateEvaluateAction()` and
`updatePerformanceInfo(nullptr)` – even when the document that was stopped is
not the current one.

### 4.5 Transport controls act on the current tab

`DocumentPage::registerButton()` (`src/documentpage.cpp:877`) connects the
widget buttons to the main window's slots without an index:

```cpp
	connect(b, SIGNAL(play()),  static_cast<CsoundQt *>(parent()), SLOT(play()));
	connect(b, SIGNAL(render()),static_cast<CsoundQt *>(parent()), SLOT(render()));
	connect(b, SIGNAL(pause()), static_cast<CsoundQt *>(parent()), SLOT(pause()));
	connect(b, SIGNAL(stop()),  static_cast<CsoundQt *>(parent()), SLOT(stop()));
```

`CsoundQt::play(bool, int)`, `stop(int)`, `pause(int)` and `record(bool, int)`
all accept an index; `render()` does not. With two visible windows, the
`_Stop` button in a background window would stop the *current* document.

### 4.6 Geometry is only captured when leaving the tab

* `WidgetLayout::adjustWidgetSize()` (`src/widgetlayout.cpp:2222`) resizes and
  moves a standalone window to the stored `m_posx/m_posy/m_w/m_h`.
* `m_posx/m_posy/m_w/m_h` are only refreshed from the real geometry in
  `changePage()` (outgoing document) and in `saveFile()` – and `saveFile()`
  only does that for the **docked** panel
  (`src/csoundqt.cpp:8615`: `if (!m_options->widgetsIndependent) { ... }`).
* `WidgetLayout::setOuterGeometry()` (`src/widgetlayout.cpp:614`) ignores
  coordinates of 0 because of `if (newx > 0 && newy > 0)`.

Consequence: a window that the user moved and resized is written back with
stale coordinates unless the user happens to switch tabs before saving.

### 4.7 The window title comes from the CSD `<label>`

`WidgetLayout::parseXmlNode()` (`src/widgetlayout.cpp:3859`) does
`setWindowTitle(child.nodeValue())` for the `<label>` element, and
`WidgetLayout::getWidgetsText()` (`src/widgetlayout.cpp:489`) writes
`windowTitle()` back as `<label>`. If the title is changed to the document
name, saving the CSD would overwrite the original label.

---

## 5. Decisions taken during the discussion

| Topic | Decision |
|---|---|
| Visibility of a stopped document's window | Keep it visible; the user closes it |
| Effect of a tab switch on widget windows | None at all |
| Visibility vs. performance state | Independent |
| `showWidgetsAct` | Reflects and toggles the *current* document's window (independent mode) |
| Docked mode | Unchanged: one shared panel |
| Widget window title | Always the document name |
| MIDI | Broadcast to all documents; honour *MIDI CC to current page only* |
| Virtual keyboard | Current document only (unchanged) |
| ALSA without PipeWire | Second simultaneous performance refused with a banner |
| Transport buttons in a widget window | Act on the owning document |

---

## 6. Detailed work items

### 6.1 Visibility rules of `changePage()`

**File:** `src/csoundqt.cpp`, `CsoundQt::changePage()` (line 1273)

*Outgoing document* – do not touch its window in independent mode:

```cpp
        auto page = documentPages[curPage];
        if (!m_options->widgetsIndependent) {
            page->hideWidgets();
            QRect panelGeometry = widgetPanel->geometry();
            ...
            widgetPanel->takeWidgetLayout(panelGeometry);
        } else {
            // The window stays exactly as the user left it. Its geometry is
            // kept up to date by the move/resize handlers (6.6).
            page->setWidgetLayoutOuterGeometry(QRect());
        }
```

*Incoming document* – do not show, move or resize its window:

```cpp
        if (!m_options->widgetsIndependent) {
            WidgetLayout *w = page->getWidgetLayout();
            widgetPanel->addWidgetLayout(w);
            setWidgetPanelGeometry();
        }
        // (independent mode: nothing to do here)
```

and replace the `page->showWidgets(showWidgetsAct->isChecked())` call in the
independent branch with a state update only:

```cpp
            if (!m_options->widgetsIndependent) {
                page->showWidgets();
                widgetPanel->setVisible(showWidgetsAct->isChecked());
            } else {
                // The window keeps whatever visibility the user gave it;
                // only the menu entry follows the current document.
                showWidgetsAct->setChecked(page->isWidgetWindowVisible());
            }
```

Notes:

* `showWidgetsAct->setChecked()` must happen *after* `connectActions()`
  (which is called earlier in the same function), because `connectActions()`
  reconnects the action's `triggered`/`windowStatus` connections.
* `setChecked()` does not emit `triggered()`, so the action cannot loop back
  into `toggleWidgetsPanel()`.
* A new small helper `DocumentPage::isWidgetWindowVisible()` (returns
  `m_widgetLayouts[0]->isVisible()`) avoids reaching into the layout from
  `CsoundQt`. The name must not be `widgetsVisible()`: `BaseDocument` already
  has `widgetsVisible(bool)` (`src/basedocument.cpp:265`), which is used by
  `CsoundQt::play()` (`src/csoundqt.cpp:3063`); a no-argument overload in
  `DocumentPage` would hide the base one.

### 6.2 `toggleWidgetsPanel()` and `focusWidgets()`

**File:** `src/csoundqt.cpp`, lines 2484 and 2282

Both already work per document in independent mode:

* `toggleWidgetsPanel()` reads `wl->isVisible()` of the current document and
  calls `doc->showWidgets(true/false)`.
* `focusWidgets()` calls `doc->showWidgets(true)` and raises the window.

They need two adjustments:

* `DocumentPage::showWidgets(true)` must not re-apply the stored geometry to
  an already visible window (see 6.6). `WidgetLayout::adjustWidgetSize()`
  currently does `resize(m_w, m_h); move(m_posx, m_posy);` unconditionally for
  a standalone layout. Guard it:

```cpp
void WidgetLayout::adjustWidgetSize()
{
    if (m_contained) {
        adjustLayoutSize();
    } else if (!isVisible()) {
        // A window that is already on screen keeps the geometry the user
        // gave it; only a hidden one is placed at the stored position.
        this->resize(m_w, m_h);
        this->move(m_posx, m_posy);
    }
}
```

* `showWidgetsAct` should follow the window state of the current document
  when it changes elsewhere (window closed by the user). That is already
  handled by `WidgetLayout::closeEvent()` → `windowStatus(false)` →
  `showWidgetsAct::setChecked(false)` (`src/csoundqt.cpp:7009`).

### 6.3 Background document state when a performance ends

**Files:** `src/csoundqt.cpp`, `makeNewPage()` (line 8508), new slot;
`src/csoundqt.h`.

Add a permanent connection per document, made when the page is created:

```cpp
    connect(newPage->getEngine(), &CsoundEngine::stopSignal,
            this, &CsoundQt::documentPerformanceEnded);
```

The engine object itself lives in the GUI thread, but `stopSignal()` is *not*
always emitted there: when a score ends by itself, the stop is triggered from
the message dispatcher thread
(`CsoundEngine::messageListDispatcher()`, `src/csoundengine.cpp:1309-1317`,
started with `QtConcurrent::run()`), which calls `CsoundEngine::stop()` →
`stopCsound()` → `emit stopSignal()`
(`src/csoundengine.cpp:1092` and `:1114`).

The connection is therefore cross-thread. With the default
`Qt::AutoConnection` the slot is invoked as a queued call in the GUI thread,
which is exactly what is needed for the UI updates below. (The existing
`DocumentPage::perfEnded()` connection behaves the same way.) The lookup of
the page through `sender()` keeps working in a queued call.

New slot:

```cpp
void CsoundQt::documentPerformanceEnded()
{
    auto *engine = qobject_cast<CsoundEngine *>(sender());
    if (engine == nullptr)
        return;
    int index = -1;
    for (int i = 0; i < documentPages.size(); ++i) {
        if (documentPages[i]->getEngine() == engine) {
            index = i;
            break;
        }
    }
    if (index < 0)
        return;                     // the document was closed meanwhile
    DocumentPage *page = documentPages[index];
    removePlaybackTempFile(page);
    updateTabIcon(index);
    // Only the current document drives the toolbar/state of the main window.
    if (index == curPage) {
        runAct->setChecked(false);
        recAct->setChecked(false);
        updateEvaluateAction();
        updatePerformanceInfo(nullptr);
    }
}
```

Deliberately **not** in this slot: `hideWidgets()`. Visibility is
independent of the performance state (section 5).

Consequences for the existing code:

* `CsoundQt::markStopped()` (`src/csoundqt.cpp:3519`) is connected to
  `DocumentPage::stopSignal()` for the current document only. With the new
  slot in place it becomes largely redundant; it can be reduced to the
  current-document cleanup, or kept for the cases where it is called
  directly (`stop()`, `stopAll()`).
* `CsoundQt::stop(int index)` must not clear the current document's UI when a
  background document is stopped:

```cpp
    removePlaybackTempFile(documentPages[docIndex]);
    updateTabIcon(docIndex);
    if (docIndex == curPage)
        markStopped();              // only for the current document
```

* `CsoundQt::stopAll()` (line 3496) stops everything and may keep its
  unconditional `markStopped()` (the current document is stopped too).
* `CsoundQt::stopAllOthers()` (line 3506) is called by `play()` when
  simultaneous play is disabled; the individual stops trigger the new slot
  per document, which is exactly what is wanted.

### 6.4 Transport controls act on the owning document

**File:** `src/documentpage.cpp`, `DocumentPage::registerButton()` (line 877)

The page knows its own identity; the index changes when tabs are moved or
closed, so the index must be resolved at invocation time:

```cpp
void DocumentPage::registerButton(QuteButton *b)
{
    auto *csoundQt = qobject_cast<CsoundQt *>(parent());
    if (csoundQt == nullptr)
        return;
    auto pageIndex = [this, csoundQt]() {
        return csoundQt->documentPages.indexOf(this);
    };
    connect(b, &QuteButton::play, this, [csoundQt, pageIndex]{
        const int index = pageIndex();
        if (index >= 0) csoundQt->play(true, index);
    });
    connect(b, &QuteButton::stop, this, [csoundQt, pageIndex]{
        const int index = pageIndex();
        if (index >= 0) csoundQt->stop(index);
    });
    connect(b, &QuteButton::pause, this, [csoundQt, pageIndex]{
        const int index = pageIndex();
        if (index >= 0) csoundQt->pause(index);
    });
    connect(b, &QuteButton::render, this, [csoundQt, pageIndex]{
        const int index = pageIndex();
        if (index >= 0) csoundQt->renderDocument(index);
    });
}
```

Notes:

* `documentPages` is a public member of `CsoundQt`
  (`src/csoundqt.h:465`), so the lambda can use it; alternatively add
  `CsoundQt::indexOfPage(DocumentPage *)`.
* `CsoundQt::play(true, index)` already supports an index. It temporarily
  sets `curPage = index` and restores it at the end
  (`src/csoundqt.cpp:2884` and `:3086`), so the active tab does not change.
* `stop(int)`, `pause(int)` and `record(bool, int)` already take an index.
* The shared `m_options` object is mutated by `play()` before the performance
  starts, but each engine takes its own snapshot at that moment
  (`CsoundEngine::play()`: `m_options = *options;`,
  `src/csoundengine.cpp:756`). Because the copy happens inside the same
  synchronous call, two documents can never see each other's options.
* `play()` also calls `updatePerformanceInfo(page)`, so starting a background
  document replaces the sample-rate/channel information in the status bar
  with that document's values. Acceptable, but worth watching; the
  information could be limited to the current document if it turns out to be
  confusing.

**`render()` needs an index.** `CsoundQt::render()`
(`src/csoundqt.cpp:3604`) uses `curPage` throughout and drives the global
render progress widget. `render()` is connected with the old-style
`SLOT(render())` (`src/csoundqt.cpp:6359`), so the existing signature has to
stay. Add a separate entry point and keep `render()` as a wrapper:

```cpp
void CsoundQt::render()
{
    renderDocument(curPage);
}

void CsoundQt::renderDocument(int index)
{
    if (index < 0 || index >= documentPages.size())
        return;
    DocumentPage *page = documentPages[index];
    ...
}
```

Inside `renderDocument()`, replace the remaining `documentPages[curPage]` /
`curPage` uses with `index` / `page`. The progress UI
(`m_renderStatusWidget`, `m_renderProgressTimer`, `m_renderStopConnection`)
stays global: rendering a background document shows its progress in the same
status bar area. The `saveAs()` call inside the function (for unnamed
documents) still acts on the current document and needs a look – the simplest
safe behaviour is to require a background document to have a file name before
it is rendered.

### 6.5 Widget window title = document name

**Files:** `src/widgetlayout.h/.cpp`, `src/csoundqt.cpp`.

*Step 1 – keep the CSD label separate from the window title.*

In `WidgetLayout`:

```cpp
    QString m_label;   // the <label> of the panel as stored in the CSD
```

* `parseXmlNode()` (line 3859) stores the value in `m_label` instead of
  calling `setWindowTitle()`:

```cpp
    else if (name == "label") {
        auto child = node.firstChild();
        if (!child.isNull())
            m_label = child.nodeValue();
    }
```

* `getWidgetsText()` (line 489) writes `m_label` instead of `windowTitle()`:

```cpp
    txts << "<label>" << m_label << "</label>\n"
```

* `m_label` is initialised next to `m_objectName = "";` in the constructor
  (`src/widgetlayout.cpp:259`), matching the current behaviour of an unset
  title.
* The title is set *after* the CSD is parsed: `makeNewPage()` calls
  `loadTextString()` (which parses the widget XML) before
  `setTabTextForPage()`, so `updateWidgetWindowTitle()` always runs after the
  `<label>` has been read.

*Step 2 – let CsoundQt own the window title.*

Add to `CsoundQt`:

```cpp
    // Display name of a document, as shown in its tab.
    QString documentDisplayName(int index) const;
    // Give the document's widget window the document name as its title.
    void updateWidgetWindowTitle(int index);
```

`documentDisplayName()` reuses the rules of `setTabTextForPage()`
(`src/csoundqt.cpp:8874`) and `setCurrentFile()`:

```cpp
QString CsoundQt::documentDisplayName(int index) const
{
    if (index < 0 || index >= documentPages.size())
        return QString();
    const DocumentPage *page = documentPages[index];
    QString name = page->getFileName();
    if (name.isEmpty())
        name = page->getTemporaryName();
    if (name.isEmpty())
        name = u"untitled.csd"_s;
    return strippedName(name);
}
```

`updateWidgetWindowTitle()`:

```cpp
void CsoundQt::updateWidgetWindowTitle(int index)
{
    if (index < 0 || index >= documentPages.size())
        return;
    WidgetLayout *layout = documentPages[index]->getWidgetLayout();
    if (layout == nullptr)
        return;
    layout->setWindowTitle(documentDisplayName(index));
}
```

*Step 3 – call it wherever the name changes.*

* `setTabTextForPage()` (line 8874) – after loading/saving a document.
* `setCurrentFile()` (line 8895) – after a save-as rename.
* `newFile()` – the new document is called "default.csd".
* `changePage()` – cheap, and keeps the title correct when documents are
  restored in the background.
* `saveFile()` – after the file name changed.

*Step 4 – docked mode.*

In docked mode the layout lives inside the panel, so the window title is not
visible; setting it anyway is harmless and keeps the code simple. The
`<label>` written to the CSD is unaffected (step 1).

### 6.6 Independent window geometry

**Files:** `src/widgetlayout.h/.cpp`, `src/csoundqt.cpp`.

*Step 1 – track the real geometry.*

Add to `WidgetLayout` (protected):

```cpp
    void moveEvent(QMoveEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;
```

```cpp
void WidgetLayout::moveEvent(QMoveEvent *event)
{
    QWidget::moveEvent(event);
    storeOuterGeometry();
}

void WidgetLayout::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);
    storeOuterGeometry();
}

void WidgetLayout::storeOuterGeometry()
{
    if (m_contained)      // a docked panel is laid out by QMainWindow
        return;
    const QRect g = geometry();
    m_posx = g.x();
    m_posy = g.y();
    m_w = g.width();
    m_h = g.height();
}
```

*Step 2 – accept coordinates of 0.*

`setOuterGeometry()` (line 614) currently requires `newx > 0 && newy > 0`,
which silently drops a window placed at the top/left edge:

```cpp
    if (newx >= 0 && newy >= 0) {
        m_posx = newx >= 0 && newx < 4096 ? newx : m_posx;
        m_posy = newy >= 0 && newy < 4096 ? newy : m_posy;
        m_w = neww >= 0 && neww < 4096 ? neww : m_w;
        m_h = newh >= 0 && newh < 4096 ? newh : m_h;
    }
```

(The negative values are the sentinel used for a docked panel, whose position
is managed by `QMainWindow`.)

*Step 3 – capture the geometry when saving.*

`CsoundQt::saveFile()` (line 8603) currently only captures the geometry in
docked mode. Add the independent case:

```cpp
    if (m_options->widgetsIndependent) {
        documentPages[curPage]->setWidgetLayoutOuterGeometry(QRect());
    } else {
        // ... existing docked code ...
    }
```

`setOuterGeometry(QRect())` (invalid rectangle) takes the current geometry of
the layout, which is what we want. With step 1 in place this is a safety net;
without it, it is the only place where a moved window is stored.

*Step 4 – never re-apply the geometry to a visible window.*

See the guard in `adjustWidgetSize()` in 6.2.

### 6.7 ALSA guard: refuse a second simultaneous performance

**File:** `src/csoundqt.cpp`, `CsoundQt::play()` (line 2872)

The check belongs after the audio module has been resolved
(`ensureAudioMidiDiscovery()`, line 2898) and before the performance starts
(so before `stopAllOthers()` at line 3016).

```cpp
    // A second realtime performance needs an audio backend that can be
    // opened twice. ALSA can only do that when PipeWire is in the loop.
    if (realtime && !m_options->checkSyntaxOnly
            && m_options->simultaneousRun
            && !page->isRunning()
            && anyOtherDocumentRunning(curPage)
            && m_options->rtAudioModule == u"alsa"_L1
            && !m_configlists.isPipeWireRunning()) {
        Notification::showTransient(this,
                tr("Simultaneous performance is not supported"), 3000);
        if (curPage == oldPage)
            runAct->setChecked(false);
        curPage = oldPage;
        return;
    }
```

with a small helper:

```cpp
bool CsoundQt::anyOtherDocumentRunning(int exceptIndex) const
{
    for (int i = 0; i < documentPages.size(); ++i) {
        if (i != exceptIndex && documentPages[i]->isRunning())
            return true;
    }
    return false;
}
```

Details:

* `m_options->simultaneousRun` must be true: when it is false, `play()`
  stops the other documents first, so the performance is not simultaneous and
  the backend does not need to support it.
* `!page->isRunning()`: pressing Play on an already running document does not
  open a second device (the engine returns "Already playing").
* `m_options->rtAudioModule` holds the raw module name as selected in the
  settings ("jack", "rtpw", "alsa", "pa_cb", …). `ConfigLists::audioModuleDisplayName()`
  (`src/configlists.cpp:181`) can be used for the user-facing name; for the
  check the raw name is enough. A small helper on `ConfigLists`
  (`isAlsaModule()`) keeps the literal in one place.
* `ConfigLists::isPipeWireRunning()` (`src/configlists.cpp:626`) looks for
  `$PIPEWIRE_RUNTIME_DIR`/`$XDG_RUNTIME_DIR` + `$PIPEWIRE_REMOTE`. It returns
  `false` on non-Linux platforms, where the ALSA module does not exist
  anyway.
* `Notification::showTransient()` is already used in this file
  (`src/csoundqt.cpp:1161` and others).

The same check should be applied when a *background* document is started
through its own widget window (`_Play`), because `play(true, index)` goes
through the same function.

### 6.8 MIDI

No code change. The broadcast already exists (section 3). The existing
*Settings → Widgets → MIDI CC to current page only* option
(`m_options->midiCcToCurrentPageOnly`) is honoured as it is today: with the
option enabled only the current document reacts to MIDI CC, with it disabled
all documents do.

If the user wants a hint that several documents are receiving the same
controller, a status bar message could be added later; it is out of scope.

### 6.9 Docked mode

Unchanged. `changePage()` keeps taking the outgoing document's layout out of
the panel and adding the incoming one; the panel is shown or hidden by
`showWidgetsAct`. `CsoundQt::applyWidgetModeChange()` (from the prerequisite
fix) moves a layout between the dock and a standalone window when the widget
mode is changed at runtime; it needs to respect the new rules:

* When switching **to** independent mode, the current document's window is
  shown only if it was visible before the switch (already the case).
* When switching **to** docked mode, all standalone windows are hidden and
  only the current document's layout goes into the panel (already the case).

---

## 7. Files to be touched

| File | What |
|---|---|
| `src/csoundqt.cpp` | `changePage()`, `toggleWidgetsPanel()`, `focusWidgets()`, `play()`, `stop()`, `stopAll()`, `stopAllOthers()`, `markStopped()`, `saveFile()`, `makeNewPage()`, `connectActions()`, `render()`/`renderDocument()`, new slot `documentPerformanceEnded()`, new helpers `documentDisplayName()`, `updateWidgetWindowTitle()`, `anyOtherDocumentRunning()` |
| `src/csoundqt.h` | declarations of the new members |
| `src/documentpage.cpp` | `registerButton()`, new helper `isWidgetWindowVisible()` |
| `src/documentpage.h` | declaration of `isWidgetWindowVisible()` |
| `src/widgetlayout.cpp` | `adjustWidgetSize()` guard, `moveEvent()`, `resizeEvent()`, `setOuterGeometry()`, `parseXmlNode()` (`<label>`), `getWidgetsText()` (`<label>`) |
| `src/widgetlayout.h` | `m_label`, `moveEvent()`, `resizeEvent()`, `storeOuterGeometry()` |
| `src/configlists.h/.cpp` | optional `isAlsaModule()` helper |
| `src/configdialog.ui` | none (the options already exist) |

---

## 8. Implementation order

1. **Visibility rules** (6.1, 6.2) – the core of the feature; after this step
   two documents can already keep their windows open.
2. **Titles** (6.5) – needed to tell the windows apart.
3. **Geometry** (6.6) – needed so that the windows stay where the user put
   them.
4. **Background state** (6.3) – tab icons and actions of background
   documents.
5. **Transport controls** (6.4) – `_Play`/`_Stop`/`_Pause`/`_Render` in every
   window act on their own document.
6. **ALSA guard** (6.7) – the backend restriction.
7. **MIDI** (6.8) – verification only.

Each step is independently testable.

---

## 9. Test plan

### 9.1 Manual

Settings: *Show widgets in separate window* on, *Allow simultaneous play* on.

| # | Action | Expected |
|---|---|---|
| 1 | Play document A | A's widget window opens, title = document name |
| 2 | Switch to tab B | A's window unchanged (same position, size, not raised); no window appears for B |
| 3 | Play document B | B's window opens; A's window still there and unchanged |
| 4 | Stop B | B's window **stays open**; B's tab icon stops playing; A's window unchanged |
| 5 | Stop A | A's window stays open |
| 6 | Close A's window | The window closes; A keeps performing; the Widgets menu entry follows the current document |
| 7 | Switch tabs repeatedly | No window is shown, hidden, moved or resized |
| 8 | Move and resize a window, then switch tabs and back | Position and size are unchanged |
| 9 | Move and resize a window, then save the document, reopen it | The saved `<x> <y> <width> <height>` match the window |
| 10 | Save a CSD that has a `<label>` | The `<label>` in the file is unchanged; the window title shows the document name |
| 11 | Press `_Stop` in a background window | That document stops; the current document keeps playing |
| 12 | Press `_Play` in a background window | That document starts; the active tab does not change |
| 13 | ALSA backend without PipeWire, A playing, press Play on B | Banner "Simultaneous performance is not supported"; B does not start |
| 14 | JACK/PipeWire backend, A playing, press Play on B | B starts |
| 15 | MIDI controller moved | All playing documents receive it (unless "MIDI CC to current page only" is on) |
| 16 | Docked mode: switch tabs | One panel, content follows the current document, no flash (regression) |
| 17 | Switch the widget mode in Settings at runtime | The layout moves between the dock and the window, no empty panel left behind |
| 18 | Close a document that has an open window | The window disappears with the document |

### 9.2 Automated

* `tests/run-tests.sh` – the existing unit tests do not cover the main
  window, but they must still pass.
* A headless smoke test (as used while fixing the empty panel): start the
  application with `QT_QPA_PLATFORM=offscreen` and a prepared `QSettings`
  file, and assert that in independent mode the dock panel stays hidden and
  that the widget window is a top-level window.

---

## 10. Risks and open points

* **Two Csound instances, one audio device.** JACK, PipeWire and PulseAudio
  clients can share a device; an exclusive ALSA device cannot. This is the
  reason for the guard in 6.7. The existing tooltip in the settings dialog
  ("Simultaneous play may cause problems under certain audio backends")
  should be kept.
* **Csound global state.** Each engine has its own `CSOUND*`, but plugin
  globals, the message dispatcher and the MIDI ports are process-wide.
  Simultaneous performances with plugins that keep global state can misbehave.
  Out of scope, but worth a note in the release notes.
* **MIDI conflicts.** Every document receives the same controller events;
  documents that react to the same controller will fight over the same
  hardware. The user has to use different channels.
* **Rendering from a background document** (6.4) shares the global render
  progress widget; a second render started while one is running is not
  supported today either.
* **`m_visible` in the CSD** (`<visible>`) is written but never applied; it
  stays as it is.
* **Window positions** are stored per document in the CSD; two documents with
  the same saved position will open on top of each other. Not addressed.
