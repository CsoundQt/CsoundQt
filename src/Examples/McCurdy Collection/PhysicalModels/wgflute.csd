; Written by Iain McCurdy, 2006

; Demonstration of the wgflute opcode which is based on perry cook's physical model of a
; flute

; This opcode offers a lot of input parameters

; Kamp - amplitude

; Kfreq - the fundemental of the tone produced

; Kjet - a parameter controlling the air jet. Values should be positive, and about 0.3.
; The useful range is approximately 0.08 to 0.56
; Low settings for kjet force overtones from the instrument
; This is probably the most insteresting parameter in this opcode

; Iatt/idek - attack and decay times apparently but they don't seem to do anything at all
; as far as i can see!

; Kngain - amplitude of breath/wind noise. The flute sound consists of 2 main elements:
; The resonant tone and the breath noise.
; This parameter controls the strength of the breath/wind noise.
; A useful range for this is about 0-1
; 0=No breath noise, 1=breath noise only

; Kvibf/kvibamp - this opcode implements vibrato that goes beyond just frequency
; modulation and includes modulation
; -Upon several other aspects of the sound including amplitude modulation
; A useful range for kvibamp (amplitude of vibrato) is 0-.25 where 0=no vibrato and .25=a
; lot of vibrato
; Kvibf is used to control vibrato frequency, a natural vibrato frequency is about 5 hz

; Ifn - a function table waveform must be given to define the shape of the vibrato,
; -This should normally be a sine wave.

; The opcode offers 3 further *optional* parameters:

; Iminfreq - a minimum frequency setting given to the algorithm
; - Typically this is set to a value below the frequency setting given by kfreq
; - If kfreq goes below iminfreq is can have a strange effect on the sound and the setting
; for kfreq no longer
; -Reflects the pitch that is actually heard.

; Ijetrf - amount of reflection of the breath jet. I.e. Resistance of the air column on
; the flute (i-rate only)

; Iendrf - breath jet reflection coefficient (i-rate only) this controls how the breath
; jet interacts with the resonant sound
; - 0=Breath jet dominates 1=resonance dominates


; Modified for QuteCsound by René, March 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


; Notes on modifications from original csd:
; Add tables for exp slider
; INIT instrument added


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


gisine ftgen 0, 0, 131072, 10, 1                    ; Sine wave (used for vibrato)
giExp1 ftgen 0, 0, 129, -25, 0, 20.0, 128, 20000.0  ; Table for exp slider


instr 2  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkamp invalue "Amp"
    kfreq invalue "Freq"
    gkfreq tablei kfreq, giExp1, 1
    outvalue "Freq_Value", gkfreq
    gkjet    invalue "AirJet"
    gkatt    invalue "Attack"
    gkdek    invalue "Decay"
    gkngain  invalue "AmpNoise"
    gkvibf   invalue "VibFreq"
    gkvibamp invalue "VibAmp"
    kminfreq invalue "MinFreq"
    gkminfreq tablei kminfreq, giExp1, 1
    outvalue "MinFreq_Value", gkminfreq
    gkjetrf invalue "AmtRefJet"
    gkendrf invalue "CoefRefJet"
  endif
endin

instr 1           ; MIDI activated instrument
  ioct octmidi    ; Read note values from MIDI input in the 'oct' format
  iamp ampmidi 1  ; Amplitude is read from incoming MIDI note

  ; Pitch bend information is read
  ; Pitch bend range in semitones (will be defined further later)
  iSemitoneBendRange = 2
  imin               = 0  ; Equilibrium position
  ; Max pitch displacement (in oct format)
  imax = iSemitoneBendRange * .0833333
  ; Pitch bend variable (in oct format)
  kbend pchbend imin, imax
  kfreq = cpsoct(ioct+ kbend)
  ; Waveform function table for the shape of the vibrato - should normally just be a sine
  ; wave or something similar
  ifn = 1
  ; Generate a momentary '1' value through variable kswitch if any of its input variable
  ; change
  kSwitch changed gkminfreq, gkjetrf, gkendrf, gkatt, gkdek
  if kSwitch = 1 then  ; If i-rate variable change trigger is '1'...
    reinit UPDATE      ; Begin a reinitialisation pass from label 'update'
  endif
