<CsoundSynthesizer>

; Id: X_ESSAY.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -oX_ESSAY.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

	instr 1
a1	diskin2 p4 , 1

aout	=  a1* .7
	out aout
	endin

</CsInstruments>
<CsScore>
t0	4572	

i1	0		3999.9	 	"X_ABSCHNITT_A.wav"
i1	3753.5		2780.767	"X_ABSCHNITT_B.wav"
i1	6249.2		807.08		"X_ABSCHNITT_C.wav"
i1	6998.7		8407.4		"X_ABSCHNITT_D.wav"
i1	15421.5 	7643		"X_ABSCHNITT_E.wav"
i1	19329.12 	3869.76		"X_ABSCHNITT_F.wav"	; 21026-rev.anteriore
i1	22145.2 	13528.24	"X_ABSCHNITT_G.wav"	; 22135.2-REV ANTERIORE
i1	34819.4		1693.62		"X_ABSCHNITT_H.wav"
e

</CsScore>
</CsoundSynthesizer>