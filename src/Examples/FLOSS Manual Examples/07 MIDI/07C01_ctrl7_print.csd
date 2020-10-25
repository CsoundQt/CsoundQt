<CsoundSynthesizer>
<CsOptions>
-Ma -odac
; activate all MIDI devices
</CsOptions>
<CsInstruments>
; 'sr' and 'nchnls' are irrelevant so are omitted
ksmps = 32

  instr 1
kCtrl    ctrl7    1,1,0,127  ; read in controller 1 on channel 1
kTrigger changed  kCtrl      ; if 'kCtrl' changes generate a trigger ('bang')
 if kTrigger=1 then
; Print kCtrl to console with formatting, but only when its value changes.
printks "Controller Value: %d%n", 0, kCtrl
 endif
  endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
<CsoundSynthesizer>
;example by Iain McCurdy