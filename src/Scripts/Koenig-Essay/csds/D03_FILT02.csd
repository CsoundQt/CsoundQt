<CsoundSynthesizer>

; Id: D03_FILT02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD03_FILT02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 243.2 FILTERINGS
;=============================================
	instr 1
if1	= p4
if2	= p5
ibw	= p5-p4
ifc	= if1+(ibw*.333)

ifile	= p6

a1	diskin2 ifile, 1

af1	atonex a1, if1
af2	tonex af1, if2

	out af2 * 8
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572	; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	p6
;			if1	if2	ifile
i1	0	865.7	1128	2256	"D02_RM02.wav"

e

</CsScore>
</CsoundSynthesizer>
