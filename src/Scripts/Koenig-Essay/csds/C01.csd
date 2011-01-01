<CsoundSynthesizer>

; Id: C01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oC01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

	zakinit 1 , 10
gifreq	init 0

;=============================================
; SINUS TONES (S)
;=============================================
	instr 1	
iamp	= ampdb(90+p4)
ifreq	= p5
gkfreq	= ifreq

a1	oscili iamp , ifreq , 1
aenv	linen 1 , .005 , p3 , .005

aout	= a1 * aenv

	out aout
	endin
;=============================================

;=============================================
; FILTERED NOISE (N)
;=============================================
	instr 2
iamp	= ampdb(90+p4)
ifreq	= p5
gkfreq	= ifreq
ibw	= ifreq * .05		; filtered noise's bandwidth 5% of central frequency

a1	rnd31 iamp , 1 
k1	rms a1

afilt	butterbp a1 , ifreq , ibw
afilt	butterbp afilt , ifreq , ibw

aenv	linen .9,  .01 , p3 , .005

aout	gain afilt , k1
aout	= aout * aenv 

	out aout
	endin
;=============================================

;=============================================
; FILTERED IMPULSES (I)
;=============================================
	instr 3
iamp	= ampdb(90+p4)
ifreq	= p5
gkfreq	= ifreq
ibw	= ifreq * .01		; filtered noise's bandwidth 5% of central frequency

if1	= ifreq-(ibw/3)
if2	= ifreq+((2*ibw)/3)

				
a1	mpulse iamp , 0 
k1	rms a1

afilt	atonex a1 , if1 , 4
afilt	tonex afilt*100 , if2 , 4
afilt	butterbp afilt*140 , ifreq , ibw *.5

aenv	linseg 1 , p3-.005, 1 , .005 , 0

aout	= afilt * aenv 

	out aout
	endin
;=============================================

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Ununderstandable instrument! (mg)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	instr 9
kfreq	= gkfreq
kndx	zkr 1

	tablew kfreq , kndx*.93 , 2 

kndx	= (kndx) + 1
	display kndx ,p3
	zkw kndx, 1
	endin
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


</CsInstruments>
<CsScore>	
;functions--------------------------------------------------
f1	0	8192	10	1	; sinusoid
f2	0	4096	-2 	0 0 2048 0
;/functions--------------------------------------------------

t0	4572	; 76.2 cm/sec. tape speed (durations in cm)
;test--------------------------------------------------
;mute--------------------------------------------------
q 1 0 1
q 2 0 1
q 3 0 1
;/mute-------------------------------------------------
;/test-------------------------------------------------

;==================================================
; 130. MATERIAL C
; 131. total length: 76 cm, 3 sections
;
; length   sequence 	
; 24    cm (2)
; 16    cm (1)
; 36    cm (3)
;==================================================

;==================================131.1
; 24 cm 11/10
;---------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]	
i1	0	2.1	0	200	; S
i1	+	4.1	0	400	; S
i1	+	3.1	0	238	; S
i1	+	2.5	0	800	; S
i1	+	2.3	0	476	; S
i1	+	3.4	0	1600	; S
i1	+	2.8	0	283	; S
i1	+	3.7	0	951	; S
                                    
i9	0	24
s
t0	4572	
;==================================131.2
; 16 cm 12/11
;---------------------------------------
i1	0	2.6	0	3200	; S
i1	+	2.4	0	566     ; S
i1	+	1.9	0	1903    ; S
i1	+	1.6	0	336     ; S
i1	+	1.5	0	6400    ; S
i1	+	2.1	0	1081    ; S
i1	+	1.7	0	3806    ; S
i1	+	2.2	0	673     ; S
                                    
i9	0	16
s
t0	4572	
;==================================131.3
; 36 cm 10/9
;---------------------------------------
i1	0	4.6	0	2263	; S
i1	+	4.2	0	7611    ; S
i1	+	3	0	1346    ; S
i1	+	5.7	0	4526    ; S
i1	+	5.1	0	2691    ; S
i1	+	3.4	0	9052    ; S
i1	+	6.3	0	5382    ; S
i1	+	3.7	0	10764   ; S

; total length: 76 cm

;-----------------------------------------------------------------------------------------------------------------
; NOTE
; the actual values for this last section in the Universal Edition score are wrong, as attested by a comunication 
; between Alvise Vidolin and G.M. Koenig. The values used here are the right values. Those given in the score 
; for 131.3 are the following
;
; 2.2 cm
; 2.5
; 2.7
; 3.0
; 3.4
; 3.7
; 4.2
; 4.6
; sequence: 5 4 1 7 6 2 8 3
;
; the right values are as follow
;
; 3.0 cm
; 3.4
; 3.7
; 4.2
; 4.6
; 5.1
; 5.7
; 6.3
; sequence: 5 4 1 7 6 2 8 3
;---------------------------------------------------------------------------------------------------------------------


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
i9	0	36
f3	36	4096	-24	2	0 1000 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
e
</CsScore>
</CsoundSynthesizer>