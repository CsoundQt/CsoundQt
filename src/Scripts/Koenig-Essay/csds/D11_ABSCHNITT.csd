<CsoundSynthesizer>

; Id: D11_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_D.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 341-444 ENTRY DELAYS & SYNCHRONIZATION
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
i1	0	865.7	1 	"D08_ENV01.wav"	
i1	379.5	2493.4 	1	"D08_ENV02.wav"		; + 379.5
i1	1233.5	612.1	1 	"D08_ENV03.wav"		; + 854
i1	1402.1	3844.1	1 	"D10_ENV04.wav"		; + 168.6	
i1	4285.1	306.1	1 	"D08_ENV05.wav"		; + 2883
i1	4397.5	3348	1  	"D08_ENV06.wav"		; + 112.4
i1	4650.5	1224	1 	"D08_ENV07.wav"		; + 253
i1	6572.5	356.4	1 	"D08_ENV08.wav"		; + 1922
i1	7141.8	1246.7	1 	"D08_ENV09.wav"		; + 569.3
							; PART E: + 1281
                      
; total length: 8422.8
e

</CsScore>
</CsoundSynthesizer>