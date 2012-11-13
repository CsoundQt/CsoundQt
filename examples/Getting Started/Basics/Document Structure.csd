/* Getting started.. 1.2 Basic Document Structure

This file explains the "Document Structure". If you press run, you won't hear anything!

A Csound document is structured in four main sections. Each sections is opened with a <xyz> tag and closed with </xyz> tag. Every Csound file starts with a <CsoundSynthesizer> tag, and ends with </CsoundSynthesizer>, only text that is inbetween, will be compiled by Csound.
*/

<CsoundSynthesizer> 	; START OF A CSOUND FILE

<CsOptions> 		; OPTIONS
; If you run Csound from QuteCsound, you can set options in the 'Preferences' menu more comfortably.
; Read more details in the Csound Manual under: 1.Overview->The Csound Command->Comand-line Flags (by Category).
</CsOptions> 		;close OPTIONS


<CsInstruments> 		; INSTRUMENT SECTION
; The instrumentheader section, specifies global options for instrument performance.
sr = 44100 			; the samplerate for audiosignals is set to 44100 Hz (calculations per second)
ksmps = 128 		; is the number of samples per control-block, -> ~345 Hz is the controlrate (sr/ksmps = controlrate HZ) 
nchnls = 2 			; the number of output channels is set to 2 (stereo)
0dbfs = 1 			; the maximum output level before clipping (0dB FS) is set to 1, so the amplitude range is 0-1

; Now you can define your instruments
instr 1 			; first instrument
				; this is empty, so nothing will be played
endin

instr 2 			; second instrument
				; this is also empty, so nothing will be played
endin
</CsInstruments> 		;ends the INSTUMENT SECTION


<CsScore> 			; SCORE
				; instruments will be triggered here but this is empty as well
e
</CsScore> 			; ends the SCORE
</CsoundSynthesizer> 	; ending of CSOUND FILE
this will not become compiled :-), so I don't need the comment sign
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover 
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>160</r>
  <g>158</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>51</x>
  <y>30</y>
  <width>80</width>
  <height>25</height>
  <uuid>{12de81e4-fac6-4001-b773-b19de1632c09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>empty :-)</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