UPDATE:
  ; An audio signal is created using the wgflute opcode. Note that i-rate variables must
  ; be converted to i-rate from k-rate sliders
  aflute wgflute gkamp*iamp, kfreq, gkjet, i(gkatt), i(gkdek), gkngain, gkvibf, gkvibamp, gisine, i(gkminfreq), i(gkjetrf), i(gkendrf)
  rireturn  ; Return from a reinitialization pass to performance time passes
  ; This envelope, although not used as a control signal for anything, serves to keep the
  ; instrument running after a note of has been received to facilitate the deccay time for
  ; wgclar
  aenv linsegr 1, i(gkdek), 0
  outs aflute * aenv, aflute * aenv  ; Send audio outputs
endin

instr 3  ; GUI activated instrument
  ; This envelope, although not used as a control signal for anything, serves to keep the
  ; instrument running after a note of has been received to facilitate the deccay time for
  ; wgclar
  aenv linsegr 1, i(gkdek), 0
  ; Generate a momentary '1' value through variable kswitch if any of its input variable
  ; change
  kSwitch changed gkminfreq, gkjetrf, gkendrf, gkatt, gkdek
  if kSwitch = 1 then  ; IF kSwitch=1 THEN...
    reinit UPDATE      ; Begin a reinitialization pass from the given label
  endif                ; Label
UPDATE:
  ; An audio signal is created using the wgflute opcode. Note that i-rate variables must
  ; be converted to i-rate from k-rate sliders
  aflute wgflute gkamp, gkfreq, gkjet, i(gkatt), i(gkdek), gkngain, gkvibf, gkvibamp, gisine, i(gkminfreq), i(gkjetrf), i(gkendrf)
  ; Return from a reinitialization pass to performance time passes
  rireturn
  outs aflute * aenv, aflute * aenv  ; Send audio outputs
endin

instr 4  ; Init
  outvalue "Amp", 0.2
  outvalue "Freq", 0.524649
  outvalue "AirJet", .34
  outvalue "Attack", .1
  outvalue "Decay", .1
  outvalue "AmpNoise", .1
  outvalue "VibFreq", 5
  outvalue "VibAmp", .1
  outvalue "MinFreq", 0.0
  outvalue "AmtRefJet", .5
  outvalue "CoefRefJet", .5
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 2 0 3600  ; GUI
i 4 0 0.1   ; Init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1164</x>
 <y>151</y>
 <width>862</width>
 <height>558</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1</x>
  <y>2</y>
  <width>511</width>
  <height>554</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgflute</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>76</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Amp</objectName>
  <x>8</x>
  <y>54</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Amp</objectName>
  <x>448</x>
  <y>76</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>515</x>
  <y>2</y>
  <width>340</width>
  <height>554</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgflute</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>517</x>
  <y>22</y>
  <width>336</width>
  <height>530</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------
