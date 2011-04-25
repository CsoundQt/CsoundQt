<CsoundSynthesizer>

; Id: B02_DIST02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oB02_DIST02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;===========================================================
; 226.2 OTHER TRANSFORMATIONS (DISTORTION & LOW-PASS FILTERING)
;===========================================================
	instr 1
ifile	= p4

a1	diskin2  ifile, 1

adist	tablei a1 , 2 , 0 , 32768	; distortion

adist	tonex adist, 5000 		; low-pass filtering

aout	= adist * ampdb(90)

	out aout
	endin
;===========================================================

</CsInstruments>
<CsScore>
f2	0	65536	-27	0 -1 20000 -1   45536 1 65536 1	; waveshaping function

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4
;			ifile
i1	0	256.5	"B01.wav"	; 6.25/50

e

</CsScore>
</CsoundSynthesizer>