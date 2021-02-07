<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>

giFt ftgen 0, 0, 12, 2, 0

instr 1; calculates first 12 fibonacci values and writes them to giFt
 istart = 1
 inext =	 2
 indx = 0
 while indx < 12 do
  tableiw istart, indx, giFt ;writes istart to table
  istartold = istart ;keep previous value of istart
  istart = inext ;reset istart for next loop
  inext = istartold + inext ;reset inext for next loop
  indx += 1
 od
endin

instr 2; prints the values of the table
 prints "%nContent of Function Table:%n"
 indx init 0
 while indx < 12 do
  ival table indx, giFt
  prints "Index %d = %f%n", indx, ival
  indx += 1
 od
  endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
