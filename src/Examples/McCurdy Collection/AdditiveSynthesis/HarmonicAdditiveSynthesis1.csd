; Written by Iain McCurdy, 2006
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

; Notes on modifications from original csd:
; Add table(s) for exp slider
; Instrument 1 is activated by MIDI and by the GUI

; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
; --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 48000  ; Sample rate
ksmps  = 64     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


gisine     ftgen 0, 0, 4096, 10, 1                  ; A sine wave
giExp10000 ftgen 0, 0, 129, -25, 0, 20, 128, 10000  ; Table for exp slider


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkPartAmp1  invalue "PartAmp1"
    gkPartAmp2  invalue "PartAmp2"
    gkPartAmp3  invalue "PartAmp3"
    gkPartAmp4  invalue "PartAmp4"
    gkPartAmp5  invalue "PartAmp5"
    gkPartAmp6  invalue "PartAmp6"
    gkPartAmp7  invalue "PartAmp7"
    gkPartAmp8  invalue "PartAmp8"
    gkPartAmp9  invalue "PartAmp9"
    gkPartAmp10 invalue "PartAmp10"
    gkfund      invalue "Fund_Freq"
    gkfund tablei gkfund, giExp10000, 1
    outvalue "Fund_Freq_Value", gkfund
    gkamp  invalue "Amplitude"
    gkwarp invalue "Warp"
    gkrnd  invalue "Rnd"
  endif
endin

instr 2           ; Partial spacings random factors (always on)
  irnd1  gauss 1  ; Random factors
  irnd2  gauss 1  ; Random factors
  irnd3  gauss 1  ; Random factors
  irnd4  gauss 1  ; Random factors
  irnd5  gauss 1  ; Random factors
  irnd6  gauss 1  ; Random factors
  irnd7  gauss 1  ; Random factors
  irnd8  gauss 1  ; Random factors
  irnd9  gauss 1  ; Random factors
  irnd10 gauss 1  ; Random factors

  gkrnd1  = 1+(irnd1*gkrnd)
  gkrnd2  = 1+(irnd2*gkrnd)
  gkrnd3  = 1+(irnd3*gkrnd)
  gkrnd4  = 1+(irnd4*gkrnd)
  gkrnd5  = 1+(irnd5*gkrnd)
  gkrnd6  = 1+(irnd6*gkrnd)
  gkrnd7  = 1+(irnd7*gkrnd)
  gkrnd8  = 1+(irnd8*gkrnd)
  gkrnd9  = 1+(irnd9*gkrnd)
  gkrnd10 = 1+(irnd10*gkrnd)
endin

