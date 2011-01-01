<CsoundSynthesizer>

; Id: A07_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_A.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 311-441 ENTRY DELAYS & SYNCHRONIZATION
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


; + 10 cm respect to score (?)
;			p4	p5
;			iamp	ifile
i1	0	126	.8	"A06_ENV01.wav"	
i1	126.4	384.7	.8	"A06_ENV02.wav"		; + 116.4
i1	300.9	3098	.6	"A06_ENV03.wav"		; + 174.5
i1	890	192.4	.3	"A06_ENV04.wav"		; + 589.1
i1	1282.7	48.2	.5	"A06_ENV05.wav"		; + 392.7
i1	1544.5	1539	.8	"A06_ENV06.wav"		; + 261.8
i1	2869.9	1130	.8	"A06_ENV07.wav"		; + 1325.4
							; PART B: + 883.6

; total length: 3743.5
e

</CsScore>
</CsoundSynthesizer>