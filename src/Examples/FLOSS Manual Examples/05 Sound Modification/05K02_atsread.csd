<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

instr 1	
iamp = p4                       ;amplitude scaler
ifreq = p5                      ;frequency scaler
ipar = p6                       ;partial required
itab = p7                       ;audio table
iatsfile = p8                   ;ats file

idur ATSinfo iatsfile, 7        ;get duration

ktime line 0, p3, idur          ;time pointer

kfreq, kamp ATSread ktime, iatsfile, ipar        ;get frequency and amplitude values
aamp        interp  kamp                         ;interpolate amplitude values
afreq       interp  kfreq                        ;interpolate frequency values
aout        oscil3  aamp*iamp, afreq*ifreq, itab ;synthesize with amp and freq scaling
	
            out     aout
endin

</CsInstruments>
<CsScore>
; sine wave table
f 1 0 16384 10 1
#define atsfile #"../ats-files/flute-A5.ats"#

;	start	dur	amp	freq	par	tab	atsfile
i1 	0 	3 	1	1	1	1	$atsfile	
i1 	0 	. 	.1	.	2	.	$atsfile
i1 	0 	. 	1	.	3	.	$atsfile
i1 	0 	. 	.1	.	4	.	$atsfile
i1 	0 	. 	1	.	5	.	$atsfile
i1 	0 	. 	.1	.	6	.	$atsfile
i1 	0 	. 	1	.	7	.	$atsfile
i1 	0 	. 	.1	.	8	.	$atsfile
i1 	0 	. 	1	.	9	.	$atsfile
i1 	0 	. 	.1	.	10	.	$atsfile
e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia
