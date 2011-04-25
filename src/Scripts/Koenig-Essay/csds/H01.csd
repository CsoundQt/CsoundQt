<CsoundSynthesizer>

; Id: H01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

	instr 1
ifile	= p4
a1	diskin2 ifile , 1
a1	= a1 * .51

	out a1
	endin

</CsInstruments>
<CsScore>

t0	4572	; 76.2 cm/sec. tape speed (durations in cm)	

;			p4
;			ifile
i1	0	171	"H00_a.wav"
i1	0	171	"H00_b.wav"

e

</CsScore>
</CsoundSynthesizer>