<CsoundSynthesizer>

<CsOptions>
-Ma -m0
; activates all midi devices, suppress note printings
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

; no audio so 'sr' or 'nchnls' aren't relevant
ksmps = 32

; using massign with these arguments disables default instrument triggering
massign	0,0

  instr 1
kstatus, kchan, kdata1, kdata2  midiin            ;read in midi
ktrigger  changed  kstatus, kchan, kdata1, kdata2 ;trigger if midi data changes
 if ktrigger=1 && kstatus!=0 then          ;if status byte is non-zero...
; -- print midi data to the terminal with formatting --
 printks "status:%d%tchannel:%d%tdata1:%d%tdata2:%d%n"\
                                    ,0,kstatus,kchan,kdata1,kdata2
 endif
  endin

</CsInstruments>

<CsScore>
i 1 0 3600 ; instr 1 plays for 1 hour
</CsScore>

</CsoundSynthesizer>