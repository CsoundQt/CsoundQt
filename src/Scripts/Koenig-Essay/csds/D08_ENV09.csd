<CsoundSynthesizer>

; Id: D08_ENV09.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD08_ENV09.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 245.9 INTENSITY CURVES
;=============================================
	instr 1
idur	= p3

a1	diskin2  "D07_TR09a.wav", 1
a2	diskin2  "D07_TR09b.wav", 1

aout	=  (a1*.75)+(a2*.5)
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			
;			
i1	0	1246.7		

e

</CsScore>
</CsoundSynthesizer>