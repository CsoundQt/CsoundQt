<CsoundSynthesizer>

; Id: E01_c.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE01_c.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; SINUS TONES (S)
;=============================================
	instr 1	
iamp	= ampdb(90+p4)
ifreq	= p5

a1	oscili iamp , ifreq , 1
aenv	expseg .001 , .005, 1 , p3-.01 ,1, .005,.001

aout	= a1 * aenv

	out aout
	endin
;=============================================

;=============================================
; FILTERED NOISE (N)
;=============================================
	instr 2
iamp	= ampdb(87+p4)
ifreq	= p5
ibw	= ifreq * .05		; filtered noise's bandwidth 5% of central frequency

a1	rnd31 iamp , 1 
k1	rms a1

afilt	butterbp a1 , ifreq , ibw
afilt	butterbp afilt , ifreq , ibw

aenv	expseg .001 , .005, .8 , p3-.01 ,.8 ,.005,.001

aout	gain afilt , k1
aout	= aout * aenv 

	out aout
	endin
;=============================================

;=============================================
; IMPULSI FILTRATI
;=============================================
	instr 3
iamp	= ampdb(86+p4)
ifreq	= p5
ibw	= ifreq * .01		; filtered pulse's bandwidth 1% of central frequency

if1	= ifreq-(ibw/3)
if2	= ifreq+((2*ibw)/3)

				
a1	mpulse iamp , 0 

afilt	atonex a1 , if1 , 2
afilt	tonex afilt*200 , if2 , 2  
afilt	butterbp afilt*72 , ifreq , ibw*.5


aenv	linseg 1 , p3-.01, 1 , .01 , 0

aout	= afilt * aenv 

	out aout
	endin
;=============================================
</CsInstruments>
<CsScore>
;functions--------------------------------------------------
f1	0	8192	10	1	; sinusoid
;/functions--------------------------------------------------

t0	4572	; 76.2 cm/sec. tape speed (durations in cm)

;test--------------------------------------------------
;mute-------------------------------------------------
q 1 0 1
q 2 0 1
q 3 0 1
;/mute-------------------------------------------------
;/test-------------------------------------------------

;====================================================
; 150. MATERIAL E
; 151. total length: 577.1 cm, 8 sections
;
; sequence c
;
; length    sequence 	
; 59.3   cm (5)
; 17.6   cm (2)
; 11.7   cm (1)
; 39.5   cm (4)
;==================================================

;==================================151.31
; 59.3 cm 8/7
;----------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]
i3	0	5.1	6	872	; I
i3	+	9.9	5	951     ; I
i3	+	4.4	4.5	1037    ; I
i3	+	7.6	4	1131    ; I
i1	27	8.6	-1	1600    ; S
i3	35.6	11.3	1.5	1467    ; I
i3	+	5.8	2	1345    ; I
i3	+	6.6	-2	2263    ; I
s                                   
t0	4572
;==================================151.32
; 17.6 cm 11/10
;----------------------------------------
i1	0	2.7	0	1234	; S
i1	+	2.1	0	2075    ; S
i3	4.8	2.5	-4.5	3200    ; I
i3	+	1.7	-.5	1903    ; I
i1	9	1.9	0	4525    ; S
i1	+	2.3	0	2934    ; S
i1	+	2.9	0	1745    ; S
i3	16.1	1.5	-10	6400    ; I
s                                   
t0	4572
;==================================151.33
; 11.7 cm 12/11
;----------------------------------------
i2	0	1.1	-3	2691	; R
i1	1.1	1.6	0	4150	; S
i1	+	1.9	0	9051    ; S
i1	+	1.4	0	12800   ; S
i2	6	1.5	-3	2468    ; R
i2	+	1.7	-3	5869    ; R
i1	9.2	1.2	0	3805    ; S
i1	+	1.3	0	8300    ; S
s                                   
t0	4572
;==================================151.34
; 39.5 cm 9/8
;----------------------------------------
i2	0	5	-5	3490	; R
i2	+	3.5	-5	5382    ; R
i2	+	4.5	-5	11738   ; R
i3	13	7.2	-11	7611    ; S
i2	20.2 	3.2	-5	4935    ; R
i2	+	4	-5	10763   ; R
i2	+	5.7	-5	6979    ; R
i2	+	6.4	-5	9870    ; R
                                    
; total length E(c): 128.1 cm
e
</CsScore>
</CsoundSynthesizer>