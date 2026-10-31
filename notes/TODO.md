# TODO

Ideas and follow-ups that are not being worked on yet. Keep entries short; add
enough context that they can be picked up later without re-investigating.

## Fusion tooltips: rounded corners and shadow

**Goal:** make Fusion tooltips look less flat — rounded corners and, if
possible, a soft drop shadow, similar to what Breeze/KStyle does.

**Current state**

- `QTipLabel` (Qt's internal tooltip label) paints only
  `QStyle::PE_PanelTipLabel`.
- Fusion/QCommonStyle draws that as a plain rectangle: `ToolTipBase` fill with
  a 1 px `ToolTipText` border, no shadow.
- Defaults: `PM_ToolTipLabelFrameWidth = 1`, `SH_ToolTip_Mask = false`,
  `SH_ToolTipLabel_Opacity = 255`.
- CsoundQt deliberately avoids a `QToolTip { ... }` stylesheet today so that it
  keeps the platform/style rendering (see `configureNativeToolTips()` in
  `src/csoundqt.cpp`).

**Options**

1. **Stylesheet only** — easy, but limited:

   ```css
   QToolTip {
       border: 1px solid palette(mid);
       border-radius: 6px;
       padding: 4px 6px;
   }
   ```

   Gives rounded corners and a border, but Qt style sheets do **not** support
   `box-shadow`. Applying QSS also switches the tooltip to `QStyleSheetStyle`
   rendering and can make the corners look wrong without translucency.

2. **QProxyStyle (Breeze approach)** — more code, but the proper way:

   - `polish(QWidget *)`: if `widget->inherits("QTipLabel")`, set
     `Qt::WA_TranslucentBackground`.
   - `pixelMetric(PM_ToolTipLabelFrameWidth)`: reserve margin for the shadow.
   - `styleHint(SH_ToolTip_Mask)`: return a rounded mask, or `false` and let
     antialiased alpha define the shape.
   - `drawPrimitive(PE_PanelTipLabel)`: draw the shadow (blurred rounded rects
     or a cached 9-slice pixmap) followed by the rounded panel.

   CsoundQt already wraps the application style in `DialogButtonStyle`
   (`src/widgetstyle.h`), so these overrides can live there. Restrict them to
   the Fusion base style (`baseStyle()->objectName() == "Fusion"`) so native
   styles and Breeze keep their own tooltip rendering.

**Caveats**

- Translucency needs a compositing window manager; without one the shadow area
  can appear black. Keep a non-composited fallback (opaque rounded/plain tip).
- Must work in both light and dark application palettes and at high DPI.
- The tooltip wrapping in `src/tooltiphelper.h` must keep working; the style
  should not assume single-line text.
- Test with `QToolTip::showText()` and with `QWidget::setToolTip()`.

**References**

- Qt: `src/widgets/kernel/qtooltip.cpp` (`QTipLabel::paintEvent`,
  `QTipLabel::resizeEvent`).
- Qt: `QCommonStyle::drawPrimitive(PE_PanelTipLabel)`.
- KDE Breeze: `kstyle/breezestyle.cpp` — `polish()` special-cases `QTipLabel`
  and `renderToolTip()` draws the rounded, shadowed background.