instr 1                  ; Synthesis instrument
  if p4 != 0 then        ; MIDI
    ioct = p4            ; Read oct value from MIDI input
    iamp = p5 * 0.5      ; Read in a note velocity value from the MIDI input
    kamp = iamp * gkamp  ; Set kamp to MIDI key velocity multiplied by slider value gkamp

    ; Pitch
    ; bend===========================================================================================================================================================
    ; Pitch bend range in semitones (will be defined further later) - suggestion - this
    ; could be controlled by a counter
    iSemitoneBendRange = 2
    imin               = 0  ; Equilibrium position
    ; Max pitch displacement (in oct format)
    imax = iSemitoneBendRange * .0833333
    ; Pitch bend variable (in oct format)
    kbend pchbend imin, imax
    kfund = cpsoct(ioct + kbend)
    ; =====================================================================================================================================================================
  else                ; GUI
    iporttime = 0.05  ; Portamento time variable
    ; Create a ramping up function to represent portamento time
    kporttime linseg 0, 0.001, iporttime, 1, iporttime
    kfund portk gkfund, kporttime  ; Apply portamento smoothing
    kamp  portk gkamp, kporttime   ; Apply portamento smoothing
  endif

  ; Separate oscillators create each of the partials. Each partial follows the harmonic
  ; series
  ; Output opcode amplitude | frequency | function_table
  apart1 oscili kamp*gkPartAmp1, kfund * gkrnd1, gisine                     ; Fundemental
  apart2 oscili kamp*gkPartAmp2, (kfund+(kfund*gkwarp)) * gkrnd2, gisine    ; 1St harmonic
  apart3 oscili kamp*gkPartAmp3, (kfund+(kfund*2*gkwarp)) * gkrnd3, gisine  ; 2Nd harmonic
  apart4 oscili kamp*gkPartAmp4, (kfund+(kfund*3*gkwarp)) * gkrnd4, gisine  ; 3Rd harmonic
  apart5 oscili kamp*gkPartAmp5, (kfund+(kfund*4*gkwarp)) * gkrnd5, gisine  ; 4Th harmonic
  apart6 oscili kamp*gkPartAmp6, (kfund+(kfund*5*gkwarp)) * gkrnd6, gisine  ; 5Th harmonic
  apart7 oscili kamp*gkPartAmp7, (kfund+(kfund*6*gkwarp)) * gkrnd7, gisine  ; 6Th harmonic
  apart8 oscili kamp*gkPartAmp8, (kfund+(kfund*7*gkwarp)) * gkrnd8, gisine  ; 7Th harmonic
  apart9 oscili kamp*gkPartAmp9, (kfund+(kfund*8*gkwarp)) * gkrnd9, gisine  ; 8Th harmonic
  ; 9Th harmonic
  apart10 oscili kamp*gkPartAmp10, (kfund+(kfund*9*gkwarp)) * gkrnd10, gisine

  ; Sum the 10 oscillators:
  amix sum apart1, \
    apart2, \
    apart3, \
    apart4, \
    apart5, \
    apart6, \
    apart7, \
    apart8, \
    apart9, \
    apart10
  ; Create an amplitude envelope with 'anti click' attack and a release segment
  aenv linsegr 0, 0.01, 1, 0.1, 0
  ; Send mixed signal multiplied by the amplitude envelope to the outputs
  outs amix*aenv, amix*aenv
endin

instr 4  ; Set warp slider to '1'
  outvalue "Warp", 1
