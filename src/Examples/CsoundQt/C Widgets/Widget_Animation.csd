<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; ---------------------------------------------------------------
; Widget Animation demo
;
; Instrument 99 animates widgets at a display rate using
;     outvalue "<channel>/<property>", <value>
; where <property> is the name of a widget property WITHOUT the
; internal "CSQT_" prefix (see the "Show Properties" button in a
; widget's Properties dialog for the list of a widget's properties).
;
; Properties can be changed with numbers (position, size, visibility,
; value, ...) or strings (colour, text, ...). A property message never
; changes the widget's current value, so you can move/recolour a knob
; while it keeps controlling a Csound channel.
; ---------------------------------------------------------------

sr     = 44100
ksmps  = 64
nchnls = 2
0dbfs  = 1

instr 1
  ; a small synth driven by the "amp" and "cutoff" widgets
  kamp = chnget("amp")
  kcut = chnget("cutoff")
  if kamp == 0 then
    kamp = 0.4
  endif
  if kcut == 0 then
    kcut = 0.6
  endif
  kcut port kcut, 0.05
  a1 vco2 kamp*0.22, 110
  a2 vco2 kamp*0.14, 110.7
  aout = (a1 + a2) * 0.5
  aout butlp aout, 150 + 7000*kcut
  out aout, aout
endin

; short percussive hit, triggered by the button
instr 2
  a1 pluck 0.5, 220, 220, 0, 1
  a2 pluck 0.3, 440, 440, 0, 1
  a3 pluck 0.2, 660, 660, 0, 1
  aout = (a1 + a2 + a3) * 0.5
  aout *= linsegr:a(0, 0.001, 1, 0.2, 0)
  
  out aout, aout
endin

instr 99
  kt = eventtime()
  kamp = chnget("amp")
  
  ; All property messages are sent at ~30 Hz (a display rate), not at k-rate.
  if metro(30) == 1 then

    ; --- colour: cycle a hex colour on three widgets ---
    kred = 127 + 120*sin(kt*0.8)
    kgrn = 127 + 120*sin(kt*1.1 + 2.1)
    kblu = 127 + 120*sin(kt*1.5 + 4.2)
    Scol = sprintfk("#%02x%02x%02x", kred, kgrn, kblu)
    outvalue "cutoff/color", Scol
    outvalue "meter/color",  Scol
    outvalue "status/color", Scol

    ; --- position: glide the "mover" knob around (kept in the left column) ---
    kx = 15 + 80*(0.5 + 0.5*sin(kt*0.7))
    ky = 200 + 50*(0.5 + 0.5*sin(kt*1.0 + 1.0))
    outvalue "mover/x", int(kx)
    outvalue "mover/y", int(ky)
    ; ...and re-colour it in counter-phase
    Smcol = sprintfk("#%02x%02x%02x", 
                     120 + int(120*sin(kt*1.3)), 
                     120 + int(120*sin(kt*1.3 + 2.1)), 
                     120 + int(120*sin(kt*1.3 + 4.2)))
    outvalue "mover/color", Smcol

    ; --- size: pulse the meter width ---
    outvalue "meter/width", int(180 + 120*(0.5 + 0.5*sin(kt*1.7)))

    ; --- visibility: blink the button once a second ---
    outvalue "pulse/visible", (int(kt*1.5) % 2)

    ; --- text: show the elapsed time on the button ---
    Stext = sprintfk("t = %4.1f s", kt)
    outvalue "pulse/text", Stext

    ; feed the meter and the display with numeric channels
    chnset kamp, "meter"
    chnset kt, "status"
  endif
endin

</CsInstruments>
<CsScore>
i 1  0 3600
i 99 0 3600
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widget Animation</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>430</width>
 <height>313</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>235</r>
  <g>235</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>6</y>
  <width>420</width>
  <height>30</height>
  <uuid>{a0000000-0000-4000-8000-000000000001}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Widget Animation Demo</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Arial</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>20</g>
   <b>40</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>40</y>
  <width>420</width>
  <height>50</height>
  <uuid>{a0000000-0000-4000-8000-000000000002}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Instrument 99 changes widget properties with outvalue "channel/property": colour (cutoff, meter, status, mover), position (mover, x/y), width (meter), visibility and text (pulse). The cutoff knob and amp slider still work normally.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>20</g>
   <b>40</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>cutoff</objectName>
  <x>20</x>
  <y>95</y>
  <width>90</width>
  <height>90</height>
  <uuid>{a0000000-0000-4000-8000-000000000003}</uuid>
  <widgetName>cutoff</widgetName>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Filter cutoff. Its colour is animated from Csound.</description>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.19960000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>164</r>
   <g>92</g>
   <b>118</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>amp</objectName>
  <x>125</x>
  <y>95</y>
  <width>300</width>
  <height>24</height>
  <uuid>{a0000000-0000-4000-8000-000000000004}</uuid>
  <widgetName>amp</widgetName>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Amplitude.</description>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.29666667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>meter</objectName>
  <x>125</x>
  <y>127</y>
  <width>223</width>
  <height>30</height>
  <uuid>{a0000000-0000-4000-8000-000000000005}</uuid>
  <widgetName>meter</widgetName>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Level meter whose colour and width are animated.</description>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.29666667</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>border</bordermode>
  <borderColor>#5cb490</borderColor>
  <color>
   <r>164</r>
   <g>92</g>
   <b>118</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>225</r>
   <g>225</g>
   <b>230</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>status</objectName>
  <x>125</x>
  <y>165</y>
  <width>150</width>
  <height>38</height>
  <uuid>{a0000000-0000-4000-8000-000000000006}</uuid>
  <widgetName>status</widgetName>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Elapsed time. Its colour is animated.</description>
  <label>3.533</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Mono</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>164</r>
   <g>92</g>
   <b>118</b>
  </color>
  <bgcolor mode="background">
   <r>221</r>
   <g>240</g>
   <b>226</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>pulse</objectName>
  <x>290</x>
  <y>165</y>
  <width>135</width>
  <height>38</height>
  <uuid>{a0000000-0000-4000-8000-000000000007}</uuid>
  <widgetName>pulse</widgetName>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Triggers a hit. Its visibility and text are animated.</description>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>t =  3.5 s</text>
  <image>/</image>
  <eventLine>i 2 0 4</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>mover</objectName>
  <x>79</x>
  <y>200</y>
  <width>100</width>
  <height>100</height>
  <uuid>{a0000000-0000-4000-8000-000000000008}</uuid>
  <widgetName>mover</widgetName>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Moved around and re-coloured from Csound (no channel value is changed).</description>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.54000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>1</r>
   <g>167</g>
   <b>190</b>
  </color>
  <textcolor>#003040</textcolor>
  <border>2</border>
  <borderColor>#003040</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
