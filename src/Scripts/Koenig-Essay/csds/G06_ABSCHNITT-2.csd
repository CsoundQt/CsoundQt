<CsoundSynthesizer>

; Id: G06_ABSCHNITT-2.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG06_ABSCHNITT-2.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 372. SYNCHRONIZATION
;=============================================
	instr 1

iamp	= p4
ifile	= p5

a1	diskin2 ifile , 1

aout	=  a1* iamp *.9

	out aout
	endin

;=============================================
</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iamp	ifile
i1	0	324.63	.2  	"G03_TR01.wav"	
i1	36.8	362.11	.2  	"G03_TR02.wav"	
i1	82.9	404.02	.2  	"G03_TR03.wav"	
i1	140.5	450.9	.2  	"G03_TR04.wav"		
i1	212.5	502.9	.2  	"G03_TR05.wav"	
i1	302.5	561.2	.2  	"G03_TR06.wav"	
i1	414.9	626.1	.2  	"G03_TR07.wav"	
i1	555.4	698.4	.2  	"G03_TR08.wav"	
i1	731.1	779.1	.2  	"G03_TR09.wav"	
i1	950.7	869.3	.2  	"G03_TR10.wav"		
i1	1225.2	969.8 	.2  	"G03_TR11.wav"	
i1	1568.3	1082	.2  	"G03_TR12.wav"	
i1	1997.2	1207	.2  	"G03_TR13.wav"		
i1	2533.3	1347 	.2  	"G03_TR14.wav"	
i1	3203.4	1503	1.25  	"G05_ENV15-2.wav"		
i1	4041	1677	1.5  	"G05_ENV16-2.wav"	
i1	5088	1870	1.75	"G05_ENV17-2.wav"	
i1	6397	2086.5	2	"G05_ENV18-2.wav"	
i1	8033	2328	2.5	"G05_ENV19-2.wav"	
i1	10078	2597	3	"G05_ENV20-2.wav"	
; total length: 12675
e

</CsScore>
</CsoundSynthesizer>