/* Getting started.. 1.2 Basic Document Structure

This file explains the "Document Structure". If you press run, you won't hear anything!

A Csound document is structured in four main sections. Each sections is opened with a <xyz> tag and closed with </xyz> tag. Every Csound file starts with a <CsoundSynthesizer> tag, and ends with </CsoundSynthesizer>, only text that is inbetween, will be compiled by Csound.

*/

<CsoundSynthesizer> 	

; START OF A CSOUND FILE

<CsOptions> 		
; OPTIONS
; If you run Csound from CsoundQt, you can set options in the 'Preferences' 
; menu more comfortably.
</CsOptions> 		   ; close OPTIONS


<CsInstruments> 	; INSTRUMENT SECTION

; The instrument header section, specifies global 
; options for instrument performance.

sr     = 44100  ; the samplerate for audiosignals 
ksmps  = 64  		; the number of samples per control-block
nchnls = 2 			; the number of output channels is set to 2 (stereo)
0dbfs  = 1 			; the max. output level (0dB FS), so the amplitude range is 0-1

; Now you can define your instruments

instr 1 			  ; first instrument
  prints ">>> First instrument! \n"
endin

instr 2 			  ; second instrument
	prints ">>> Second instrument \n"
endin
</CsInstruments> 		  ; <------ end if INSTRUMENT SECTION


<CsScore>
i 1 0 0
i 2 1 0

</CsScore> 			      ; <------- end of SCORE
</CsoundSynthesizer> 	; <------- end of CSOUND FILE

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
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>51</x>
  <y>30</y>
  <width>80</width>
  <height>25</height>
  <uuid>{12de81e4-fac6-4001-b773-b19de1632c09}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>empty :-)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
