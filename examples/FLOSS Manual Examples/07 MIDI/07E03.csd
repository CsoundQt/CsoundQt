see http://www.flossmanuals.net/csound/ch047_e-midi-output

<CsoundSynthesizer>

<CsOptions>
; amend device number accordingly
-Q999
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

ksmps = 32 ;no audio so sr and nchnls omitted

  instr 1
; play a midi note
; read in values from p-fields
ichan     init      p4
inote     init      p5
iveloc    init      p6
kskip     init      0; 'skip' flag will ensure that note-on is executed just once
 if kskip=0 then
          midiout   144, ichan, inote, iveloc; send raw midi data (note on)
kskip     =         1; ensure that the note on will only be executed once by flipping flag
 endif
krelease  release; normally output is zero, on final k pass output is 1
 if krelease=1 then; i.e. if we are on the final k pass...
          midiout   144, ichan, inote, 0; send raw midi data (note off)
 endif

; send continuous controller data
iCCnum    =         p7
kCCval    line      0, p3, 127.1; continuous controller data function
kCCval    =         int(kCCval); convert data function to integers
ktrig     changed   kCCval; generate a trigger each time kCCval (integers) changes
 if ktrig=1 then; if kCCval has changed
          midiout   176, ichan, iCCnum, kCCval; send a continuous controller message
 endif
  endin

</CsInstruments>

<CsScore>
;p1 p2 p3   p4 p5 p6  p7
i 1 0  5    1  60 100 1
f 0 7; extending performance time prevents note-offs from being lost
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
