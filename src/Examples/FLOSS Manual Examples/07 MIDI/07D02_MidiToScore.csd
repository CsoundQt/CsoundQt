<CsoundSynthesizer>
<CsOptions>
; enter name of input midi file
-F InputMidiFile.mid
</CsOptions>
<CsInstruments>

;ksmps needs to be small to ensure accurate rendering of timings
ksmps = 8

massign 0,1

  instr 1
iChan       midichn
iCps        cpsmidi            ; read pitch in frequency from midi notes
iVel        veloc       0, 127 ; read in velocity from midi notes
kDur        timeinsts          ; running total of duration of this note
kRelease    release            ; sense when note is ending
 if kRelease=1 then            ; if note is about to end
;           p1  p2  p3    p4     p5    p6
event "i",  2,  0, kDur, iChan, iCps, iVel ; send full note data to instr 2
 endif
  endin

  instr 2
iDur        =        p3
iChan       =        p4
iCps        =        p5
iVel        =        p6
iStartTime  times        ; read current time since the start of performance
; form file name for this channel (1-16) as a string variable
SFileName   sprintf  "Channel%d.sco",iChan
; write a line to the score for this channel's .sco file
            fprints  SFileName, "i%d\\t%f\\t%f\\t%f\\t%d\\n",\
                                 iChan,iStartTime-iDur,iDur,iCps,iVel
  endin

</CsInstruments>
<CsScore>
f 0 480 ; ensure this duration is as long or longer that duration of midi file
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy
