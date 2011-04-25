<CsoundSynthesizer>

; Id: F04_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_F.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1


;============================================
; 361-446 ENTRY DELAYS & SYNCHRONIZATION
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
i1	0	3504	1 	"F03_TR01.wav"	; A.O. 1706.88				
i1	1786.58	876	1 	"F03_TR02.wav"	; A.O. 2167.58(A.O.TR01+460.7)		
i1	2181.88	438	1 	"F03_TR03.wav"	; A.O. 2372.38(A.O.TR02+204.8)		
i1	1746.88	1752	1 	"F03_TR04.wav"	; A.O. 2508.88(A.O.TR03+136.5) 		

; NOTE
; A.O. = start of the original
; the actual starting value is obtained by subtracting to the A.O. values the length of the transposed
; reverb (wich is reversed). See F03_TR01-04.

e

</CsScore>
</CsoundSynthesizer>