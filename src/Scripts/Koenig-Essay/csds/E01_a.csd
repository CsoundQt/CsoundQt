<CsoundSynthesizer>

; Id: E01_a.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE01_a.wav
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
afilt	tonex afilt*100 , if2 , 2  
afilt	butterbp afilt*900 , ifreq , ibw*.05


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
; sequence a
;
; length    sequence 	
; 133.5  cm (7)
; 89     cm (6)
; 26.3   cm (3)
; 200.2  cm (8)
;==================================================

;==================================151.11
; 133.5 cm 6/5
;----------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]	
i3	0	20.1	-10	11763	; I
i3	+	16.8	-8	8300    ; I
i3	+	9.7	-9.5	10763   ; I
i3	+	29	-5.5	5869    ; I
i3	+	24.2	-7	7611    ; I
i3	+	11.6	-3	4150    ; I
i2	111.4	8.1	-3	5382    ; R
i3	119.5	14	-9	9870	; I
s                                   
t0	4572	
;==================================151.12
; 89 cm 7/6
;----------------------------------------
i3	0	11.3	-6.5	6979	; I
i3	+	9.7	-.5	2934    ; I
i3	+	6.1	-2.5	3805    ; I
i2	27.1	15.4	-4	4935    ; R
i2	+	13.2	-4	2691    ; R
i3	55.7	7.1	-8.5	9051    ; I
i3	+	17.9	2.5	2075    ; I
i3	+	8.3	-2	3490    ; I
s                                   
t0	4572	
;==================================151.13
; 26.3 cm 10/9
;----------------------------------------
i2	0	2.5	-5	6400	; R
i2	+	2.2	-5	1903    ; R
i2	+	3.7	-5	2468    ; R
i3	8.4	3	-3.5	4525    ; I
i3	+	2.7	5	1467    ; I
i2	14.1	4.2	-6	3200    ; R
i2	+	3.4	-6	1745    ; R
i2	+	4.6	-6	1345    ; R
s                                   
t0	4572	
;==================================151.14
; 200.2 cm 5/4
;----------------------------------------
i2	0	48.1	-5	2263	; R
i3	48.1	38.5	6.5	1234    ; I
i2	86.6	19.7	-4	1600    ; R
i2	+	12.6	-4	1037    ; R
i2	+	10.1	-4	951     ; R
i2	+	24.6	-4	1131    ; R
i2	+	15.8	-4	872     ; R
i2	+	30.8	-4	800     ; R
                                    
; total length E(a): 449 cm
e

</CsScore>
</CsoundSynthesizer>