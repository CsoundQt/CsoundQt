<CsoundSynthesizer>

; Id: B06_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_B.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 321-442 ENTRY DELAYS & SYNCHRONIZATION
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
i1	0	388.6	1 	"B05_ENV01.wav"	
i1	270.2	2814	1 	"B05_ENV02.wav"		; + 270.2
i1	1182.2	73.7	1  	"B05_ENV03.wav"		; + 912
i1	1587.5	32.1	1  	"B05_ENV04.wav"		; + 405.3
i1	1707.6	168.7	1 	"B05_ENV05.wav"		; + 120.1
i1	1887.7	893.1	1  	"B05_ENV06.wav"		; + 180.1
							; PART C: + 608
; total length: 2495.7
e

</CsScore>
</CsoundSynthesizer>