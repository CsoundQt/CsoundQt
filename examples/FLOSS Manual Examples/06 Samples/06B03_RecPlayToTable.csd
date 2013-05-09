<CsoundSynthesizer>

<CsOptions>
; real-time audio in and out are both activated
-iadc -odac -d -m0
</CsOptions>

<CsInstruments>
; example written by Iain McCurdy

sr 	= 	44100
ksmps 	= 	32
nchnls 	= 	1

giBuffer ftgen  0, 0, 2^17, 7, 0; table for audio data storage
maxalloc 2,1 ; allow only one instance of the recording instrument at a time!

  instr	1 ; Sense keyboard activity. Trigger record or playback accordingly.
           prints  "Press 'r' to record, 'p' for playback.\\n"
iTableLen  =       ftlen(giBuffer)  ; derive buffer function table length
idur       =       iTableLen / sr   ; derive storage time in seconds
kKey sensekey                       ; sense activity on the computer keyboard
  if kKey=114 then                  ; if ASCCI value of 114 ('r') is output
event	"i", 2, 0, idur, iTableLen  ; activate recording instrument (2)
  endif
 if kKey=112 then                   ; if ASCCI value of 112 ('p) is output
event	"i", 3, 0, idur, iTableLen  ; activate playback instrument
 endif
  endin

  instr 2 ; record to buffer
iTableLen  =        p4              ; table/recording length in samples
; -- print progress information to terminal --
           prints   "recording"
           printks  ".", 0.25       ; print '.' every quarter of a second
krelease   release                  ; sense when note is in final k-rate pass...
 if krelease=1 then                 ; then ..
           printks  "\\ndone\\n", 0 ; ... print a message
 endif
; -- write audio to table --
ain        inch     1               ; read audio from live input channel 1
andx       line     0,p3,iTableLen  ; create an index for writing to table
           tablew   ain,andx,giBuffer ; write audio to function table
endin

  instr 3 ; playback from buffer
iTableLen  =        p4              ; table/recording length in samples
; -- print progress information to terminal --
           prints   "playback"
           printks  ".", 0.25       ; print '.' every quarter of a second
krelease   release                  ; sense when note is in final k-rate pass
 if krelease=1 then                 ; then ...
           printks  "\\ndone\\n", 0 ; ... print a message
 endif; end of conditional branch
; -- read audio from table --
aNdx       line     0, p3, iTableLen; create an index for reading from table
a1         table    aNdx, giBuffer  ; read audio to audio storage table
           out      a1              ; send audio to output
  endin

</CsInstruments>

<CsScore>
i 1 0 3600 ; Sense keyboard activity. Start recording - playback.
</CsScore>

</CsoundSynthesizer>
