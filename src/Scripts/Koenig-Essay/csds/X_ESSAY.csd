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
kr     = 192000
ksmps  = 1
nchnls = 1

	instr 1
a1	diskin2 p4 , 1

aout	=  a1* .7
	out aout
	endin

</CsInstruments>
<CsScore>
t0	4572	

i1	0		4020.4	 	"X_ABSCHNITT_A.wav"
i1	3753.5		2780.8		"X_ABSCHNITT_B.wav"
i1	6249.2		1040.8		"X_ABSCHNITT_C.wav"
i1	6998.7		8388.5		"X_ABSCHNITT_D.wav"
i1	15421.5 	7643		"X_ABSCHNITT_E.wav"
i1	19319.12 	3498.88		"X_ABSCHNITT_F.wav"	; 21026-rev.anteriore (1706.88)
i1	21373.2 	13436.8		"X_ABSCHNITT_G.wav"	; 22135.2-REV ANTERIORE (762)
i1	34790.4		2174.8		"X_ABSCHNITT_H.wav"
e

</CsScore>
</CsoundSynthesizer>