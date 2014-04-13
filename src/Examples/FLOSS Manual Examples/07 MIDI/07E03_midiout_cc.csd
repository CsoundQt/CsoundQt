<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials ; amend device number accordingly
-Q999
</CsOptions>

<CsInstruments>
ksmps = 32 ; no audio so sr and nchnls irrelevant

  instr 1
; play a midi note
; read in values from p-fields
ichan     init      p4
inote     init      p5
iveloc    init      p6
kskip     init      0 ; 'skip' flag ensures that note-on is executed just once
 if kskip=0 then
          midiout   144, ichan, inote, iveloc; send raw midi data (note on)
kskip     =         1   ; flip flag to prevent repeating the above line
 endif
krelease  release       ; normally zero, on final k pass this will output 1
 if krelease=1 then     ; if we are on the final k pass...
          midiout   144, ichan, inote, 0  ; send a note off
 endif

; send continuous controller data
iCCnum    =         p7
kCCval    line      0, p3, 127.1  ; continuous controller data function
kCCval    =         int(kCCval)   ; convert data function to integers
ktrig     changed   kCCval        ; generate a trigger each time kCCval changes
 if ktrig=1 then                  ; if kCCval has changed...
          midiout   176, ichan, iCCnum, kCCval  ; ...send a controller message
 endif
  endin

</CsInstruments>

<CsScore>
;p1 p2 p3   p4 p5 p6  p7
i 1 0  5    1  60 100 1
f 0 7 ; extending performance time prevents note-offs from being lost
</CsScore>

</CsoundSynthesizer>
