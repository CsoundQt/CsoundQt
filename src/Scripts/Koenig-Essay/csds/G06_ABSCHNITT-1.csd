<CsoundSynthesizer>

; Id: G06_ABSCHNITT-1.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG06_ABSCHNITT-1.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 372-447 ENTRY DELAYS & SYNCHRONIZATION
;=============================================
	instr 1
iamp	= p4
ifile	= p5

a1	diskin2 ifile , 1

aout	=  a1* iamp

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iamp	ifile
i1	0	324.63	.2 	"G03_TR01.wav"		; + 
i1	36.8	362.11	.2 	"G03_TR02.wav"		; + 36.8
i1	82.9	404.02	.2 	"G03_TR03.wav"		; + 46.1
i1	140.5	450.9	.2 	"G03_TR04.wav"		; + 57.6
i1	212.5	502.9	.2 	"G03_TR05.wav"		; + 72
i1	302.5	561.2	.2 	"G03_TR06.wav"		; + 90
i1	414.9	626.1	.2 	"G03_TR07.wav"		; + 112.4
i1	555.4	698.4	.2 	"G03_TR08.wav"		; + 140.5
i1	731.1	779.1	.2 	"G03_TR09.wav"		; + 175.7
i1	950.7	869.3	.2 	"G03_TR10.wav"		; + 219.6
i1	1225.2	969.8 	.2 	"G03_TR11.wav"		; + 274.5
i1	1568.3	1082	.2 	"G03_TR12.wav"		; + 343.1
i1	1997.2	1207	.2 	"G03_TR13.wav"		; + 428.9
i1	2533.3	1347 	.2 	"G03_TR14.wav"		; + 536.1
i1	3203.4	1503	.8 	"G05_ENV15-1.wav"	; + 670
i1	4041	1676.35	1  	"G05_ENV16-1.wav"	; + 837.6
i1	5088	1870	1.4	"G05_ENV17-1.wav"	; + 1047
i1	6397	2086.5	1.8	"G05_ENV18-1.wav"	; + 1309
i1	8033	2328	2.2	"G05_ENV19-1.wav"	; + 1636
i1	10078	2597	3.5	"G05_ENV20-1.wav"	; + 2045
							; PART H: + 2556
; total length: 12675
e                     

</CsScore>
</CsoundSynthesizer>