<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

; Two labels in this panel use Markdown: the description label is static, the
; "live" label is updated from Csound. Labels are addressed by their widget
; Name (not by a channel), so the update uses outvalue "live/label".
instr 1
  kPhase = phasor:k(0.25)
  kTrig = metro(4)
  if kTrig == 1 then
    Stext sprintfk "**Live value:** `%.3f`", kPhase
    outvalue "live/label", Stext
  endif
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>120</x>
 <y>100</y>
 <width>640</width>
 <height>470</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#f4f4f4</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>8</y>
  <width>620</width>
  <height>46</height>
  <uuid>{c23a4ea6-61d1-4f11-8f9b-9b8440a8d0a1}</uuid>
  <widgetName>title</widgetName>
  <visible>true</visible>
  <enabled>true</enabled>
  <description/>
  <label># Markdown Labels</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>18</fontsize>
  <padding>4</padding>
  <textformat>markdown</textformat>
  <locked>false</locked>
  <color>#232627</color>
  <bgcolor mode="nobackground">#f4f4f4</bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>58</y>
  <width>620</width>
  <height>330</height>
  <uuid>{6d8e2e0b-3e35-4d20-81a6-1c48bb2f4f5b}</uuid>
  <widgetName>description</widgetName>
  <visible>true</visible>
  <enabled>true</enabled>
  <description/>
  <label>A label renders **Markdown** when its *Text Format* is set to
**Markdown** in the properties dialog.

## Features

- **Bold**, *italic* and ~~strikethrough~~
- `inline code` and intervening paragraphs
- Lists, tables and links
- Headings that scale with the label's font size

| Markdown | Result |
|----------|--------|
| `**text**` | **text** |
| `*text*` | *text* |
| `[CsoundQt](https://csoundqt.github.io/)` | a link |

> The label's own font, size and colour still apply. Markdown has no syntax
> for per-word colours; use the label's Text Color for a global colour.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>14</fontsize>
  <padding>6</padding>
  <textformat>markdown</textformat>
  <locked>false</locked>
  <color>#232627</color>
  <bgcolor mode="nobackground">#f4f4f4</bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>396</y>
  <width>620</width>
  <height>60</height>
  <uuid>{a6d9c2f7-0d24-44b6-bd7a-3d9f4b8c1e52}</uuid>
  <widgetName>live</widgetName>
  <visible>true</visible>
  <enabled>true</enabled>
  <description/>
  <label>**Live value:** waiting...</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>16</fontsize>
  <padding>6</padding>
  <textformat>markdown</textformat>
  <locked>false</locked>
  <color>#1f5f8b</color>
  <bgcolor mode="background">#e4eef5</bgcolor>
  <bordercolor>#9dbfd4</bordercolor>
  <bordermode>true</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
