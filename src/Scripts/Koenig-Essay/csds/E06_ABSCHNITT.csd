<CsoundSynthesizer>

; Id: E06_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_E.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 351-445 ENTRY DELAYS & SYNCHRONIZATION
;=============================================
	instr 1
iamp	= p4
ifile	= p5

a1	diskin2 ifile , 1

aout	=  a1* .95

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iamp	ifile
i1	0	7184	1  	"E05_a_ENV01.wav"	; 	
i1	555.5	409.1	1  	"E05_b_ENV01.wav"	; + 555.5
i1	628.6	256.2	1  	"E05_c_ENV01.wav"	; + 73
i1	638.2	64.1	1  	"E05_d_ENV01.wav"	; + 9.5

i1	670.7	3592	1  	"E05_a_ENV02.wav"	; + 32.4
i1	780.4	437.1	1  	"E05_b_ENV02.wav"	; + 109.7
i1	1150.7	512.4	1  	"E05_c_ENV02.wav"	; + 370.3
i1	3025.7	32	1  	"E05_d_ENV02.wav"	; + 1875

i1	3030	1796	1  	"E05_a_ENV03.wav"	; + 4.3
i1	3051.6	112.3	1  	"E05_b_ENV03.wav"	; + 21.6
i1	3298.5	1025	1  	"E05_c_ENV03.wav"	; + 246.9
i1	4131.7	397	1  	"E05_d_ENV03.wav"	; + 833.2

i1	5381.7	898	1  	"E05_a_ENV04.wav"	; + 1250
i1	5546.3	224.5	1  	"E05_b_ENV04.wav"	; + 164.6
i1	5595	2048	1  	"E05_c_ENV04.wav"	; + 48.7
i1	5609.4	484.2	1  	"E05_d_ENV04.wav"	; + 14.3
							; PART F: + 6.3
; total length: 5615.3
e                     

</CsScore>
</CsoundSynthesizer>