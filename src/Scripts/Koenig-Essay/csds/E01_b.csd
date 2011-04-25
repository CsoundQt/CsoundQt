<CsoundSynthesizer>

; Id: E01_b.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE01_b.wav
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
iamp	= ampdb(90+p4)
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
afilt	tonex afilt*1500 , if2 , 2  
afilt	butterbp afilt*5000 , ifreq , ibw*.01


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
; sequence b
;
; length    sequence 	
; 200.2  cm (8)
; 26.3   cm (3)
; 89     cm (6)
; 133.5  cm (7)
;==================================================

;==================================151.21
; 200.2 cm 5/4
;----------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]	
i3	0	30.8	5 	54	; I
i3	+	15.8	2 	77      ; I
i3	+	24.6	4 	59      ; I
i3	+	10.1	-1	109     ; I
i3	+	12.6	1 	84      ; I
i3	+	19.7	-4 	154     ; I
i3	+	38.5	-2	119     ; I
i3	+	48.1	3.5	65      ; I
s                                   
t0	4572	
;==================================151.22
; 26.3 cm 10/9
;----------------------------------------
i3	0	4.6	.5 	92	; I
i3	+	3.4	-7	218     ; I
i3	+	4.2	-5	168     ; I
i3	+	2.7	-2.5	130     ; I
i3	+	3	-8	238     ; I
i3	+	3.7	3	71      ; I
i3	+	2.2	-10 	308     ; I
i3	+	2.5	-5.5	183     ; I
s                                   
t0	4572	
;==================================151.23
; 89 cm 7/6
;----------------------------------------
i3	0	8.3	0	100	; I
i3	+	17.9	-11	336     ; I
i3	+	7.1	-8.5	259     ; I
i3	+	13.2	-3	141     ; I
i3	+	15.4	-13	436     ; I
i3	+	6.1	-6	200     ; I
i3	+	9.7	-11.5	367     ; I
i3	+	11.3	-14	476     ; I
s                                   
t0	4572	
;==================================151.24
; 133.5 cm 6/5
;----------------------------------------
i3	0	14	-9 	283	; I
i3	+	8.1	-14.5	519     ; I
i3	+	11.6	-12	400     ; I
i3	+	24.2	-16	617     ; I
i3	+	29	-17	673     ; I
i3	+	9.7	-15	566     ; I
i3	+	16.8	-17	734     ; I
i3	+	20.1	-18	800     ; I
                                    
; total length E(b): 449 cm
e
</CsScore>
</CsoundSynthesizer>