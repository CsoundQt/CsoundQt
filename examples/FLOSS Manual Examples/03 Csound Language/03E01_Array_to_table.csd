<CsoundSynthesizer>
<CsOptions>
-odac -d
;Example by Tarmo Johannes
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giTab1 ftgen 0, 0, -6, -2, 10,11,12,13,14,15
giTab2 ftgen 0, 0, -6, -2, 0

instr 1
	tvar init ftlen(giTab1) ; declare and initialize array tvar
	copy2ttab tvar,giTab1 ; copy giTab1 to tvar
	printk2 tvar[4]
	tvar[4]=tvar[4]+tvar[3] ;    change a value
	copy2ftab tvar, giTab2 ; write the whole array to the other table
	turnoff ; stop after 1st k-cycle	
endin

instr 2
	index = 0
loophere:
    ival tab_i index,giTab2
    print index,ival
    loop_lt index, 1, ftlen(giTab2), loophere	
endin

</CsInstruments>
<CsScore>
i 1 0 0.1 ; must have some duration, since tvar is handled in k-time (percormance pass)
i 2 0.2 0  ; here only i-values, no duration needed
</CsScore>
</CsoundSynthesizer>
