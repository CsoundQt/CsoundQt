; Written by Iain McCurdy, 2011

; Modified for QuteCsound by René, May 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table for exp slider
; Add Browser for audio file and use of FilePlay2 udo, accept mono or stereo wav files
; Add denorm to moogladder input


; my flags on Ubuntu: -dm0 -iadc:system:capture_ -odac:system:playback_ -+rtaudio=jack
; -b16 -B4096 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


zakinit 4, 4

gisine ftgen 0, 0, 4096, 10, 1
gaCar   init 0
gk12_24 init 12

; Tables for exp slider
giExp1 ftgen 0, 0, 129, -25, 0, 0.01, 128, 1.0
giExp2 ftgen 0, 0, 129, -25, 0, 1.0, 128, 12.0
giExp3 ftgen 0, 0, 129, -25, 0, 0.1, 128, 50.0
giExp4 ftgen 0, 0, 129, -25, 0, 40.0, 128, 10000.0


; Mode udo (k-rate base frequency) - used for non-MIDI mode
opcode VocoderChannel, 0, aaiiiii
  aMod, aCar, ibase, ibw, iincr, icount, inum xin  ; Name input variables
  ; Derive frequency for *this* bandpass filter based on base frequency and filter number
  ; (icount)
  icf    = cpsmidinn(ibase+(icount*iincr))
  icount = icount + 1  ; Increment counter in prepartion for next filter
  ; Print data about filter number and frequency to the terminal
  prints "Band: %d %t Freq: %f \n", icount, icf

  ; If filter frequency exceeds a sensible limit skip the creation of this filter and end
  ; recursion
  if icf>15000 goto SKIP
  aModF butbp aMod, icf, ibw*icf     ; Bandpass filter modulator
  if gk12_24 = 24 then               ; If 24db per oct mode is chosen...
    aModF butbp aModF, icf, ibw*icf  ; ...Bandpass filter again to sharpen cutoff slopes
  endif                              ; End of this conditional branch
  aEnv follow2 aModF, 0.01, 0.01     ; Follow the envelope of the filtered audio

  aCarF butbp aCar, icf, ibw*icf     ; Bandpass filter carrier
  if gk12_24 = 24 then               ; If 24 db per oct is chosen...
    aCarF butbp aCarF, icf, ibw*icf  ; ...Bandpass filter again to sharpen cutoff slopes
  endif                              ; End of this conditional branch
  ; Mix filtered carrier into the accumulating zak audio channel and modulate its
  ; amplitude with the modulator envelope
  zawm aCarF*aEnv, 0

  if icount < inum then  ; If more filters still need to be created...
    ; ...Call udo again with incremented counter
    VocoderChannel aMod, aCar, ibase, ibw, iincr, icount, inum
  endif  ; End of this conditional branch
SKIP:    ; Label
endop    ; End of udo

opcode FilePlay2, aa, Skoo  ; Credit to Joachim Heintz
  ; gives stereo output regardless your soundfile is mono or stereo
  Sfil, kspeed, iskip, iloop xin
  ichn filenchnls Sfil
  if ichn == 1 then
    aL diskin2 Sfil, kspeed, iskip, iloop
    aR = aL
  else
    aL, aR diskin2 Sfil, kspeed, iskip, iloop
  endif
  xout aL, aR
endop


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    ; Spinboxes
    gkbase  invalue "BaseNote"
    gknum   invalue "NumBands"
    gk12_24 invalue "dBperOct"
    ; Menus
    gkModIn   invalue "ModIn"
    gkCarIn   invalue "CarIn"
    gkSynType invalue "SynType"
    ; Sliders
    kbw invalue "Bandwidth"
    gkbw tablei kbw, giExp1, 1
    outvalue "Bandwidth_Value", gkbw
    kincr invalue "BandSpacing"
    gkincr tablei kincr, giExp2, 1
    outvalue "BandSpacing_Value", gkincr
    kBPGain invalue "BPGain"
    gkBPGain tablei kBPGain, giExp3, 1
    outvalue "BPGain_Value", gkBPGain
    kHPGain invalue "HPGain"
    gkHPGain tablei kHPGain, giExp3, 1
    outvalue "HPGain_Value", gkHPGain
    kLPF invalue "LPF"
    gkLPF tablei kLPF, giExp4, 1
    outvalue "LPF_Value", gkLPF
    gkres invalue "Res"

    Sfile_new strcpy ""  ; Init to empty string
    gSfile invalue "_Browse"
    Sfile_old strcpyk Sfile_new
    Sfile_new strcpyk gSfile
    gkfile strcmpk Sfile_new, Sfile_old
  endif

  turnon 2  ; Vocoder plays
