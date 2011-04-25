<CsoundSynthesizer>

; Id: H09_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_H.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 482. SYNCHRONIZATION
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


i1	0	723	1	"H08_ENV01.wav"		; +
i1	425.8	1749	1	"H08_ENV02.wav"		; + 425.8
i1	615	684	1	"H08_ENV03.wav"		; + 189.2
i1	517.9	552	1	"H08_ENV04.wav"		; + 283.9	; 898.9-rev.ant.
i1	1025.1	864.6	1	"H08_ENV05.wav"		; + 126.2

e                     

</CsScore>
</CsoundSynthesizer>