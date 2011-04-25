<CsoundSynthesizer>

; Id: F00_b.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF00_b.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
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
; FILTERED IMPULSES (I)
;=============================================
	instr 3
iamp	= ampdb(86+p4)
ifreq	= p5
ibw	= ifreq * .01		; filtered pulse's bandwidth 1% of central frequency

if1	= ifreq-(ibw/3)
if2	= ifreq+((2*ibw)/3)

				
a1	mpulse iamp , 0 

afilt	atonex a1 , if1 , 2
afilt	tonex afilt*900 , if2 , 2  
afilt	butterbp afilt*320 , ifreq , ibw*.05

aenv	linseg 1 , p3-.01, 1 , .01 , 0

aout	= afilt * aenv 

	out aout*(sr/192000)
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
; 160. MATERIAL F
; 161. total length: 114 cm, 4 sections
;
; sequence b1
;
; length    sequence 	
; 14     cm (1)
; 21     cm (2)

; sequence b2
;
; length    sequence 
; 31.6   cm (3)
; 47.4   cm (4)
;==================================================


;************************************************** b1
;==================================161.21
; 14 cm 12/11
;----------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]
i1	0	2.1	0	400	; S
i1	+	1.6	0	436     ; S
i1	+	2	0	476     ; S
i3	5.7	1.4	4	519     ; I
i1	7.1	1.5	0	566     ; S
i1	+	1.8	0	617     ; S
i3	10.4	2.3	2	673     ; I
i3	+	1.3	1.5	734     ; I
s                                   
t0	4572
;==================================161.22
; 21 cm 11/10
;----------------------------------------
i3	0	3.6	.5	800	; I
i3	+	2.7	0	872     ; I
i2	6.3	3.3	-6	951     ; R
i2	+	2.2	-6	1037    ; R
i3	11.8	2.4	-2	1131    ; I
i2	13.2	3	-4	1233    ; R
i2	+	1.8	-6	1345    ; R
i2	+	2	-6	1467    ; R
s                                   
t0	4572
;************************************************** b2
;==================================161.23
; 31.6 cm 10/9
;----------------------------------------
i2	0	3	-5	1532	; R
i2	+	5	-5	1405    ; R
i2	+	2.7	-5	1288    ; R
i2	+	4	-5	1181    ; R
i2	+	4.5	-5	1083    ; R
i2	+	5.5	-5	993     ; R
i2	+	3.3	-5	911     ; R
i2	+	3.6	-5	835     ; R
s                                   
t0	4572
;==================================161.24
; 47.4 cm 9/8
;----------------------------------------
i2	0	5.4	-4	766	; R
i2	+	3.8	-4	702     ; R
i2	+	4.8	-4	644     ; R
i2	+	7.7	-4	591     ; R
i2	+	8.6	-4	542     ; R
i2	+	4.2	-4	497     ; R
i2	+	6.1	-4	456     ; R
i2	+	6.8	-4	418     ; R
                                    
; total length: 114 cm
e
</CsScore>
</CsoundSynthesizer>