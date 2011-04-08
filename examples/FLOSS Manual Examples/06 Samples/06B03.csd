see http://www.flossmanuals.net/csound/ch042_b-record-and-play-buffers

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

giBuffer ftgen  0, 0, 2^17, 7, 0; table for audio data storage
maxalloc 2,1; allow only one instance of the recordsing instrument at a time

  instr	1; sense keyboard activity and start record or playback instruments accordingly
           prints  "Press 'r' to record, 'p' for playback.\\n"
iTableLen  =       ftlen(giBuffer); derive buffer function table length in points
idur       =       iTableLen / sr; derive storage time potential of buffer function table
kKey sensekey; sense activity on the computer keyboard
  if kKey=114 then; if ASCCI value of 114 is output, i.e. 'r' has been pressed...
event	"i", 2, 0, idur, iTableLen; activate recording instrument for the duration of the buffer storage potential. Pass it table length in point as a p-field variable
  endif; end of conditional branch
 if kKey=112 then; if ASCCI value of 112 is output, i.e. 'p' has been pressed...
event	"i", 3, 0, idur, iTableLen; activate recording instrument for the duration of the buffer storage potential. Pass it table length in point as a p-field variable
 endif; end of conditional branch
  endin

  instr 2; record to buffer
iTableLen  =        p4; read in value from p-field (length of function table in samples)
;PRINT PROGRESS INFORMATION TO TERMINAL
           prints   "recording"
           printks  ".", 0.25; print a '.' every quarter of a second
krelease   release; sense when note is in final performance pass (output=1)
 if krelease=1 then; if note is in final performance pass and about to end...
           printks  "\\ndone\\n", 0; print a message bounded by 'newlines'
 endif; end of conditional branch
; WRITE TO TABLE
ain        inch     1; read audio from live input channel 1
andx       line     0, p3, iTableLen; create a pointer for writing to table
           tablew   ain, andx, giBuffer ;write audio to audio storage table
endin

  instr 3; playback from buffer
iTableLen  =        p4; read in value from p-field (length of function table in samples)
;PRINT PROGRESS INFORMATION TO TERMINAL
           prints   "playback"
           printks  ".", 0.25; print a '.' every quarter of a second
krelease   release; sense when note is in final performance pass (output=1)
 if krelease=1 then; if note is in final performance pass and about to end...
           printks  "\\ndone\\n", 0; print a message bounded by 'newlines'
 endif; end of conditional branch
; READ FROM TABLE
aNdx       line     0, p3, iTableLen; create a pointer for reading from the table
a1         table    aNdx, giBuffer ;read audio to audio storage table
           out      a1; send audio to output
  endin

</CsInstruments>

<CsScore>
i 1 0 3600; sense keyboard activity instrument
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
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