endin

instr 1                             ; Simple MIDI synth
  icps cpsmidi                      ; Read MIDI note in cps format
  aenv linsegr 0, 0.01, 1, 0.02, 0  ; Create a simple gate-type envelope

  if gkSynType = 0 then      ; If synth type chosen from button bank GUI is sawtooth...
    a1 vco2 1, icps          ; ...Create a sawtooth wave tone
  elseif gkSynType = 1 then  ; If synth type chosen from button bank GUI is square...
    a1 vco2 1, icps, 2, 0.5  ; ...Create a square wave tone
  elseif gkSynType = 2 then  ; If synth type chosen from button bank GUI is pulse...
    a1 vco2 1, icps, 2, 0.1  ; ...Create a pulse wave tone
  else                       ; Otherwise...
    a1 pinkish 1             ; ...Create some pink noise
  endif                      ; End of this conditional branch
  gaCar = gaCar + (a1*aenv)  ; Apply envelope
endin

instr 2  ; Vocoder
  ; If any of the input variable are changed generate a momentary '1' value (a bang in
  ; max-msp language)
  ktrig changed gkbase, gkbw, gknum, gkincr, gkfile
  if ktrig = 1 then     ; If a changed value trigger is received...
    reinit UPDATE       ; Reinitialise this instrument from the label 'update'
  endif                 ; End of this conditional branch
UPDATE:                 ; Label
  ibase init i(gkbase)  ; Create an initialisation time variable from GUI control
  inum  init i(gknum)   ; Create an initialisation time variable from GUI control
  ibw   init i(gkbw)    ; Create an initialisation time variable from GUI control
  iincr init i(gkincr)  ; Create an initialisation time variable from GUI control

  if gkModIn = 0 then                      ; If modulator input chosen is 'audio file'...
    aMod, asigR FilePlay2 gSfile, 1, 0, 1  ; ...Read in a sound file from hard disk
  else                                     ; Otherwise...
    ; Read live audio from the computer's left input channel
    aMod inch 1
  endif  ; End of this conditional branch

  denorm gaCar  ; to avoid high cpu load on my intel box !!!

  if gkCarIn = 0 then  ; If 'internal synth' is chosen for carrier input...
    ; ... Use internal synth audio from instr 1 and apply a low pass filter
    aCar moogladder gaCar, gkLPF, gkres
  else           ; Otherwise...
    aCar inch 2  ; Read live audio from the computer's right channel input channel
  endif          ; End of this conditional branch

  icount init 0  ; Initialise the filter counter to zero
  ; Call 'vocoderchannel' udo - (will recurse within the udo itself for thew required
  ; number of filters
  VocoderChannel aMod, aCar, ibase, ibw, iincr, icount, inum
  amix zar 0  ; Read combined filters output from zak channel

  ; High-pass channel
  ; Highpass filter cutoff (one increment above the highest bandpass filter)
  iHPcf = cpsmidinn(ibase+(inum*iincr)+1)
  iHPcf limit iHPcf, 2000, 18000  ; Limit the highpass filter to be within sensible limits
  ; Print information about the highpass filter curopff to the terminal
  prints "HPF %t%t Freq: %f \n", iHPcf

  aModHP buthp aMod, iHPcf  ; Highpass filter the modulator
  ; Follow the highpass filtered modulator's amplitude envelope
  aEnv follow2 aModHP, 0.01, 0.01
  aCarHP buthp aCar, iHPcf  ; Highpass filter the carrier
  ; Mix the highpass filtered carrier with the bandpass filters. Apply the modulator's
  ; envelope.
  amix = (amix*gkBPGain)+(aCarHP*aEnv*gkHPGain)

  outs amix, amix  ; Send audio to the outputs
  zacl 0, 4
  ; Clear the internal synth accumulating global variable, read for the next perf. Pass
  clear gaCar
  ; Return from reinitialisation pass. (not really need as the endin fulfils the same
  ; function.)
  rireturn
endin

instr 11  ; Init
  outvalue "BaseNote", 40
  outvalue "NumBands", 50
  outvalue "dBperOct", 24
  outvalue "Bandwidth", 0.7
  outvalue "BandSpacing", 0.165
  outvalue "BPGain", 0.482
  outvalue "HPGain", 0.8063
  outvalue "LPF", 0.8745
  outvalue "Res", 0.0
endin
</CsInstruments>
<CsScore>
i 10 0 3600  ; GUI
i 11 0 0     ; Init
</CsScore>
</CsoundSynthesizer>



<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>329</x>
 <y>160</y>
 <width>1036</width>
 <height>602</height>
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
  <width>1034</width>
  <height>600</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> Analogue Style Vocoder</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="background">
   <r>53</r>
   <g>62</g>
   <b>117</b>
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
  <x>9</x>
  <y>125</y>
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Band Spacing (semitones)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>BandSpacing</objectName>
  <x>9</x>
  <y>102</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.16500001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>BandSpacing_Value</objectName>
  <x>449</x>
  <y>125</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1.507</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>72</y>
  <width>200</width>
  <height>30</height>
  <uuid>{78a7e9cd-fb57-421c-8e1f-40b60a90dfc0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Bandwidth (octaves)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Bandwidth</objectName>
  <x>9</x>
  <y>49</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4b5d3fba-55d0-43d1-a94a-457bc9144a31}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Bandwidth_Value</objectName>
  <x>449</x>
  <y>72</y>
  <width>60</width>
  <height>30</height>
  <uuid>{58265963-6245-459e-8071-9ed8bba850a4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.251</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>231</y>
  <width>200</width>
  <height>30</height>
  <uuid>{1c02d7bd-4198-417f-a816-a560f4133e23}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Highpass Filter Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>HPGain</objectName>
  <x>9</x>
  <y>208</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e5fa660d-82a5-412a-a76a-500a0632ee0c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80629998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>HPGain_Value</objectName>
  <x>449</x>
  <y>231</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8341c14a-4acb-4d3d-824f-675147975768}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>15.006</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>178</y>
  <width>200</width>
  <height>30</height>
  <uuid>{fd3ea893-7f4f-4d74-a6c6-2ed00b696056}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Bandpass Filters Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>BPGain</objectName>
  <x>9</x>
  <y>155</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3911e6c3-0337-45b0-81d8-e63c67cae1f3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.48199999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>BPGain_Value</objectName>
  <x>449</x>
  <y>178</y>
  <width>60</width>
  <height>30</height>
  <uuid>{78473677-bb47-45c2-bf88-fa6930dca759}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>2.000</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d7f5620d-8a05-4982-8edb-af45fcc4611c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Base Note</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>291</y>
  <width>1026</width>
  <height>301</height>
  <uuid>{3d230d57-2e7b-4bd4-8175-e6a7da3e9e07}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This is an implementation of a traditional analogue style vocoder.
Two audio signals, referred to as a modulator and a carrier, are passed into the vocoder effect. The modulator is is typically a voice and the carrier is typically a synthesizer. The modulator is analysed by being passed into multiband filter (bank of bandpass filters), the amplitude envelope of each band is tracked and a control function for each band generated. The carrier signal is also passed through a matching multiband filter, the set of amplitude envelopes derived from the modulator analysis is applied to outputs of this second multiband filter. In this implementation the user can vary the 'Base Note' or the frequency of the lowermost filter expressed as a MIDI note value. The number of filters in both filter banks can be varied as can the spacing between adjacent filters, expressed in semitones, and the bandwidth of the filters, expressed as a fraction of an octave. Whenever changes are made to these controls the vocoder instrument reinitializes itself and at the same time checks if any of the filter frequencies will exceed the nyquist frequency, in which case they will be omitted. For this reason the actual number of filters implemented may not be the number asked for using the GUI counter. Filter frequency data is printed to the terminal each time a change is made. The uppermost band of the filter bank is always a highpass filter. This is to allow high frequency sibilants to be in modulator to be accurately represented. In this implementation the user can choose between two internal sound files and the computer's live audio input as modulator source. If 'microphone' is chosen then audio is read from the computer's left input channel. For carrier signal there is a simple built-in synth with four waveform options and a resonant lowpass filter (moogladder). This internal synth is ideally played from an external MIDI keyboard - modify &lt;CsOptions> accordingly.
If 'External' is chosen then audio is taken from the computer's right channel input. You can connect you own hardware synthesizer here. Filter creation is controlled using a UDO with recursion so that the number of filters can be changed without having to rewrite code. The filter slopes are switchable between 12 dB per octave and 24 dB per octave. Choosing 24 dB per octave effectively doubles the number of filters used as for each band two series filters are used instead of one. Older computers may struggle in realtime with 24 dB per octave when combined with large number of filters.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>517</x>
  <y>49</y>
  <width>512</width>
  <height>95</height>
  <uuid>{0084c854-b62e-4a4d-8290-1d7db3f769e5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Modulator</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>522</x>
  <y>106</y>
  <width>170</width>
  <height>30</height>
  <uuid>{553ef759-a6a8-4856-8b44-e46a7916ad88}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse</objectName>
  <x>693</x>
  <y>107</y>
  <width>330</width>
  <height>28</height>
  <uuid>{d99fb6e8-ff26-4114-994b-4a3d44cdb7bc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.000</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>522</x>
  <y>85</y>
  <width>150</width>
  <height>30</height>
  <uuid>{43f7116d-e6bc-4121-a7d8-624b37846007}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Audio File</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>ModIn</objectName>
  <x>813</x>
  <y>57</y>
  <width>210</width>
  <height>30</height>
  <uuid>{56035bec-5d19-4dfe-95e2-4eba077267e8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Micophone (Left Channel)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>BaseNote</objectName>
  <x>109</x>
  <y>260</y>
  <width>60</width>
  <height>30</height>
  <uuid>{66a00915-8240-4189-b441-9cc8399d70aa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>24</minimum>
  <maximum>80</maximum>
  <randomizable group="0">false</randomizable>
  <value>40</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>169</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2ff0a3cd-f045-46fa-bcbc-4f44ee7fb423}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Num. Bands</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>NumBands</objectName>
  <x>269</x>
  <y>260</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa29e343-5d22-4238-bb99-a1a9ba851b2d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>50</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>329</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7ba7c4e3-eaeb-4036-b014-11c0c41d483c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB per Oct</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>dBperOct</objectName>
  <x>429</x>
  <y>260</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e6b15ddb-b975-49ae-9770-d82aefa41f83}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>12</minimum>
  <maximum>24</maximum>
  <randomizable group="0">false</randomizable>
  <value>24</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>517</x>
  <y>151</y>
  <width>512</width>
  <height>140</height>
  <uuid>{c9a8a317-ee56-436a-aefb-5ce9e2816aef}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Carrier</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>CarIn</objectName>
  <x>522</x>
  <y>192</y>
  <width>210</width>
  <height>30</height>
  <uuid>{87392937-db97-42d1-8890-d619532257bb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Internal Synth</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>External (Right Channel)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>SynType</objectName>
  <x>902</x>
  <y>192</y>
  <width>120</width>
  <height>30</height>
  <uuid>{1eca9d44-ace2-4e49-b0ec-ced60019042b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sawtooth</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pulse</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Noise</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>780</x>
  <y>192</y>
  <width>120</width>
  <height>30</height>
  <uuid>{fc6f50d0-1a2d-471c-9b93-792a6fccca9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Internal Synth Wave</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>LPF</objectName>
  <x>556</x>
  <y>252</y>
  <width>200</width>
  <height>12</height>
  <uuid>{9af6561a-c1a5-4ea2-8e69-24b2ece53fd1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.87449998</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>80</r>
   <g>177</g>
   <b>80</b>
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
  <x>517</x>
  <y>248</y>
  <width>40</width>
  <height>24</height>
  <uuid>{0925f33c-4729-4fd1-8a2a-53ce834d94b8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>LPF</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Res</objectName>
  <x>820</x>
  <y>252</y>
  <width>200</width>
  <height>12</height>
  <uuid>{e2a71ace-794e-42ac-b3d9-f3ffa358cdb6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>80</r>
   <g>177</g>
   <b>80</b>
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
  <x>780</x>
  <y>248</y>
  <width>40</width>
  <height>24</height>
  <uuid>{99ee820d-dc5e-4f4c-9005-7fa02564ae07}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Res</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
