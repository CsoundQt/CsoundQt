<CsoundSynthesizer>
<CsInstruments>
;Example by Joachim Heintz

giTable   ftgen     0, 0, -20, -2, 0; empty function table with 20 points
          seed      0; each time different seed

  instr 1 ; writes in the table
icount    =         0
loop:
ival      random    0, 10.999 ;random value
; --- write in giTable at first, second, third ... position
          tableiw   int(ival), icount, giTable
          loop_lt   icount, 1, 20, loop; loop construction
  endin

  instr 2; reads from the table
icount    =         0
loop:
; --- read from giTable at first, second, third ... position
ival      tablei    icount, giTable
          print     ival; prints the content
          loop_lt   icount, 1, 20, loop; loop construction
  endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 0
</CsScore>
</CsoundSynthesizer>
