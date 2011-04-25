<CsoundSynthesizer>

; Id: E01_d.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE01_d.wav
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
iamp	= ampdb(91+p4)
ifreq	= p5
ibw	= ifreq * .01		; filtered pulse's bandwidth 1% of central frequency

if1	= ifreq-(ibw/3)
if2	= ifreq+((2*ibw)/3)

				
a1	mpulse iamp , 0 

afilt	atonex a1 , if1 , 2
afilt	tonex afilt*300 , if2 , 2  
afilt	butterbp afilt*1500 , ifreq , ibw*.01


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
; 150. MATERIAL E
; 151. total length: 577.1 cm, 8 sections
;
; sequence d
;
; length    sequence 	
; 39.5   cm (4)
; 11.7   cm (1)
; 17.6   cm (2)
; 59.3   cm (5)
;==================================================

;==================================151.41
; 39.5 cm 9/8
;----------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]
i1	0	6.4	0	734	; S
i2	6.4	5.7	-3	673     ; R
i3	12.1	4	8.5	617     ; I
i1	16.1	3.2	0	566     ; S
i2	19.3	7.2	-3	400     ; R
i3	26.5	4.5	11.5	436     ; I
i1	31	3.5	0	476     ; S
i2	34.5	5	-3	283     ; R
s                                   
t0	4572
;==================================151.42
; 11.7 cm 12/11
;----------------------------------------
i3	0	1.3	10	519	; I
i1	1.3	1.2	0	308     ; S
i2	2.5	1.7	-3	200	; R
i3	4.2	1.5	14	336     ; I
i1	5.7	1.4	0	141     ; S
i2	7.1	1.9	-3	218     ; R
i3	9	1.6	13	367     ; I
i1	10.6	1.1	0	100     ; S
s                                   
t0	4572
;==================================151.43
; 17.6 cm 11/10
;----------------------------------------
i2	0	1.5	-3	238	; R
i3	1.5	2.9	20.5	154     ; I
i1	4.4	2.3	0	71      ; S
i2	6.7	1.9	-3	50      ; R
i3	8.6	1.7	16	259     ; I
i1	10.3	2.5	0	109     ; S
i2	12.8	2.1	-3	168     ; R
i3	14.9	2.7	26.5	77      ; I
s                                   
t0	4572
;==================================151.44
; 59.3 cm 8/7
;----------------------------------------
i1	0	6.6	0	183	; S
i2	6.6	5.8	-4	119     ; R
i3	12.4	11.3	29.5	54      ; I
i1	23.7	8.6	0	84      ; S
i2	32.3	7.6	-3	130     ; R
i3	39.9	4.4	29	59      ; I
i1	44.3	9.9	0	92      ; S
i2	54.2	5.1	-3	65      ; R
                                    
; total length E(d): 128.1 cm
e

</CsScore>
</CsoundSynthesizer>