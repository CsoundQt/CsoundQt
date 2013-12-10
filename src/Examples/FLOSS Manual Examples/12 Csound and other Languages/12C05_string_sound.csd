<CsoundSynthesizer>
<CsInstruments>

sr = 44100
nchnls = 2
0dbfs = 1
ksmps = 32

giSine ftgen 1, 0, 4096, 10, 1 ; sine


#define MAINJOB(INSTNO) #
	Sstr strget p4
	ilen strlen Sstr
	ipos = 0
marker:   ; convert every character in the string to pitch
    ichr strchar Sstr, ipos
    icps = cpsmidinn(ichr)-$INSTNO*8
    ;print icps
    event_i "i", "sound", 0+ipos/8, p3, ichr,icps, $INSTNO ; chord with arpeggio
    loop_lt ipos, 1, ilen, marker
#

instr 1
	$MAINJOB(1)	
endin

instr 2
	$MAINJOB(2)	
endin

instr 3
	$MAINJOB(3)	
endin

instr sound
	ichar = p4
	ifreq = p5
	itype = p6
	kenv linen 0.1,0.1, p3,0.5	
	if itype== 1 then
		asig pluck kenv,ifreq,ifreq,0, 3, 0
	elseif itype==2 then
		kenv adsr 0.05,0.1,0.5,1
		asig poscil kenv*0.1,ifreq,giSine
	else
		asig	buzz kenv,ifreq,10, giSine
	endif
	outs asig,asig
endin

</CsInstruments>
<CsScore>
f0 3600
i 1 0 4 "huhuu"
</CsScore>
</CsoundSynthesizer>
;example by tarmo johannes
