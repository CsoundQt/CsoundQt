see http://en.flossmanuals.net/bin/view/Csound/Userdefinedopcodes

<CsoundSynthesizer>
<CsInstruments>

giVals    ftgen     0, 0, -12, -2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
          seed      0; each time different seed

  opcode TabPermRand_i, i, i
;permuts randomly the values of the input table and creates an output table for the result
iTabin    xin
itablen   =         ftlen(iTabin)
iTabout   ftgen     0, 0, -itablen, 2, 0 ;create empty output table
iCopy     ftgen     0, 0, -itablen, 2, 0 ;create empty copy of input table
          tableicopy iCopy, iTabin ;write values of iTabin into iCopy
icplen    init      itablen ;number of values in iCopy
indxwt    init      0 ;index of writing in iTabout
loop:
indxrd    random    0, icplen - .0001; random read index in iCopy
indxrd    =         int(indxrd)
ival      tab_i     indxrd, iCopy; read the value
          tabw_i    ival, indxwt, iTabout; write it to iTabout
 shift:           ;shift values in iCopy larger than indxrd one position to the left
 if indxrd < icplen-1 then ;if indxrd has not been the last table value
ivalshft  tab_i     indxrd+1, iCopy ;take the value to the right ...
          tabw_i    ivalshft, indxrd, iCopy ;... and write it to indxrd position
indxrd    =         indxrd + 1 ;then go to the next position
          igoto     shift ;return to shift and see if there is anything left to do
 endif
indxwt    =         indxwt + 1 ;increase the index of writing in iTabout
          loop_gt   icplen, 1, 0, loop ;loop as long as there is a value in iCopy
          ftfree    iCopy, 0 ;delete the copy table
          xout      iTabout ;return the number of iTabout
  endop

instr 1
iPerm     TabPermRand_i giVals ;perform permutation
;print the result
indx      =         0
Sres      =         "Result:"
print:
ival      tab_i     indx, iPerm
Sprint    sprintf   "%s %d", Sres, ival
Sres      =         Sprint
          loop_lt   indx, 1, 12, print
          puts      Sres, 1
endin

instr 2; the same but performed ten times
icnt      =         0
loop:
iPerm     TabPermRand_i giVals ;perform permutation
;print the result
indx      =         0
Sres      =         "Result:"
print:
ival      tab_i     indx, iPerm
Sprint    sprintf   "%s %d", Sres, ival
Sres      =         Sprint
          loop_lt   indx, 1, 12, print
          puts      Sres, 1
          loop_lt   icnt, 1, 10, loop
endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 0
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
ioView background {59117, 36032, 9346}
</MacGUI>
