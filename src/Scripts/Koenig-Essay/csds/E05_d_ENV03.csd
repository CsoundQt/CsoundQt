<CsoundSynthesizer>

; Id: E05_d_ENV03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE05_d_ENV03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 255.d.3 INTENSITY CURVES
;=============================================
	instr 1
iamp	= ampdb(90+p4)/ 28965

ifile	= p5

a1	diskin2  ifile, 1, 5.6

aenv	expseg iamp , p3-.1 , iamp , .1 , .001

aout	=  a1*aenv 

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	
;			iamp1	ifile
;			[dB]	
i1	0	292.2	-10	"E04_d_REV03.wav"
;		16
e

</CsScore>
</CsoundSynthesizer>