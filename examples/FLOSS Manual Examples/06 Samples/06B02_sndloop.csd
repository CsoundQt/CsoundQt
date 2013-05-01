<CsoundSynthesizer>

<CsOptions>
; real-time audio in and out are both activated
-iadc -odac
</CsOptions>

<CsInstruments>
;example written by Iain McCurdy

sr 	= 	44100
ksmps 	= 	32
nchnls 	= 	1	

  instr	1
; PRINT INSTRUCTIONS
           prints  "Press 'r' to record, 's' to stop playback, "
           prints  "'+' to increase pitch, '-' to decrease pitch.\\n"
; SENSE KEYBOARD ACTIVITY
kKey sensekey; sense activity on the computer keyboard
aIn        inch    1             ; read audio from first input channel
kPitch     init    1             ; initialize pitch parameter
iDur       init    2             ; inititialize duration of loop parameter
iFade      init    0.05          ; initialize crossfade time parameter
 if kKey = 114 then              ; if 'r' has been pressed...
kTrig      =       1             ; set trigger to begin record-playback
 elseif kKey = 115 then          ; if 's' has been pressed...
kTrig      =       0             ; set trigger to turn off record-playback
 elseif kKey = 43 then           ; if '+' has been pressed...
kPitch     =       kPitch + 0.02 ; increment pitch parameter
 elseif kKey = 95 then           ; if '-' has been pressed
kPitch     =       kPitch - 0.02 ; decrement pitch parameter
 endif                           ; end of conditional branches
; CREATE SNDLOOP INSTANCE
aOut, kRec sndloop aIn, kPitch, kTrig, iDur, iFade ; (kRec output is not used)
           out     aOut          ; send audio to output
  endin

</CsInstruments>

<CsScore>
i 1 0 3600 ; instr 1 plays for 1 hour
</CsScore>

</CsoundSynthesizer>