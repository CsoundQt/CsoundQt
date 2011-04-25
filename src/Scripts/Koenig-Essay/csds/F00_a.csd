<CsoundSynthesizer>

; Id: F00_a.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF00_a.wav
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
iamp	= ampdb(90+p4)
ifreq	= p5
ibw	= ifreq * .01		; filtered pulse's bandwidth 1% of central frequency

if1	= ifreq-(ibw/3)
if2	= ifreq+((2*ibw)/3)

				
a1	mpulse iamp , 0 

afilt	atonex a1 , if1 , 2
afilt	tonex afilt*100 , if2 , 2  
afilt	butterbp afilt*32 , ifreq , ibw*.5

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
; sequence a
;
; length    sequence 	
; 21     cm (2)
; 14     cm (1)
; 47.4   cm (4)
; 31.6   cm (3)
;==================================================

;==================================161.11
; 21 cm 11/10
;----------------------------------------
;			p4	p5
;			iamp	ifreq	timbre
;			[dB]	[Hz]
i1	0	2	0	336	; S
i1	+	1.8	0	319     ; S
i1	+	3	0	302     ; S
i1	+	2.4	0	286     ; S
i1	+	2.2	0	271     ; S
i1	+	3.3	0	257     ; S
i2	14.7	2.7	-9	243     ; R
i1	17.4	3.6	0	230     ; S
s                                   
t0	4572
;==================================161.12
; 14 cm 12/11
;----------------------------------------
; x
i1	0	1.3	-6	309	; S
i1	+	2.3	-6	302     ; S
i1	+	1.8	-6	283     ; S
i2	5.4	1.5	-10	322     ; R
i2	+	1.4	-10	315     ; R
i1	8.3	2	-6	289     ; S
i1	+	1.6	-6	329     ; S
i1	+	2.1	-6	295     ; S
; y                                 
i1	0	1.3	-6	238	; S
i1	+	2.3	-6	248     ; S
i1	+	1.8	-6	259     ; S
i2	5.4	1.5	-10	271     ; R
i2	+	1.4	-10	277     ; R
i1	8.3	2	-6	265     ; S
i1	+	1.6	-6	254     ; S
i1	+	2.1	-6	243     ; S
s                                   
t0	4572
;==================================161.13
; 47.4 cm 9/8
;----------------------------------------
i2	0	6.8	-4	271	; R
i2	+	6.1	-4	268     ; R
i2	+	4.2	-4	259     ; R
i1	17.1	8.6	0	277     ; S
i1	+	7.7	0	274     ; S
i2	33.4	4.8	-4	262     ; R
i2	+	3.8	-4	280     ; R
i2	+	5.4	-4	265     ; R
s                                   
t0	4572
;==================================161.14
; 31.6 cm 10/9
;----------------------------------------
; x
i2	0	3.6	-10	228	; R
i1	3.6	3.3	-6	221     ; S
i2	6.9	5.5	-10	200     ; R
i2	+	4.5	-10	243     ; R
i2	+	4	-10	235     ; R
i2	+	2.7	-10	207     ; R
i2	+	5	-10	251     ; R
i2	+	3	-10	213     ; R
; y                                 
i2	0	3.6	-10	367	; R
i1	3.6	3.3	-6	336     ; S
i2	6.9	5.5	-10	308     ; R
i2	+	4.5	-10	283     ; R
i2	+	4	-10	271     ; R
i2	+	2.7	-10	295     ; R
i2	+	5	-10	322     ; R
i2	+	3	-10	351     ; R
                                    
; total length: 114 cm
e
</CsScore>
</CsoundSynthesizer>