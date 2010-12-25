see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>

<CsOptions>
; audio in and out are required
-iadc -odac -d -m0
</CsOptions>

<CsInstruments>
;example written by Iain McCurdy

sr 	= 	44100
ksmps 	= 	32
nchnls 	= 	1	
0dbfs	=	1	; maximum amplitude regardless of bit depth

  instr	1
; PRINT INSTRUCTIONS
           prints  "Press 'r' to record, 's' to stop playback, '+' to increase pitch, '-' to decrease pitch.\\n"
; SENSE KEYBOARD ACTIVITY
kKey sensekey; sense activity on the computer keyboard
aIn        inch    1; read audio from first input channel
kPitch     init    1; initialize pitch parameter
iDur       init    2; inititialize duration of loop parameter
iFade      init    0.05 ;initialize crossfade time parameter
 if kKey = 114 then; if 'r' has been pressed...
kTrig      =       1; set trigger to begin record-playback process
 elseif kKey = 115 then; if 's' has been pressed...
kTrig      =       0; set trigger to deactivate sndloop record-playback process
 elseif kKey = 43 then; if '+' has been pressed...
kPitch     =       kPitch + 0.02; increment pitch parameter
 elseif kKey = 95 then; if ''-' has been pressed
kPitch     =       kPitch - 0.02; decrement pitch parameter
 endif; end of conditional branch
; CREATE SNDLOOP INSTANCE
aOut, kRec sndloop aIn, kPitch, kTrig, iDur, iFade; (kRec output is not used)
           out     aOut; send audio to output
  endin

</CsInstruments>

<CsScore>
i 1 0 3600; sense keyboard activity instrument
</CsScore>

</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>630</x>
 <y>260</y>
 <width>380</width>
 <height>205</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>140</g>
  <b>36</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {59110, 35980, 9252}
</MacGUI>
