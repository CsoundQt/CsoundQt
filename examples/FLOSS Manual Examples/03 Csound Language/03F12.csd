see http://www.flossmanuals.net/csound/ch021_f-user-defined-opcodes

<CsoundSynthesizer>
<CsOptions>
-ndm0 -+max_str_len=10000
</CsOptions>
<CsInstruments>
;example by joachim heintz

gitab     ftgen     1, 0, -7, -2, 0, 1, 2, 3, 4, 5, 6
gisin     ftgen     2, 0, 128, 10, 1


  opcode TableDumpSimp, 0, ijo
;prints the content of a table in a simple way
;input: function table, float precision while printing (default = 3), parameters per row (default = 10, maximum = 32)
ifn, iprec, ippr xin
iprec     =         (iprec == -1 ? 3 : iprec)
ippr      =         (ippr == 0 ? 10 : ippr)
iend      =         ftlen(ifn)
indx      =         0
Sformat   sprintf   "%%.%df\t", iprec
Sdump     =         ""
loop:
ival      tab_i     indx, ifn
Snew      sprintf   Sformat, ival
Sdump     strcat    Sdump, Snew
indx      =         indx + 1
imod      =         indx % ippr
 if imod == 0 then
          puts      Sdump, 1
Sdump     =         ""
 endif
 if indx < iend igoto loop
          puts      Sdump, 1
  endop
	
	
instr 1
          TableDumpSimp p4, p5, p6
          prints    "%n"
endin

</CsInstruments>
<CsScore>
;i1   st   dur   ftab   prec   ppr
i1    0    0     1      -1
i1    .    .     1       0
i1    .    .     2       3     10	
i1    .    .     2       6     32
</CsScore>
</CsoundSynthesizer><bsbPanel>
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