endin
</CsInstruments>
<CsScore>
; Partial spacings random factors instruments play a note for 1 hour (and keeps
; performance going)
i 2 0 3600
i 10 0 3600  ; GUI
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>1014</width>
 <height>432</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>600</width>
  <height>430</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Additive Synthesis 1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>211</r>
   <g>211</g>
   <b>211</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>9</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a2478686-0cb1-4081-896c-03397bd19331}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.59600000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>347</y>
  <width>276</width>
  <height>31</height>
  <uuid>{ab0e7272-d733-4ebb-bb0e-5be83cf2d34d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1      2      3      4      5      6      7      8      9     10 </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>33</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{fdb44389-5b7d-408b-86f5-c6817a697505}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.72432812</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>57</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{20a90144-827d-437e-8a8f-9c6cd9e2a87f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.38415625</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>81</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{92d15a4b-d582-4ae2-8fb2-c0993d808c34}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.90156250</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>105</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{9a9e0651-0fc3-4772-ab39-364cac49aaae}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.42148438</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>129</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{dec8a20a-eadd-4a93-a400-bcb352406930}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.75468750</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>153</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{821ddbec-2c2c-418b-bef2-233c1c69fb97}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.23726563</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>177</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{238d4c2c-a4cd-4595-bfed-328db8c4bddf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.59900000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>201</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{90c161db-14bf-4937-b50b-44a6002eb02b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp9</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.34485937</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>225</x>
  <y>94</y>
  <width>20</width>
  <height>250</height>
  <uuid>{95e1897f-d796-4dba-8b9c-f382985a0a57}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>PartAmp10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.81610938</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b1975</objectName>
  <x>8</x>
  <y>8</y>
  <width>176</width>
  <height>55</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>ON: GUI
OFF: MIDI</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Fund_Freq</objectName>
  <x>254</x>
  <y>107</y>
  <width>341</width>
  <height>27</height>
  <uuid>{086a860c-b45b-47f3-978f-2f6daac6338b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41642229</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>254</x>
  <y>129</y>
  <width>298</width>
  <height>29</height>
  <uuid>{109a592d-ca0d-4b82-bf17-3b42c0ff503a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Fundamental (Hertz)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Fund_Freq_Value</objectName>
  <x>515</x>
  <y>129</y>
  <width>80</width>
  <height>23</height>
  <uuid>{30f36f54-9085-46d0-8f1f-4a4b89881919}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>61.923</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>1</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Amplitude</objectName>
  <x>254</x>
  <y>163</y>
  <width>341</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.31671554</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>254</x>
  <y>185</y>
  <width>298</width>
  <height>29</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Global Amplitude</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Amplitude</objectName>
  <x>515</x>
  <y>185</y>
  <width>80</width>
  <height>23</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.317</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Warp</objectName>
  <x>254</x>
  <y>218</y>
  <width>341</width>
  <height>27</height>
  <uuid>{e4300af9-24c6-4b70-93ab-c970819d2c35}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>254</x>
  <y>240</y>
  <width>298</width>
  <height>29</height>
  <uuid>{34370953-ce7f-4ce0-a30a-87b8ad5b8d34}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Warp Partial Spacings</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Warp</objectName>
  <x>551</x>
  <y>242</y>
  <width>44</width>
  <height>21</height>
  <uuid>{9df2c1be-0396-40aa-bcb5-aae3a5654e10}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1.000</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Rnd</objectName>
  <x>254</x>
  <y>273</y>
  <width>341</width>
  <height>27</height>
  <uuid>{3fe7d249-f69e-4927-b101-437a44586552}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>254</x>
  <y>295</y>
  <width>298</width>
  <height>29</height>
  <uuid>{3d3bb9bb-d39c-49de-b313-7cd9e38557ef}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Partial Spacings Random Factor</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Rnd</objectName>
  <x>515</x>
  <y>295</y>
  <width>80</width>
  <height>23</height>
  <uuid>{604955bd-5b1c-457a-95ac-ff9bc1d7aaa0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.000</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>Reset</objectName>
  <x>486</x>
  <y>242</y>
  <width>66</width>
  <height>27</height>
  <uuid>{4bc80b9f-1a71-44f0-8669-5905e6cbda94}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Reset</text>
  <image>/</image>
  <eventLine>i 4 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>603</x>
  <y>2</y>
  <width>413</width>
  <height>430</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Additive Synthesis 1 - 10 Harmonics</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>211</r>
   <g>211</g>
   <b>211</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>606</x>
  <y>17</y>
  <width>408</width>
  <height>411</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>
Additive synthesis is the technique whereby sine waves of different frequencies are mixed and manipulated in such a way that they are perceived fused and seem to form a new, more complex tone. The inspiration for additive synthesis comes from Fourier theory that states that any sound can be replicated as a composite of sine waves of various frequencies and phases.  In harmonic additive synthesis the sequence of frequencies  followed by the different sine wave oscillators follows that of the harmonic series in that each harmonic is a product of the fundemental. For example: if the fundemental of a harmonic tone is 100 Hz. then its 1st harmonic will be at 200 Hz. its 2nd at 300 Hz and so on. This example offers the user manipulation of the first 10 harmonics but to synthesize bright timbres rich in higher harmonics such as a violin this number will be insufficient. The next example which utilises more partials, demonstrates  ways in which the fusion of partials can be enhanced but also draws attention to the shortcomings of additive synthesis. Note that the fundemental can also be referred to as the 1st partial, the 1 harmonic as the 2nd partial and so on. Partial spacings can be modified in two ways. 'Warp Partial  Spacings' compresses or expands partials spacings depending  upon whether its value is less than or greater than 1. 'Partial Spacings Random Factor' multiplies a unique random value to each partial frequency.                             </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>65</r>
   <g>65</g>
   <b>65</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>80</x>
  <y>365</y>
  <width>156</width>
  <height>31</height>
  <uuid>{495f1d8a-abb5-49dc-89af-5d52dc31b75f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Partial Strength</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
