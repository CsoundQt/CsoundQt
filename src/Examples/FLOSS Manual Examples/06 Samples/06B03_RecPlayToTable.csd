<CsoundSynthesizer>
<CsOptions>
; real-time audio in and out are both activated
-iadc -odac -m128
</CsOptions>
<CsInstruments>
sr      =       44100
ksmps   =       32
nchnls  =       2
0dbfs   =       1

giTabLenSec = 3 ;table duration in seconds
giBuffer ftgen  0, 0, giTabLenSec*sr, 2, 0; table for audio data storage
maxalloc 2,1 ; allow only one instance of the recording instrument at a time!

  instr 1 ; Sense keyboard activity. Trigger record or playback accordingly.
           prints  "Press 'r' to record, 'p' for playback.\n"
kKey sensekey                    ; sense activity on the computer keyboard
  if kKey==114 then               ; if ASCCI value of 114 ('r') is output
event   "i", 2, 0, giTabLenSec   ; activate recording instrument (2)
  endif
 if kKey==112 then                ; if ASCCI value of 112 ('p) is output
event   "i", 3, 0, giTabLenSec  ; activate playback instrument
 endif
  endin

  instr 2 ; record to buffer
; -- print progress information to terminal --
           prints   "recording"
           printks  ".", 0.25    ; print '.' every quarter of a second
krelease   release               ; sense when note is in final k-rate pass...
 if krelease==1 then              ; then ..
           printks  "\ndone\n", 0 ; ... print a message
 endif
; -- write audio to table --
ain        inch     1            ; read audio from live input channel 1
andx       line     0,p3,ftlen(giBuffer); create an index for writing to table
           tablew   ain,andx,giBuffer ; write audio to function table
endin

  instr 3 ; playback from buffer
; -- print progress information to terminal --
           prints   "playback"
           printks  ".", 0.25    ; print '.' every quarter of a second
krelease   release               ; sense when note is in final k-rate pass
 if krelease=1 then              ; then ...
           printks  "\ndone\n", 0 ; ... print a message
 endif; end of conditional branch
; -- read audio from table --
aNdx line 0, p3, ftlen(giBuffer)  ;create an index for reading from table
aRead      table    aNdx, giBuffer  ; read audio to audio storage table
           out      aRead, aRead    ; send audio to output
  endin

</CsInstruments>
<CsScore>
i 1 0 3600 ; Sense keyboard activity. Start recording - playback.
</CsScore>
</CsoundSynthesizer>
;example written by Iain McCurdy
