see http://www.flossmanuals.net/csound/ch048_d-reading-midi-files

<CsoundSynthesizer>

<CsOptions>
-F InputMidiFile.mid
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

;ksmps needs to be 10 to ensure accurate rendering of timings
ksmps = 10

massign 0,1

  instr 1
iChan       midichn
iCps        cpsmidi; read pitch in frequency from midi notes
iVel        veloc	0, 127; read in velocity from midi notes
kDur        timeinsts; running total of duration of this note
kRelease    release; sense when note is ending
 if kRelease=1 then; if note is about to end
;           p1  p2  p3    p4     p5    p6
event "i",  2,  0, kDur, iChan, iCps, iVel ; send full note data to instr 2
 endif
  endin

  instr 2
iDur        =        p3
iChan       =        p4
iCps        =        p5
iVel        =        p6
iStartTime  times; read current time since the start of performance
SFileName   sprintf  "Channel%d.sco",iChan; form file name for this channel (1-16) as a string variable
            fprints  SFileName, "i%d\\t%f\\t%f\\t%f\\t%d\\n",iChan,iStartTime-iDur,iDur,iCps,iVel; write a line to the score for this channel's .sco file
  endin

</CsInstruments>
<CsScore>
f 0 480; ensure that this duration is as long or longer that the duration of the input midi file
e
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