wgflute is a wave guide physical model of a flute based on work by Perry Cook but re-coded for Csound by John ffitch. Attack time is the time taken to reach full blowing pressure. The author suggests that 0.1 corresponds to normal playing. Decay time is the time taken for the system to stop producing sound after blowing has stopped. The author suggests that 0.1 produces a smooth natural sounding end to a note. Air jet defines the strength of the air jet blown into the flute and therefore controls the playing of overtones. Values for air jet should be positive and the useful range is approximately 0.08 to 0.56. The author suggests a value of 0.3 as representing an air jet of typical strength. A value of 0.34 seems to provide the most accurate tuning. Amplitude of breath noise controls the amount of simulated wind noise in the composite tone produced. The suggested range is 0 to 0.5. Vibrato is implemented within the opcode and does not need to be applied separately to the frequency parameter. Natural vibrato occurs at about 5 hertz. Minimum frequency (optional) defines the lowest frequency at which the model will play. Amount of Reflection of Breath Jet (optional, default=0.5) defines the amount of reflection in the breath jet that. powers the flute. Breath Jet Reflection Coefficient (optional, default=0.5) is used in conjunction with the Amount of Reflection of Breath Jet in the calculation of the pressure differential. This example can also be triggered via MIDI. MIDI note number, velocity and pitch bend are interpreted appropriately.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b9023</objectName>
  <x>8</x>
  <y>16</y>
  <width>120</width>
  <height>30</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
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
  <x>8</x>
  <y>121</y>
  <width>220</width>
  <height>30</height>
  <uuid>{6e0c35ca-d489-456c-a3c8-7b02cf334c36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Freq</objectName>
  <x>8</x>
  <y>99</y>
  <width>500</width>
  <height>27</height>
  <uuid>{28514f48-2718-4dab-b43c-78c3cc4fba09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.52464902</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Freq_Value</objectName>
  <x>448</x>
  <y>121</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1ad30bb1-9a2f-461a-bf9e-cc7cc6c9d678}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>750.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>166</y>
  <width>220</width>
  <height>30</height>
  <uuid>{b6d928a2-0d92-4eaa-b1e8-9f3091c5794c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Air Jet</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>AirJet</objectName>
  <x>8</x>
  <y>144</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49a6777a-6ac7-430b-b827-547dc2686e49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.02000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.34000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>AirJet</objectName>
  <x>448</x>
  <y>166</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fca8b154-9112-4b23-8054-469dafd66230}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.340</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>211</y>
  <width>220</width>
  <height>30</height>
  <uuid>{55089f0d-6978-4aca-b682-ae666b30683e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack Time (i-rate in seconds)</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Attack</objectName>
  <x>8</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3439fd43-d6bf-41ba-88ab-efcbcda0122c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Attack</objectName>
  <x>448</x>
  <y>211</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d78b9853-b96c-4bc2-a2d5-375b6a4869ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>256</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d8273459-fbc3-40c2-b202-003f954906f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay Time (i-rate in seconds)</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Decay</objectName>
  <x>8</x>
  <y>234</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ab819133-79c9-448f-a33b-8cbd65c8d6af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Decay</objectName>
  <x>448</x>
  <y>256</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22ea767e-1d44-46df-a57d-1b39aeeeaa04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>301</y>
  <width>220</width>
  <height>30</height>
  <uuid>{eb9ca396-c5b9-439b-a2d6-173005d43519}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude of Breath Noise</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>AmpNoise</objectName>
  <x>8</x>
  <y>279</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8efddf99-5c6c-4272-8941-b63cbfa97d8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>AmpNoise</objectName>
  <x>448</x>
  <y>301</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f23ee963-c062-4762-86c4-6695f28e2b01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>345</y>
  <width>220</width>
  <height>30</height>
  <uuid>{a749092a-748d-4f5e-b805-f2397e3d8ec9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Frequency</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>VibFreq</objectName>
  <x>8</x>
  <y>323</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2dbff1a3-6cbb-402a-adc0-3f5c90b8bab1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>VibFreq</objectName>
  <x>448</x>
  <y>345</y>
  <width>60</width>
  <height>30</height>
  <uuid>{358c97c4-62fa-47d1-b74c-38996c4d00f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>390</y>
  <width>220</width>
  <height>30</height>
  <uuid>{b4c83057-1e9b-411b-af13-ffd335111370}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Amplitude</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>VibAmp</objectName>
  <x>8</x>
  <y>368</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0d7af4e5-75ae-4266-ad8f-961bca178e91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>VibAmp</objectName>
  <x>448</x>
  <y>390</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8dbc13b7-4506-4e59-8a2c-102bcd73c3cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>435</y>
  <width>220</width>
  <height>30</height>
  <uuid>{6f91bfd5-5833-4370-a064-9c699e367c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Minimum Frequency (i-rate)</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>MinFreq</objectName>
  <x>8</x>
  <y>413</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d9213109-8987-4c5f-87b1-1aea6078283d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>MinFreq_Value</objectName>
  <x>448</x>
  <y>435</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5c6e9bdc-a611-4f91-997f-b9ebf24f6f17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>479</y>
  <width>250</width>
  <height>30</height>
  <uuid>{316b00d5-3798-4f12-bb9e-0effe5d06d07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amount of Reflection of Breath Jet (i-rate)</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>AmtRefJet</objectName>
  <x>8</x>
  <y>457</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1c528095-f7f2-44fa-8f42-bee1f3c31d8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>AmtRefJet</objectName>
  <x>448</x>
  <y>479</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d6d41382-7902-4209-bcff-5d41af983a6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>524</y>
  <width>250</width>
  <height>30</height>
  <uuid>{8704e564-9d17-40d1-994b-0d313b6f4440}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Breath Jet Reflection Coefficient (i-rate)</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>CoefRefJet</objectName>
  <x>8</x>
  <y>502</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3ef92ec5-2d44-47fe-8194-da6f7856f29a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>CoefRefJet</objectName>
  <x>448</x>
  <y>524</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fcb424ee-0159-49f1-8d5a-c3680660b2a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
