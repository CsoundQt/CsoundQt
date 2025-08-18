; "Diffamator"
; by Andres Cabrera
;
; Diffamator Version 0.91
; by Andrés Cabrera (GUI by my wife Cristina =) )
; Released under the GPL license.
; 
; CsoundQt version by Rene Djack Sept. 2010
;
; Diffamator is an MIDI controlled FM synth which can be randomized to find interesting sounds. It features the same algorithms available in the Yamaha DX7 synth, but might not really sound exactly like it, since not all of the synth is implemented. It can also store presets in one of its 30 memory slots.
; 
; SETUP
; You will need to tell Csound to run in realtime with audio output and MIDI input, which varies according to platform.
; You can adjust maximum polyphony for your system with the opcode maxalloc.
; The ksmps size has a very clear effect on the sound of feedback. Lower values yield a 'smoother' Feedback but reduces polyphony.
; 
; USING
; MIDI notes (on any channel) trigger the sound. You can control each FM operator's ADSR envelope, frequency ratio and phase separately, or you can use the transformation buttons to randomize and manipulate parameters. Diffamator uses the same algorithms as the Yamaha DX7. You can find them at
; http //www.adp-gmbh.ch/csound/dx7/algorithms.html
; 
; The transform(q)ation buttons do the following (the letter in parenthesis determines the key that can trigger that button):
; 
; Rand Mus (q)- Randomizes all Operator parameters, algorithm and feedback but keeping ratios in 0.5 multiple ratios, which tend to generate harmonic spectra
; 
; Rand FX (w)- Exactly as before, but ratios are completely randomized, generating mostly noisy and in-harmonic spectra
; 
; Attackify (e)- Shortens the attack and decay times, and decreases sustain level to all operators, effectively making the sound more percussive.
; 
; Padify (r)- Lengthens the attack and decay times to smooth the onset of the sound
; 
; + Harm (t)- Moves the frequency ratios toward multiples of 0.5, making the sound tend to a more harmonic spectrum
; 
; - Harm (y)- Slightly randomizes the frequency ratios, slowly turning a harmonic sound into an in-harmonic one.
; 
; Switch + (u)- Switches Operator parameters one operator down
; 
; Switch - (i)- Switches Operator parameters one operator up.
; 
; You can also use the 'i Print' button to generate a score file line which will trigger the current sound using only instrument 10 (i.e. you only need instrument 10 if you use this line. All the rest can be discarded. This is useful for using diffamator in your own compositions. In the GUI you can set the base frequency, duration and velocity of the event. Otherwise, you can modify the p-fields of the generated score event. p3 is duration, p4 is base frequency, and p5 is the velocity (1-127).
; The lock toggle locks the algorithm so it's not modified when Diffamator is randomized.
; 
; Other Keyboard shortcuts
; ---------------------
; o - Increments the algorithm number
; p - Decrements the algorithm number
; 
; Presets
; -------
; To recall a preset, just use the preset menu.
; To store a new preset or modify an existing preset, use CsoundQt Preset facilities.
; 
; Please send problems, comments and suggestions to mantaraya36 at gmail or the csound mailing list.
; 
; Enjoy!
; 
;
<CsoundSynthesizer>
<CsOptions>
-+max_str_len=4096
;-fdm0
</CsOptions>
<CsInstruments>

sr		= 48000
ksmps	= 10
nchnls	= 2

			maxalloc		1, 16		;Adjust maxalloc according to your system
			massign		0, 10

gafeedback	init		0
gisine		ftgen	0,0, 4096, 10, 1
			seed		0

instr	1		;GUI
	ktrig	metro	10

	if (ktrig == 1)	then
		;OP1
		gkatt1		invalue		"OP1_A"
		gkdec1		invalue		"OP1_D"
		gksus1		invalue		"OP1_S"
		gkrel1		invalue		"OP1_R"
		gklvl1		invalue		"OP1_Lev"
		gkrat1		invalue		"OP1_Ratio"
		gkinv1		invalue		"OP1_Inv"
		;OP2
		gkatt2		invalue		"OP2_A"
		gkdec2		invalue		"OP2_D"
		gksus2		invalue		"OP2_S"
		gkrel2		invalue		"OP2_R"
		gklvl2		invalue		"OP2_Lev"
		gkrat2		invalue		"OP2_Ratio"
		gkinv2		invalue		"OP2_Inv"
		;OP3
		gkatt3		invalue		"OP3_A"
		gkdec3		invalue		"OP3_D"
		gksus3		invalue		"OP3_S"
		gkrel3		invalue		"OP3_R"
		gklvl3		invalue		"OP3_Lev"
		gkrat3		invalue		"OP3_Ratio"
		gkinv3		invalue		"OP3_Inv"
		;OP4
		gkatt4		invalue		"OP4_A"
		gkdec4		invalue		"OP4_D"
		gksus4		invalue		"OP4_S"
		gkrel4		invalue		"OP4_R"
		gklvl4		invalue		"OP4_Lev"
		gkrat4		invalue		"OP4_Ratio"
		gkinv4		invalue		"OP4_Inv"
		;OP5
		gkatt5		invalue		"OP5_A"
		gkdec5		invalue		"OP5_D"
		gksus5		invalue		"OP5_S"
		gkrel5		invalue		"OP5_R"
		gklvl5		invalue		"OP5_Lev"
		gkrat5		invalue		"OP5_Ratio"
		gkinv5		invalue		"OP5_Inv"
		;OP6
		gkatt6		invalue		"OP6_A"
		gkdec6		invalue		"OP6_D"
		gksus6		invalue		"OP6_S"
		gkrel6		invalue		"OP6_R"
		gklvl6		invalue		"OP6_Lev"
		gkrat6		invalue		"OP6_Ratio"
		gkinv6		invalue		"OP6_Inv"

		gkfeedback	invalue		"Feedback"
		gkalgo		invalue		"Algorithm"
		gkalglock		invalue		"Lock"
	endif
endin


instr	2		;Rand FX
	irand	random	0,1
			outvalue	"OP1_Lev", irand
	irand	random	0,1
			outvalue	"OP2_Lev", irand
	irand	random	0,1
			outvalue	"OP3_Lev", irand
	irand	random	0,1
			outvalue	"OP4_Lev", irand
	irand	random	0,1
			outvalue	"OP5_Lev", irand
	irand	random	0,1
			outvalue	"OP6_Lev", irand
	irand	random	0,3
			outvalue	"OP1_Ratio", irand
	irand	random	0,3
			outvalue	"OP2_Ratio", irand
	irand	random	0,3
			outvalue	"OP3_Ratio", irand
	irand	random	0,3
			outvalue	"OP4_Ratio", irand
	irand	random	0,3
			outvalue	"OP5_Ratio", irand
	irand	random	0,3
			outvalue	"OP6_Ratio", irand
	irand	random	0,1
			outvalue	"OP1_A", irand
	irand	random	0,1
			outvalue	"OP2_A", irand
	irand	random	0,1
			outvalue	"OP3_A", irand
	irand	random	0,1
			outvalue	"OP4_A", irand
	irand	random	0,1
			outvalue	"OP5_A", irand
	irand	random	0,1
			outvalue	"OP6_A", irand
	irand	random	-0.5,0
			outvalue	"OP1_D", irand
	irand	random	0,0.5
			outvalue	"OP2_D", irand
	irand	random	0,0.5
			outvalue	"OP3_D", irand
	irand	random	0,0.5
			outvalue	"OP4_D", irand
	irand	random	0,0.5
			outvalue	"OP5_D", irand
	irand	random	0,0.5
			outvalue	"OP6_D", irand
	irand	random	0,1
			outvalue	"OP1_S", irand
	irand	random	0,1
			outvalue	"OP2_S", irand
	irand	random	0,1
			outvalue	"OP3_S", irand
	irand	random	0,1
			outvalue	"OP4_S", irand
	irand	random	0,1
			outvalue	"OP5_S", irand
	irand	random	0,1
			outvalue	"OP6_S", irand
	irand	random	0,3
			outvalue	"OP1_R", irand
	irand	random	0,3
			outvalue	"OP2_R", irand
	irand	random	0,3
			outvalue	"OP3_R", irand
	irand	random	0,3
			outvalue	"OP4_R", irand
	irand	random	0,3
			outvalue	"OP5_R", irand
	irand	random	0,3
			outvalue	"OP6_R", irand
	if (i(gkalglock)==0) then
		irand	random	1,32
		irand	=		int(irand)
				outvalue	"Algorithm", irand
	endif
	irand	random	0,1
			outvalue	"Feedback", irand
endin

instr	3		;Rand Mus
	irand	random	0,1
			outvalue	"OP1_Lev", irand
	irand	random	0,1
			outvalue	"OP2_Lev", irand
	irand	random	0,1
			outvalue	"OP3_Lev", irand
	irand	random	0,1
			outvalue	"OP4_Lev", irand
	irand	random	0,1
			outvalue	"OP5_Lev", irand
	irand	random	0,1
			outvalue	"OP6_Lev", irand
	irand	random	0,11
	irand	=		(int(irand)/2)+0.5	
			outvalue	"OP1_Ratio", irand
	irand	random	0,11
	irand	=		(int(irand)/2)+0.5	
			outvalue	"OP2_Ratio", irand
	irand	random	0,11
	irand	=		(int(irand)/2)+0.5	
			outvalue	"OP3_Ratio", irand
	irand	random	0,11
	irand	=		(int(irand)/2)+0.5	
			outvalue	"OP4_Ratio", irand
	irand	random	0,11
	irand	=		(int(irand)/2)+0.5	
			outvalue	"OP5_Ratio", irand
	irand	random	0,11
	irand	=		(int(irand)/2)+0.5	
			outvalue	"OP6_Ratio", irand
	irand	random	0,1
			outvalue	"OP1_A", irand
	irand	random	0,1
			outvalue	"OP2_A", irand
	irand	random	0,1
			outvalue	"OP3_A", irand
	irand	random	0,1
			outvalue	"OP4_A", irand
	irand	random	0,1
			outvalue	"OP5_A", irand
	irand	random	0,1
			outvalue	"OP6_A", irand
	irand	random	0,0.5
			outvalue	"OP1_D", irand
	irand	random	0,0.5
			outvalue	"OP2_D", irand
	irand	random	0,0.5
			outvalue	"OP3_D", irand
	irand	random	0,0.5
			outvalue	"OP4_D", irand
	irand	random	0,0.5
			outvalue	"OP5_D", irand
	irand	random	0,0.5
			outvalue	"OP6_D", irand
	irand	random	0,1
			outvalue	"OP1_S", irand
	irand	random	0,1
			outvalue	"OP2_S", irand
	irand	random	0,1
			outvalue	"OP3_S", irand
	irand	random	0,1
			outvalue	"OP4_S", irand
	irand	random	0,1
			outvalue	"OP5_S", irand
	irand	random	0,1
			outvalue	"OP6_S", irand
	irand	random	0,3
			outvalue	"OP1_R", irand
	irand	random	0,3
			outvalue	"OP2_R", irand
	irand	random	0,3
			outvalue	"OP3_R", irand
	irand	random	0,3
			outvalue	"OP4_R", irand
	irand	random	0,3
			outvalue	"OP5_R", irand
	irand	random	0,3
			outvalue	"OP6_R", irand
	if (i(gkalglock)==0) then
		irand	random	1,32
		irand	=		int(irand)
				outvalue	"Algorithm", irand
	endif
	irand	random	0,0.5
			outvalue	"Feedback", irand
endin

instr	4		;Rand more harm
	irat		=		i(gkrat1)
	inewrat	=		((irat*4) + (int((irat*2)+0.5) /2))/5
	
	print irat
	print inewrat
	
			outvalue 	"OP1_Ratio", inewrat
	irat		=		i(gkrat2)
	inewrat	=		((irat*4) + (int((irat*2)+0.5) /2))/5
			outvalue	"OP2_Ratio", inewrat
	irat		=		i(gkrat3)
	inewrat	=		((irat*4) + (int((irat*2)+0.5) /2))/5
			outvalue	"OP3_Ratio", inewrat
	irat		=		i(gkrat4)
	inewrat	=		((irat*4) + (int((irat*2)+0.5) /2))/5
			outvalue	"OP4_Ratio", inewrat
	irat		=		i(gkrat5)
	inewrat	=		((irat*4) + (int((irat*2)+0.5) /2))/5
			outvalue	"OP5_Ratio", inewrat
	irat		=		i(gkrat6)
	inewrat	=		((irat*4) + (int((irat*2)+0.5) /2))/5
			outvalue	"OP6_Ratio", inewrat
endin

instr	5		;Rand less harm
	irat		=		i(gkrat1)
	irand	random	-0.02,0.02
	inew		=		irat + irand
			outvalue	"OP1_Ratio", inew
	irat		=		i(gkrat2)
	irand	random	-0.02,0.02
	inew		=		irat + irand
			outvalue	"OP2_Ratio", inew
	irat		=		i(gkrat3)
	irand	random	-0.02,0.02
	inew		=		irat + irand
			outvalue	"OP3_Ratio", inew
	irat		=		i(gkrat4)
	irand	random	-0.02,0.02
	inew		=		irat + irand
			outvalue	"OP4_Ratio", inew
	irat		=		i(gkrat5)
	irand	random	-0.02,0.02
	inew		=		irat + irand
			outvalue	"OP5_Ratio", inew
	irat		=		i(gkrat6)
	irand	random	-0.02,0.02
	inew		=		irat + irand
			outvalue	"OP6_Ratio", inew
endin

instr	6		;Attackify
	ival		=		i(gkatt1)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP1_A", ival
	ival		=		i(gkatt2)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP2_A", ival
	ival		=		i(gkatt3)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP3_A", ival
	ival		=		i(gkatt4)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP4_A", ival
	ival		=		i(gkatt5)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP5_A", ival
	ival		=		i(gkatt6)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP6_A", ival
	ival		=		i(gkdec1)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP1_D", ival
	ival		=		i(gkdec2)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP2_D", ival
	ival		=		i(gkdec3)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP3_D", ival
	ival		=		i(gkdec4)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP4_D", ival
	ival		=		i(gkdec5)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP5_D", ival
	ival		=		i(gkdec6)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP6_D", ival
	ival		=		i(gksus1)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP1_S", ival
	ival		=		i(gksus2)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP2_S", ival
	ival		=		i(gksus3)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP3_S", ival
	ival		=		i(gksus4)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP4_S", ival
	ival		=		i(gksus5)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP5_S", ival
	ival		=		i(gksus6)
	ival		=		(ival>0.01?ival-0.01:ival)
			outvalue	"OP6_S", ival
endin

instr	7		;Padify
	ival		=		i(gkatt1)
	ival		=		(ival<0.99?ival+0.01:ival)
			outvalue	"OP1_A", ival
	ival		=		i(gkatt2)
	ival		=		(ival<0.99?ival+0.01:ival)
			outvalue	"OP2_A", ival
	ival		=		i(gkatt3)
	ival		=		(ival<0.99?ival+0.01:ival)
			outvalue	"OP3_A", ival
	ival		=		i(gkatt4)
	ival		=		(ival<0.99?ival+0.01:ival)
			outvalue	"OP4_A", ival
	ival		=		i(gkatt5)
	ival		=		(ival<0.99?ival+0.01:ival)
			outvalue	"OP5_A", ival
	ival		=		i(gkatt6)
	ival		=		(ival<0.99?ival+0.01:ival)
			outvalue	"OP6_A", ival
	ival		=		i(gkdec1)
	ival		=		(ival<0.495?ival+0.005:ival)
			outvalue	"OP1_D", ival
	ival		=		i(gkdec2)
	ival		=		(ival<0.495?ival+0.005:ival)
			outvalue	"OP2_D", ival
	ival		=		i(gkdec3)
	ival		=		(ival<0.495?ival+0.005:ival)
			outvalue	"OP3_D", ival
	ival		=		i(gkdec4)
	ival		=		(ival<0.495?ival+0.005:ival)
			outvalue	"OP4_D", ival
	ival		=		i(gkdec5)
	ival		=		(ival<0.495?ival+0.005:ival)
			outvalue	"OP5_D", ival
	ival		=		i(gkdec6)
	ival		=		(ival<0.495?ival+0.005:ival)
			outvalue	"OP6_D", ival
endin

instr	8		;Switch +
	ival		=		i(gklvl5)
			outvalue	"OP6_Lev", ival
	ival		=		i(gklvl4)
			outvalue	"OP5_Lev", ival
	ival		=		i(gklvl3)
			outvalue	"OP4_Lev", ival
	ival		=		i(gklvl2)
			outvalue	"OP3_Lev", ival
	ival		=		i(gklvl1)
			outvalue	"OP2_Lev", ival
	ival		=		i(gklvl6)
			outvalue	"OP1_Lev", ival
	ival		=		i(gkrat5)
			outvalue	"OP6_Ratio", ival
	ival		=		i(gkrat4)
			outvalue	"OP5_Ratio", ival
	ival		=		i(gkrat3)
			outvalue	"OP4_Ratio", ival
	ival		=		i(gkrat2)
			outvalue	"OP3_Ratio", ival
	ival		=		i(gkrat1)
			outvalue	"OP2_Ratio", ival
	ival		=		i(gkrat6)
			outvalue	"OP1_Ratio", ival
	ival		=		i(gkinv5)
			outvalue	"OP6_Inv", ival
	ival		=		i(gkinv4)
			outvalue	"OP5_Inv", ival
	ival		=		i(gkinv3)
			outvalue	"OP4_Inv", ival
	ival		=		i(gkinv2)
			outvalue	"OP3_Inv", ival
	ival		=		i(gkinv1)
			outvalue	"OP2_Inv", ival
	ival		=		i(gkinv6)
			outvalue	"OP1_Inv", ival
	ival		=		i(gkatt5)
			outvalue	"OP6_A", ival
	ival		=		i(gkatt4)
			outvalue	"OP5_A", ival
	ival		=		i(gkatt3)
			outvalue	"OP4_A", ival
	ival		=		i(gkatt2)
			outvalue	"OP3_A", ival
	ival		=		i(gkatt1)
			outvalue	"OP2_A", ival
	ival		=		i(gkatt6)
			outvalue	"OP1_A", ival
	ival		=		i(gkdec5)
			outvalue	"OP6_D", ival
	ival		=		i(gkdec4)
			outvalue	"OP5_D", ival
	ival		=		i(gkdec3)
			outvalue	"OP4_D", ival
	ival		=		i(gkdec2)
			outvalue	"OP3_D", ival
	ival		=		i(gkdec1)
			outvalue	"OP2_D", ival
	ival		=		i(gkdec6)
			outvalue	"OP1_D", ival
	ival		=		i(gksus5)
			outvalue	"OP6_S", ival
	ival		=		i(gksus4)
			outvalue	"OP5_S", ival
	ival		=		i(gksus3)
			outvalue	"OP4_S", ival
	ival		=		i(gksus2)
			outvalue	"OP3_S", ival
	ival		=		i(gksus1)
			outvalue	"OP2_S", ival
	ival		=		i(gksus6)
			outvalue	"OP1_S", ival
	ival		=		i(gkrel5)
			outvalue	"OP6_R", ival
	ival		=		i(gkrel4)
			outvalue	"OP5_R", ival
	ival		=		i(gkrel3)
			outvalue	"OP4_R", ival
	ival		=		i(gkrel2)
			outvalue	"OP3_R", ival
	ival		=		i(gkrel1)
			outvalue	"OP2_R", ival
	ival		=		i(gkrel6)
			outvalue	"OP1_R", ival
endin

instr	9		;Switch -
	ival		=		i(gklvl2)
			outvalue	"OP1_Lev", ival
	ival		=		i(gklvl3)
			outvalue	"OP2_Lev", ival
	ival		=		i(gklvl4)
			outvalue	"OP3_Lev", ival
	ival		=		i(gklvl5)
			outvalue	"OP4_Lev", ival
	ival		=		i(gklvl6)
			outvalue	"OP5_Lev", ival
	ival		=		i(gklvl1)
			outvalue	"OP6_Lev", ival
	ival		=		i(gkrat2)
			outvalue	"OP1_Ratio", ival
	ival		=		i(gkrat3)
			outvalue	"OP2_Ratio", ival
	ival		=		i(gkrat4)
			outvalue	"OP3_Ratio", ival
	ival		=		i(gkrat5)
			outvalue	"OP4_Ratio", ival
	ival		=		i(gkrat6)
			outvalue	"OP5_Ratio", ival
	ival		=		i(gkrat1)
			outvalue	"OP6_Ratio", ival
	ival		=		i(gkinv2)
			outvalue	"OP1_Inv", ival
	ival		=		i(gkinv3)
			outvalue	"OP2_Inv", ival
	ival		=		i(gkinv4)
			outvalue	"OP3_Inv", ival
	ival		=		i(gkinv5)
			outvalue	"OP4_Inv", ival
	ival		=		i(gkinv6)
			outvalue	"OP5_Inv", ival
	ival		=		i(gkinv1)
			outvalue	"OP6_Inv", ival
	ival		=		i(gkatt2)
			outvalue	"OP1_A", ival
	ival		=		i(gkatt3)
			outvalue	"OP2_A", ival
	ival		=		i(gkatt4)
			outvalue	"OP3_A", ival
	ival		=		i(gkatt5)
			outvalue	"OP4_A", ival
	ival		=		i(gkatt6)
			outvalue	"OP5_A", ival
	ival		=		i(gkatt1)
			outvalue	"OP6_A", ival
	ival		=		i(gkdec2)
			outvalue	"OP1_D", ival
	ival		=		i(gkdec3)
			outvalue	"OP2_D", ival
	ival		=		i(gkdec4)
			outvalue	"OP3_D", ival
	ival		=		i(gkdec5)
			outvalue	"OP4_D", ival
	ival		=		i(gkdec6)
			outvalue	"OP5_D", ival
	ival		=		i(gkdec1)
			outvalue	"OP6_D", ival
	ival		=		i(gksus2)
			outvalue	"OP1_S", ival
	ival		=		i(gksus3)
			outvalue	"OP2_S", ival
	ival		=		i(gksus4)
			outvalue	"OP3_S", ival
	ival		=		i(gksus5)
			outvalue	"OP4_S", ival
	ival		=		i(gksus6)
			outvalue	"OP5_S", ival
	ival		=		i(gksus1)
			outvalue	"OP6_S", ival
	ival		=		i(gkrel2)
			outvalue	"OP1_R", ival
	ival		=		i(gkrel3)
			outvalue	"OP2_R", ival
	ival		=		i(gkrel4)
			outvalue	"OP3_R", ival
	ival		=		i(gkrel5)
			outvalue	"OP4_R", ival
	ival		=		i(gkrel6)
			outvalue	"OP5_R", ival
	ival		=		i(gkrel1)
			outvalue	"OP6_R", ival
endin

instr	10		;FM synth

			midinoteoncps	p4,p5

	icps		init			p4
	iveloc	init			((p5/127)*11000)+4000

			mididefault	i(gkalgo),p6
			mididefault	i(gkfeedback),p7
			mididefault	i(gkatt1), p8
			mididefault	i(gkdec1), p9
			mididefault	i(gksus1), p10
			mididefault	i(gkrel1), p11
			mididefault	i(gkrat1), p12
			mididefault	i(gklvl1), p13

	acps1	init			icps*-p12
	ifn1		init			gisine

			mididefault	i(gkatt2), p14
			mididefault	i(gkdec2), p15
			mididefault	i(gksus2), p16
			mididefault	i(gkrel2), p17
			mididefault	i(gkrat2), p18
			mididefault	i(gklvl2), p19

	acps2	init			icps*-p18
	ifn2		init			gisine

			mididefault	i(gkatt3), p20
			mididefault	i(gkdec3), p21
			mididefault	i(gksus3), p22
			mididefault	i(gkrel3), p23
			mididefault	i(gkrat3), p24
			mididefault	i(gklvl3), p25

	acps3	init			icps*-p24
	ifn3		init			gisine

			mididefault	i(gkatt4), p26
			mididefault	i(gkdec4), p27
			mididefault	i(gksus4), p28
			mididefault	i(gkrel4), p29
			mididefault	i(gkrat4), p30
			mididefault	i(gklvl4), p31

	acps4	init		 	icps*-p30
	ifn4		init			gisine

			mididefault	i(gkatt5), p32
			mididefault	i(gkdec5), p33
			mididefault	i(gksus5), p34
			mididefault	i(gkrel5), p35
			mididefault	i(gkrat5), p36
			mididefault	i(gklvl5), p37

	acps5	init			icps*-p36
	ifn5		init			gisine

			mididefault	i(gkatt6), p38
			mididefault	i(gkdec6), p39
			mididefault	i(gksus6), p40
			mididefault	i(gkrel6), p41
			mididefault	i(gkrat6), p42
			mididefault	i(gklvl6), p43

	acps6	init			icps*-p42
	ifn6		init			gisine

	kamp		init			iveloc

	ialgo	= p6

	;--------------OP6
	;Check if op6 has feedback
	if (ialgo==2)||(ialgo==8)||(ialgo==9)||(ialgo==10)|| (ialgo==12)||(ialgo==15)||(ialgo==15)||(ialgo==18)|| (ialgo==20)||(ialgo==21)||(ialgo==27)||(ialgo==28)|| (ialgo==30) then
		afrq6 = acps6  ;no feedback
	else
		afrq6 = acps6 + (gafeedback*acps6)  ;feedback
	endif

	aphs6 phasor afrq6
	aop6  tablei	aphs6, ifn6, 1
	aenv6 mxadsr	p38,p39,p40,p41
	aop6 = aop6 * aenv6

	;Check if op6 feeds the feedback loop
	if (ialgo==2)||(ialgo==8)||(ialgo==9)||(ialgo==10)|| (ialgo==12)||(ialgo==15)||(ialgo==15)||(ialgo==18)|| (ialgo==20)||(ialgo==21)||(ialgo==27)||(ialgo==28)|| (ialgo==30) goto nofb6
		gafeedback = aop6 * p7
	nofb6:
		;Check if op6 doesn't modulate
		if (ialgo==28)||(ialgo==30)||(ialgo==32) then
			aop6 = aop6 * -p43 * kamp
		else
			aop6 = aop6 * -p43
		endif

	;--------------OP5

	;Check if op5 has feedback
	if (ialgo==28)||(ialgo==30) then
		afrq5 = acps5 + (gafeedback*acps5)  ;feedback
	;Check if not modulated
	elseif (ialgo==10)||(ialgo==11)||(ialgo==12)||(ialgo==13)|| (ialgo==14)||(ialgo==15)||(ialgo==20)||(ialgo==26)|| (ialgo==27)||(ialgo==32) then
		afrq5 = acps5  ;no modulation
	else
		afrq5 = acps5 + (aop6*acps5) ;modulated by op6
	endif

	aphs5 phasor afrq5
	aop5  tablei	aphs5, ifn5, 1
	aenv5 mxadsr	p32, p33, p34, p35
	aop5 = aop5 * aenv5

	;Check if op5 feeds the feedback loop
	if (ialgo==6)||(ialgo==28)||(ialgo==30) then
		gafeedback = aop5 * p7
	endif
	;Check if op5 doesn't modulate
	if (ialgo==5)||(ialgo==6)||(ialgo==19)||(ialgo==21)|| (ialgo==22)||(ialgo==23)||(ialgo==24)||(ialgo==25)|| (ialgo==29)||(ialgo==31)||(ialgo==32) then
		aop5 = aop5 * -p37 * kamp
	else
		aop5 = aop5 * -p37
	endif

	;--------------OP4

	;Check if op4 has feedback
	if (ialgo==8) then
		afrq4 = acps4 + (gafeedback*acps4)  ;feedback
	;Check if modulated
	elseif (ialgo==1)||(ialgo==2)||(ialgo==3)||(ialgo==4)|| (ialgo==18)||(ialgo==20)||(ialgo==26)|| (ialgo==27)||(ialgo==28)||(ialgo==30) then
		afrq4 = acps4 + (aop5*acps4) ;modulated by op5
	elseif (ialgo==10)||(ialgo==11)||(ialgo==14)||(ialgo==15)|| (ialgo==19)||(ialgo==21)||(ialgo==22)||(ialgo==23)|| (ialgo==24)||(ialgo==25) then
		afrq4 = acps4 + (aop6*acps4) ;modulated by op6
	else
		afrq4 = acps4  ;no modulation
	endif

	aphs4	phasor	afrq4
	aop4		tablei	aphs4, ifn4, 1
	aenv4	mxadsr	p26,p27,p28,p29
	aop4		=		aop4 * aenv4

	;Check if op4 feeds the feedback loop
	if (ialgo==4) then
		gafeedback = aop4 * p7
	endif
	;Check if op4 doesn't modulate
	if (ialgo==3)||(ialgo==4)||(ialgo==10)||(ialgo==11)|| (ialgo==19)||(ialgo==20)||(ialgo==21)||(ialgo==22)|| (ialgo==23)||(ialgo==24)||(ialgo==25)||(ialgo==26)|| (ialgo==27)||(ialgo==31)||(ialgo==32) then
		aop4 = aop4 * -p31 * kamp
	else
		aop4 = aop4 * -p31
	endif

	;--------------OP3

	;Check if op3 has feedback
	if (ialgo==10)||(ialgo==18)||(ialgo==20)||(ialgo==21)|| (ialgo==27) then
		afrq3 = acps3 + (gafeedback*acps3)  ;feedback
	;Check if modulated
	elseif (ialgo==1)||(ialgo==2)||(ialgo==5)||(ialgo==6)|| (ialgo==9)||(ialgo==12) then
		afrq3 = acps3 + (aop4*acps3) ;modulated by op4
	elseif (ialgo==7)||(ialgo==8)||(ialgo==9) then
		afrq3 = acps3 + (aop4*acps3) + (aop5*acps3) ;modulated by op4+op5
	elseif (ialgo==12)||(ialgo==13) then
		afrq3 = acps3 + (aop4*acps3) + (aop5*acps3) + (aop6*acps3)
	;modulated by op4+op5+op6
	elseif (ialgo==14)||(ialgo==15)||(ialgo==16)||(ialgo==17)|| (ialgo==28)||(ialgo==29)||(ialgo==30) then
		afrq3 = acps3 + (aop4*acps3) ;modulated by op4
	elseif (ialgo==22)||(ialgo==24) then
		afrq3 = acps3 + (aop6*acps3) ;modulated by op6
	else
		afrq3 = acps3  ;no modulation
	endif

	aphs3	phasor	afrq3
	aop3		tablei	aphs3, ifn3, 1
	aenv3	mxadsr	p20,p21, p22, p23
	aop3		=		aop3 * aenv3

	;Check if op4 feeds the feedback loop
	if (ialgo==10)||(ialgo==18)||(ialgo==20)||(ialgo==21)|| (ialgo==27) then
		gafeedback = aop3 * p7
	endif
	;Check if op3 doesn't modulate
	if (ialgo==1)||(ialgo==2)||(ialgo==5)||(ialgo==6)|| (ialgo==7)||(ialgo==8)||(ialgo==9)||(ialgo==12)|| (ialgo==13)||(ialgo==14)||(ialgo==15)||(ialgo==22)|| (ialgo==24)||(ialgo==25)||(ialgo==28)||(ialgo==29)|| (ialgo==30)||(ialgo==31)||(ialgo==32) then
		aop3 = aop3 * -p25 * kamp
	else
		aop3 = aop3 * -p25
	endif

	;--------------OP2

	;Check if op2 has feedback
	if (ialgo==2)||(ialgo==9)||(ialgo==12)||(ialgo==15)|| (ialgo==17) then
		afrq2 = acps2 + (gafeedback*acps2)  ;feedback
	;Check if modulated
	elseif (ialgo==3)||(ialgo==4)||(ialgo==10)||(ialgo==11)|| (ialgo==19)||(ialgo==20)||(ialgo==21)||(ialgo==23)|| (ialgo==26)||(ialgo==27) then
		afrq2 = acps2 + (aop3*acps2) ;modulated by op3
	else
		afrq2 = acps2  ;no modulation
	endif

	aphs2 phasor afrq2
	aop2  tablei	aphs2, ifn2, 1
	aenv2 mxadsr	p14, p15, p16, p17
	aop2 = aop2 * aenv2

	;Check if op4 feeds the feedback loop
	if (ialgo==2)||(ialgo==9)||(ialgo==12)||(ialgo==15)|| (ialgo==17) then
		gafeedback = aop2 * p7
	endif
	;Check if op2 doesn't modulate
	if (ialgo==20)||(ialgo==21)||(ialgo==23)||(ialgo==24)|| (ialgo==25)||(ialgo==26)||(ialgo==27)||(ialgo==29)|| (ialgo==30)||(ialgo==31)||(ialgo==32) then
		aop2 = aop2 * -p19 * kamp
	else
		aop2 = aop2 * -p19
	endif

	;--------------OP1

	;op1 never has feedback
	;Check if NOT modulated
	if (ialgo==23)||(ialgo==24)||(ialgo==25)||(ialgo==26)|| (ialgo==27)||(ialgo==29)||(ialgo==30)||(ialgo==31)|| (ialgo==32) then
		afrq1 = acps1 ;no modulation
	elseif (ialgo==16)||(ialgo==17) then
		afrq1 = acps1 + (aop2*acps1) + (aop3*acps1) + (aop5*acps1)
	;modulated by op2, op3 and op5
	elseif (ialgo==18) then
		afrq1 = acps1 + (aop2*acps1) + (aop3*acps1) + (aop4*acps1)
	;modulated by op2, op3 and op4
	elseif (ialgo==20)||(ialgo==21) then
		afrq1 = acps1 + (aop3*acps1) ;modulated by op3
	else
		afrq1 = acps1 + (aop2*acps1)  ;modulated by op2
	endif

	aphs1	phasor	afrq1
	aop1		tablei	aphs1, ifn1, 1
	aenv1	mxadsr	p8, p9, p10, p11
	aop1		=		aop1 * aenv1

	;op1 never modulates
	aop1		=		aop1 * -p13 * kamp

	;------------MIX OPS
	if (ialgo==1 ) then
		aout = aop1 + aop3
	elseif (ialgo==2 ) then
		aout = aop1 + aop3
	elseif (ialgo==3 ) then
		aout = aop1 + aop4
	elseif (ialgo==4 ) then
		aout = aop1 + aop4
	elseif (ialgo==5 ) then
		aout = aop1 + aop3 + aop5
	elseif (ialgo==6 ) then
		aout = aop1 + aop3 + aop5
	elseif (ialgo==7 ) then
		aout = aop1 + aop3
	elseif (ialgo==8 ) then
		aout = aop1 + aop3
	elseif (ialgo==9 ) then
		aout = aop1 + aop3
	elseif (ialgo==10 ) then
		aout = aop1 + aop4
	elseif (ialgo==11 ) then
		aout = aop1 + aop4
	elseif (ialgo==12 ) then
		aout = aop1 + aop3
	elseif (ialgo==13 ) then
		aout = aop1 + aop3
	elseif (ialgo==14 ) then
		aout = aop1 + aop3
	elseif (ialgo==15 ) then
		aout = aop1 + aop3
	elseif (ialgo==16 ) then
		aout = aop1
	elseif (ialgo==17 ) then
		aout = aop1
	elseif (ialgo==18 ) then
		aout = aop1
	elseif (ialgo==19 ) then
		aout = aop1 + aop4 + aop5
	elseif (ialgo==20 ) then
		aout = aop1 + aop2 + aop4
	elseif (ialgo==21 ) then
		aout = aop1 + aop2 + aop4 + aop5
	elseif (ialgo==22 ) then
		aout = aop1 + aop3 + aop4 + aop5
	elseif (ialgo==23 ) then
		aout = aop1 + aop2 + aop4 + aop5
	elseif (ialgo==24 ) then
		aout = aop1 + aop2 + aop3 + aop4 + aop5
	elseif (ialgo==25 ) then
		aout = aop1 + aop2 + aop3 + aop4 + aop5
	elseif (ialgo==26 ) then
		aout = aop1 + aop2 + aop4
	elseif (ialgo==27 ) then
		aout = aop1 + aop2 + aop4
	elseif (ialgo==28 ) then
		aout = aop1 + aop3 + aop6
	elseif (ialgo==29 ) then
		aout = aop1 + aop2 + aop3 + aop5
	elseif (ialgo==30 ) then
		aout = aop1 + aop2 + aop3 + aop6
	elseif (ialgo==31 ) then
		aout = aop1 + aop2 + aop3 + aop4 + aop5
	elseif (ialgo==32 ) then
		aout = aop1 + aop2 + aop3 + aop4 + aop5 + aop6
	endif
	outs  aout, aout
endin

instr	12	;Keyboard input
	kres, kkeydown		sensekey
	
	;printk2 kres
	
	if (kres==113) then					;q
		event	"i", 3, 0, 0			;Randomize Mus
	elseif (kres==119) then				;w
		event	"i", 2, 0, 0			;Randomize FX
	elseif (kres==101) then				;e
		event	"i", 6, 0, 0			;Attackify
	elseif (kres==114) then				;r
		event	"i", 7, 0, 0			;Padify
	elseif (kres==116) then				;t
		event	"i", 4, 0, 0			;+ harm
	elseif (kres==121) then				;y
		event	"i", 5, 0, 0			;- harm
	elseif (kres==117) then				;u
		event	"i", 8, 0, 0			;switch +
	elseif (kres==105) then				;i
		event	"i", 9, 0, 0			;switch -
	elseif (kres==111) then				;o 
		kalgo	= gkalgo -1			;algorithm -1
		event	"i", 13, 0, 0, kalgo	
	elseif (kres==112) then				;p
		kalgo	= gkalgo +1			;algorithm +1
		event	"i", 13, 0, 0, kalgo
	endif
endin

instr	13	;Keyboard Algo change
	kalgo	wrap		p4, 1, 32
			outvalue	"Algorithm", kalgo
endin

instr	17	;Print i line
	ialgo	= i(gkalgo)
	ifeedback	= i(gkfeedback)
	iatt1	= i(gkatt1)
	idec1	= i(gkdec1)
	isus1	= i(gksus1)
	irel1	= i(gkrel1)
	ilvl1	= i(gklvl1)
	irat1	= i(gkrat1)
	iinv1	= i(gkinv1)

	iatt2	= i(gkatt2)
	idec2	= i(gkdec2)
	isus2	= i(gksus2)
	irel2	= i(gkrel2)
	ilvl2	= i(gklvl2)
	irat2	= i(gkrat2)
	iinv2	= i(gkinv2)

	iatt3	= i(gkatt3)
	idec3	= i(gkdec3)
	isus3	= i(gksus3)
	irel3	= i(gkrel3)
	ilvl3	= i(gklvl3)
	irat3	= i(gkrat3)
	iinv3	= i(gkinv3)

	iatt4	= i(gkatt4)
	idec4	= i(gkdec4)
	isus4	= i(gksus4)
	irel4	= i(gkrel4)
	ilvl4	= i(gklvl4)
	irat4	= i(gkrat4)
	iinv4	= i(gkinv4)

	iatt5	= i(gkatt5)
	idec5	= i(gkdec5)
	isus5	= i(gksus5)
	irel5	= i(gkrel5)
	ilvl5	= i(gklvl5)
	irat5	= i(gkrat5)
	iinv5	= i(gkinv5)

	iatt6	= i(gkatt6)
	idec6	= i(gkdec6)
	isus6	= i(gksus6)
	irel6	= i(gkrel6)
	ilvl6	= i(gklvl6)
	irat6	= i(gkrat6)
	iinv6	= i(gkinv6)

	kdur invalue "mididur"
	idur	= i(kdur)
	knote invalue "midinote"
	inote = i(knote)
	ifreq	= 440.0 * 2 ^ ((inote - 69)/12 )
	kveloc invalue "midiveloc"
	iveloc	= i(kveloc)
	
	prints "i 10  0  %f  %f %i %i %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %i %i %i %i %i %i \n",\
		idur, ifreq, iveloc, ialgo, ifeedback, \
		iatt1, idec1, isus1, irel1, irat1 ,ilvl1, \
		iatt2, idec2, isus2, irel2, irat2, ilvl2, \
		iatt3, idec3, isus3, irel3, irat3, ilvl3, \
		iatt4, idec4, isus4, irel4, irat4, ilvl4, \
		iatt5, idec5, isus5, irel5, irat5, ilvl5, \
		iatt6, idec6, isus6, irel6, irat6, ilvl6, \
		iinv1, iinv2, iinv3, iinv4, iinv5, iinv6
endin

instr	18	;Play note
	ialgo	= i(gkalgo)
	ifeedback	= i(gkfeedback)
	iatt1	= i(gkatt1)
	idec1	= i(gkdec1)
	isus1	= i(gksus1)
	irel1	= i(gkrel1)
	ilvl1	= i(gklvl1)
	irat1	= i(gkrat1)
	iinv1	= i(gkinv1)

	iatt2	= i(gkatt2)
	idec2	= i(gkdec2)
	isus2	= i(gksus2)
	irel2	= i(gkrel2)
	ilvl2	= i(gklvl2)
	irat2	= i(gkrat2)
	iinv2	= i(gkinv2)

	iatt3	= i(gkatt3)
	idec3	= i(gkdec3)
	isus3	= i(gksus3)
	irel3	= i(gkrel3)
	ilvl3	= i(gklvl3)
	irat3	= i(gkrat3)
	iinv3	= i(gkinv3)

	iatt4	= i(gkatt4)
	idec4	= i(gkdec4)
	isus4	= i(gksus4)
	irel4	= i(gkrel4)
	ilvl4	= i(gklvl4)
	irat4	= i(gkrat4)
	iinv4	= i(gkinv4)

	iatt5	= i(gkatt5)
	idec5	= i(gkdec5)
	isus5	= i(gksus5)
	irel5	= i(gkrel5)
	ilvl5	= i(gklvl5)
	irat5	= i(gkrat5)
	iinv5	= i(gkinv5)

	iatt6	= i(gkatt6)
	idec6	= i(gkdec6)
	isus6	= i(gksus6)
	irel6	= i(gkrel6)
	ilvl6	= i(gklvl6)
	irat6	= i(gkrat6)
	iinv6	= i(gkinv6)

	kdur invalue "mididur"
	idur	= i(kdur)
	knote invalue "midinote"
	inote = i(knote)
	ifreq	= 440.0 * 2 ^ ((inote - 69)/12 )
	kveloc invalue "midiveloc"
	iveloc	= i(kveloc)
	
	Sevent1 sprintf "i 10  0  %f  %f %i %i %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ", \
		idur, ifreq, iveloc, ialgo, ifeedback, \
		iatt1, idec1, isus1, irel1, irat1 ,ilvl1, \
		iatt2, idec2, isus2, irel2, irat2, ilvl2, \
		iatt3, idec3, isus3, irel3, irat3, ilvl3, \
		iatt4, idec4, isus4, irel4, irat4, ilvl4 
		
	Sevent2 sprintf "%f %f %f %f %f %f %f %f %f %f %f %f %i %i %i %i %i %i \n",  \ 
		iatt5, idec5, isus5, irel5, irat5, ilvl5, \
		iatt6, idec6, isus6, irel6, irat6, ilvl6, \
		iinv1, iinv2, iinv3, iinv4, iinv5, iinv6
	Sevent strcat Sevent1, Sevent2
	scoreline_i Sevent
endin
</CsInstruments>
<CsScore>
i 1 0 3600		;GUI controls
i 12 0 3600		;Keyboard input
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>305</x>
 <y>201</y>
 <width>859</width>
 <height>462</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>248</r>
  <g>242</g>
  <b>210</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>44</x>
  <y>2</y>
  <width>91</width>
  <height>132</height>
  <uuid>{ddefd7af-22f4-40ce-a66f-83c075867c7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>41</y>
  <width>44</width>
  <height>27</height>
  <uuid>{4ab7fff4-fdc7-44d8-a795-9d0fb247211c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP 1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP1_A</objectName>
  <x>49</x>
  <y>8</y>
  <width>20</width>
  <height>100</height>
  <uuid>{9e13da35-ce6a-4581-abec-2c5395a24f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>1.00000000</maximum>
  <value>0.26794010</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>49</x>
  <y>107</y>
  <width>21</width>
  <height>26</height>
  <uuid>{f640f134-49d6-4294-b510-f0b4ee893f92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>71</x>
  <y>108</y>
  <width>21</width>
  <height>26</height>
  <uuid>{ab147300-6f87-48ca-a1fa-1ae56bae29ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP1_D</objectName>
  <x>71</x>
  <y>9</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a92533d8-c015-4de0-a136-76bc296de24d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00784610</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>93</x>
  <y>108</y>
  <width>21</width>
  <height>26</height>
  <uuid>{e8154a5e-f96b-4a16-a41c-b45763b58b76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP1_S</objectName>
  <x>93</x>
  <y>9</y>
  <width>20</width>
  <height>100</height>
  <uuid>{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00781716</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>114</x>
  <y>108</y>
  <width>21</width>
  <height>26</height>
  <uuid>{f4a75829-da47-4da2-8cd4-6b52fba5e175}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP1_R</objectName>
  <x>114</x>
  <y>9</y>
  <width>20</width>
  <height>100</height>
  <uuid>{e5c6b99d-3423-4958-864e-bbffe3d7fafe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>1.41834235</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>44</x>
  <y>137</y>
  <width>91</width>
  <height>132</height>
  <uuid>{c12f4db8-8eb1-4fcd-81b6-c579b404b42a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>174</y>
  <width>44</width>
  <height>27</height>
  <uuid>{1ec74f70-9037-4f13-be48-5d4ac24f16e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP 2</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP2_A</objectName>
  <x>49</x>
  <y>141</y>
  <width>20</width>
  <height>100</height>
  <uuid>{871077d5-13ce-4ad8-a12a-ebc4180b0c86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>1.00000000</maximum>
  <value>0.15406355</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>49</x>
  <y>240</y>
  <width>21</width>
  <height>26</height>
  <uuid>{14b69b38-828e-4612-8d64-e7181ff09a46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>71</x>
  <y>241</y>
  <width>21</width>
  <height>26</height>
  <uuid>{ae1c88aa-5651-4ff9-a116-f10101b5e7bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP2_D</objectName>
  <x>71</x>
  <y>142</y>
  <width>20</width>
  <height>100</height>
  <uuid>{05ec1dfd-fdaf-4381-8048-ae47a50cf679}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00825546</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>93</x>
  <y>241</y>
  <width>21</width>
  <height>26</height>
  <uuid>{9aa62bc0-ec02-47c0-8918-8cbdb6a6d8e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP2_S</objectName>
  <x>93</x>
  <y>142</y>
  <width>20</width>
  <height>100</height>
  <uuid>{36e27d45-a162-4fd9-9d98-2e439b3f91ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00134029</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>114</x>
  <y>241</y>
  <width>21</width>
  <height>26</height>
  <uuid>{f14ff09e-86a8-4abe-9fd6-00447f7c50d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP2_R</objectName>
  <x>114</x>
  <y>142</y>
  <width>20</width>
  <height>100</height>
  <uuid>{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.68942636</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>303</x>
  <y>6</y>
  <width>91</width>
  <height>132</height>
  <uuid>{e9cf9368-f199-422a-a096-ba1e1bcd7f3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>44</x>
  <y>271</y>
  <width>91</width>
  <height>132</height>
  <uuid>{693d4506-9a51-4058-985c-b8581f402b81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>310</y>
  <width>44</width>
  <height>27</height>
  <uuid>{c314c6ce-baa9-4b6e-861d-76cbc8164424}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP 3</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP3_A</objectName>
  <x>49</x>
  <y>277</y>
  <width>20</width>
  <height>100</height>
  <uuid>{33f07b85-57c7-4dac-aecd-8a88397672a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>1.00000000</maximum>
  <value>0.11952523</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>49</x>
  <y>376</y>
  <width>21</width>
  <height>26</height>
  <uuid>{a7943c1f-4aa4-4d82-ad39-3f46ecf4f619}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>71</x>
  <y>377</y>
  <width>21</width>
  <height>26</height>
  <uuid>{9212c445-ec73-439d-bc54-98c5e1236338}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP3_D</objectName>
  <x>71</x>
  <y>278</y>
  <width>20</width>
  <height>100</height>
  <uuid>{d37dc860-9122-4463-941a-baf3d9964fb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00428255</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>93</x>
  <y>377</y>
  <width>21</width>
  <height>26</height>
  <uuid>{37c5f99a-8b65-407e-ad71-a7e956dc3bdc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP3_S</objectName>
  <x>93</x>
  <y>278</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f72b09db-2caa-4461-825b-62ec9795be78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00911442</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>114</x>
  <y>377</y>
  <width>21</width>
  <height>26</height>
  <uuid>{359bb3cb-c925-48b4-8abd-2b6da04a65ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP3_R</objectName>
  <x>114</x>
  <y>278</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0325a2d5-bbc5-4209-809b-f3882f92c49a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.21356234</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>259</x>
  <y>44</y>
  <width>44</width>
  <height>27</height>
  <uuid>{5bf58f22-4e3b-40e7-9bdf-c808c70568ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP 4</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP4_A</objectName>
  <x>308</x>
  <y>11</y>
  <width>20</width>
  <height>100</height>
  <uuid>{27f72d99-dcf9-41eb-957f-b961a831e299}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00030442</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>308</x>
  <y>110</y>
  <width>21</width>
  <height>25</height>
  <uuid>{3b5533e4-b730-4d8c-a76e-d234d3b0ccf7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>330</x>
  <y>111</y>
  <width>21</width>
  <height>25</height>
  <uuid>{d629506d-32d0-4866-8aa1-3fcf0a1198b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP4_D</objectName>
  <x>330</x>
  <y>12</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00177382</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>352</x>
  <y>111</y>
  <width>21</width>
  <height>25</height>
  <uuid>{3e25a99a-5fd1-4a17-a7a8-01ea5dcd76e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP4_S</objectName>
  <x>352</x>
  <y>12</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a77c4ed0-b2d4-460a-9364-8960bc569e44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.36083108</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>373</x>
  <y>111</y>
  <width>21</width>
  <height>25</height>
  <uuid>{5065db68-fa84-4b6d-b436-9b0aa90fef62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP4_R</objectName>
  <x>373</x>
  <y>12</y>
  <width>20</width>
  <height>100</height>
  <uuid>{95170189-8693-4ad0-8208-2e11a78f0c92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.11849165</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>303</x>
  <y>141</y>
  <width>91</width>
  <height>132</height>
  <uuid>{a44a27e9-15d5-4d50-ab7f-8d2490eef4da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>303</x>
  <y>275</y>
  <width>91</width>
  <height>132</height>
  <uuid>{6adf61be-3364-4131-8f55-f072b796fc7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>259</x>
  <y>180</y>
  <width>44</width>
  <height>27</height>
  <uuid>{085b71a0-b11a-4225-9654-35fbb949e00b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP 5</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP5_A</objectName>
  <x>308</x>
  <y>147</y>
  <width>20</width>
  <height>100</height>
  <uuid>{00476cf1-49a1-443c-b2d0-e5a58fffb07b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00048555</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>308</x>
  <y>246</y>
  <width>21</width>
  <height>25</height>
  <uuid>{622367d2-a460-4762-931c-92a7f2a49ee8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>330</x>
  <y>247</y>
  <width>21</width>
  <height>25</height>
  <uuid>{49a67124-8182-47c5-ab92-c1805b3b781b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP5_D</objectName>
  <x>330</x>
  <y>148</y>
  <width>20</width>
  <height>100</height>
  <uuid>{de3ea287-8def-4d60-ab7f-227e03a58b89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00556565</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>352</x>
  <y>247</y>
  <width>21</width>
  <height>25</height>
  <uuid>{53710c5e-8350-4c6e-8336-1a38e2e4c553}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP5_S</objectName>
  <x>352</x>
  <y>148</y>
  <width>20</width>
  <height>100</height>
  <uuid>{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.03035997</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>373</x>
  <y>247</y>
  <width>21</width>
  <height>25</height>
  <uuid>{ea4be0a7-eb52-4298-815e-56c0eda60ddd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP5_R</objectName>
  <x>373</x>
  <y>148</y>
  <width>20</width>
  <height>100</height>
  <uuid>{aef1719c-c106-4de5-8877-a83bcb0e303a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>2.75318646</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>259</x>
  <y>313</y>
  <width>44</width>
  <height>27</height>
  <uuid>{9a9b8c07-51d2-4ad6-acab-fc4d4414d32f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP 6</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP6_A</objectName>
  <x>308</x>
  <y>280</y>
  <width>20</width>
  <height>100</height>
  <uuid>{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34034353</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>308</x>
  <y>379</y>
  <width>21</width>
  <height>25</height>
  <uuid>{30e4b087-6716-45a8-8fba-8355aed7a984}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>330</x>
  <y>380</y>
  <width>21</width>
  <height>25</height>
  <uuid>{deb8e31d-4ca0-47b2-af38-ecd75175fa61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP6_D</objectName>
  <x>330</x>
  <y>281</y>
  <width>20</width>
  <height>100</height>
  <uuid>{39bbe82d-bf66-4390-af28-728bf48bf553}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00144197</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>352</x>
  <y>380</y>
  <width>21</width>
  <height>25</height>
  <uuid>{6161e0da-63d2-4955-81de-c9b45001bf87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP6_S</objectName>
  <x>352</x>
  <y>281</y>
  <width>20</width>
  <height>100</height>
  <uuid>{8175dd03-fb0b-4510-95a1-5e64decf4956}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00835408</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>373</x>
  <y>380</y>
  <width>21</width>
  <height>25</height>
  <uuid>{5159ef4a-2efc-4ed3-9ed2-c2f6d7eab744}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP6_R</objectName>
  <x>373</x>
  <y>281</y>
  <width>20</width>
  <height>100</height>
  <uuid>{14a72510-ba4d-4aaa-8abe-af9434462a84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>2.70617104</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>2</y>
  <width>110</width>
  <height>132</height>
  <uuid>{ab79e93c-b7b3-49d3-99a9-9557d60ff47e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>138</x>
  <y>108</y>
  <width>30</width>
  <height>25</height>
  <uuid>{ccb66377-6a5d-4fe4-b4a1-cf14951aec10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lev</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP1_Lev</objectName>
  <x>143</x>
  <y>9</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69100642</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>OP1_Ratio</objectName>
  <x>170</x>
  <y>26</y>
  <width>62</width>
  <height>25</height>
  <uuid>{07822872-42f0-4f92-8750-01a4be5f8a8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>180</x>
  <y>48</y>
  <width>52</width>
  <height>28</height>
  <uuid>{a0de1639-3c30-416d-89b7-7b96e822642a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OP1_Inv</objectName>
  <x>184</x>
  <y>79</y>
  <width>46</width>
  <height>20</height>
  <uuid>{eca47157-c2db-455e-9f7b-8aad20172dab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Inv</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>137</y>
  <width>110</width>
  <height>132</height>
  <uuid>{e1cde249-7bb8-44ce-9fb2-395be9a224e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OP2_Inv</objectName>
  <x>184</x>
  <y>213</y>
  <width>46</width>
  <height>20</height>
  <uuid>{4057129d-e5b6-4d43-a7b3-cc89da41cf95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Inv</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>180</x>
  <y>182</y>
  <width>52</width>
  <height>28</height>
  <uuid>{c270ed88-7208-44a7-aa63-808b356052fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>OP2_Ratio</objectName>
  <x>170</x>
  <y>160</y>
  <width>62</width>
  <height>25</height>
  <uuid>{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>2.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP2_Lev</objectName>
  <x>143</x>
  <y>143</y>
  <width>20</width>
  <height>100</height>
  <uuid>{52cdd897-93c5-4ce6-8363-2f1b80beffab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.35206032</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>138</x>
  <y>241</y>
  <width>30</width>
  <height>25</height>
  <uuid>{ea9733e5-ac29-4c5c-a47c-9b048a04a3d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lev</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>271</y>
  <width>110</width>
  <height>132</height>
  <uuid>{af72e9b9-4b6e-44f2-8413-bffb1cb613fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>396</x>
  <y>6</y>
  <width>110</width>
  <height>132</height>
  <uuid>{f1d52ecc-c75d-4487-a694-811e6b319e94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>396</x>
  <y>141</y>
  <width>110</width>
  <height>132</height>
  <uuid>{b20aee5e-5a24-4ea4-b83b-2ccea0bce9db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>396</x>
  <y>275</y>
  <width>110</width>
  <height>132</height>
  <uuid>{d4538d22-9d29-4ab0-babe-6e3880343362}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>138</x>
  <y>377</y>
  <width>30</width>
  <height>25</height>
  <uuid>{d0cad3ed-cbd0-42eb-b558-ac39a311d778}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lev</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP3_Lev</objectName>
  <x>143</x>
  <y>279</y>
  <width>20</width>
  <height>100</height>
  <uuid>{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.48741713</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>OP3_Ratio</objectName>
  <x>170</x>
  <y>296</y>
  <width>62</width>
  <height>25</height>
  <uuid>{6fd61b15-bc21-41f0-888d-526675b6ec12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>180</x>
  <y>318</y>
  <width>52</width>
  <height>28</height>
  <uuid>{75b940ac-1a6b-42bd-bd7d-350b91f07b43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OP3_Inv</objectName>
  <x>184</x>
  <y>349</y>
  <width>46</width>
  <height>20</height>
  <uuid>{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Inv</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>397</x>
  <y>111</y>
  <width>30</width>
  <height>25</height>
  <uuid>{2153f47f-3c8e-49a3-839d-7530547ad92c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lev</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP4_Lev</objectName>
  <x>402</x>
  <y>12</y>
  <width>20</width>
  <height>100</height>
  <uuid>{546eff0f-e7a8-40f3-9450-9fffe360958f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60054684</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>OP4_Ratio</objectName>
  <x>429</x>
  <y>32</y>
  <width>62</width>
  <height>25</height>
  <uuid>{62157ee3-b7e1-404a-925d-973bfa2e48d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>5.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>439</x>
  <y>54</y>
  <width>52</width>
  <height>28</height>
  <uuid>{f8f4438c-2393-4e88-a0d2-0668418f10a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OP4_Inv</objectName>
  <x>443</x>
  <y>85</y>
  <width>46</width>
  <height>20</height>
  <uuid>{93af235b-99d6-4ecb-9ec7-7d1421350c86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Inv</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>398</x>
  <y>247</y>
  <width>30</width>
  <height>25</height>
  <uuid>{3a7b8370-8a35-4dbd-ac77-95671033afef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lev</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP5_Lev</objectName>
  <x>403</x>
  <y>148</y>
  <width>20</width>
  <height>100</height>
  <uuid>{37c7aa17-e643-4e75-bf58-6969b2ed6c31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.82928985</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>OP5_Ratio</objectName>
  <x>429</x>
  <y>165</y>
  <width>62</width>
  <height>25</height>
  <uuid>{1b153ca8-1cc5-4578-850d-6ba111c78a82}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>3.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>440</x>
  <y>187</y>
  <width>52</width>
  <height>28</height>
  <uuid>{5afb0f34-ac97-41ee-a1a0-4d5b556a218f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OP5_Inv</objectName>
  <x>444</x>
  <y>218</y>
  <width>46</width>
  <height>20</height>
  <uuid>{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Inv</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>398</x>
  <y>380</y>
  <width>30</width>
  <height>25</height>
  <uuid>{dbbb48a6-cb9b-41b5-ba70-42bb632a52a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Lev</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>OP6_Lev</objectName>
  <x>403</x>
  <y>281</y>
  <width>20</width>
  <height>100</height>
  <uuid>{9f825ec8-2820-4a22-b358-03e0db0f6f49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.81146699</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>OP6_Ratio</objectName>
  <x>430</x>
  <y>298</y>
  <width>62</width>
  <height>25</height>
  <uuid>{04bcd67b-1f71-4738-a580-5d34453e3158}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>440</x>
  <y>320</y>
  <width>52</width>
  <height>28</height>
  <uuid>{49db844e-1ce5-4ffc-b207-de4b4c79db06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>OP6_Inv</objectName>
  <x>443</x>
  <y>350</y>
  <width>46</width>
  <height>20</height>
  <uuid>{79864394-9898-4781-bbfb-184658696f75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Inv</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>567</x>
  <y>150</y>
  <width>124</width>
  <height>256</height>
  <uuid>{84e29a83-2929-41ab-b8ea-22cd0e58fe3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transform</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>180</y>
  <width>100</width>
  <height>20</height>
  <uuid>{487c8bfd-d023-43ea-b959-dac28c1e341d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Rand Mus</text>
  <image>/</image>
  <eventLine>i3 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>208</y>
  <width>100</width>
  <height>20</height>
  <uuid>{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Rand FX</text>
  <image>/</image>
  <eventLine>i2 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>236</y>
  <width>100</width>
  <height>20</height>
  <uuid>{a21166bb-8c6d-48a7-8005-837613fc83b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Attackify</text>
  <image>/</image>
  <eventLine>i6 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>264</y>
  <width>100</width>
  <height>20</height>
  <uuid>{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Padify</text>
  <image>/</image>
  <eventLine>i7 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>292</y>
  <width>100</width>
  <height>20</height>
  <uuid>{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>+ Harm</text>
  <image>/</image>
  <eventLine>i4 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>321</y>
  <width>100</width>
  <height>20</height>
  <uuid>{a509c2de-6235-4dd2-9449-757808be3cef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>- Harm</text>
  <image>/</image>
  <eventLine>i5 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>350</y>
  <width>100</width>
  <height>20</height>
  <uuid>{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Switch +</text>
  <image>/</image>
  <eventLine>i8 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>579</x>
  <y>379</y>
  <width>100</width>
  <height>20</height>
  <uuid>{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Switch -</text>
  <image>/</image>
  <eventLine>i9 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>567</x>
  <y>5</y>
  <width>124</width>
  <height>143</height>
  <uuid>{0e2489b0-38b6-49c2-ad4a-62bf29752149}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>697</x>
  <y>5</y>
  <width>124</width>
  <height>132</height>
  <uuid>{e9e01339-1445-4ee9-a24c-11caa98c0f74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Algorithm</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>570</x>
  <y>9</y>
  <width>118</width>
  <height>43</height>
  <uuid>{db54a1ce-2e3f-4ef4-a765-6721f66610e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Diffamator
</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>697</x>
  <y>219</y>
  <width>126</width>
  <height>185</height>
  <uuid>{cc0440f6-06ca-42e1-8c45-53a27c91a649}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Notes</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>697</x>
  <y>140</y>
  <width>125</width>
  <height>76</height>
  <uuid>{bfaa2588-192b-4a5e-a47a-a70150baf979}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Presets</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial Black</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>219</r>
   <g>203</g>
   <b>161</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Feedback</objectName>
  <x>701</x>
  <y>43</y>
  <width>115</width>
  <height>21</height>
  <uuid>{58a81e21-97d6-4731-8910-53f1f0537605}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.04375662</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Algorithm</objectName>
  <x>706</x>
  <y>77</y>
  <width>48</width>
  <height>28</height>
  <uuid>{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>30</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>752</x>
  <y>81</y>
  <width>67</width>
  <height>26</height>
  <uuid>{0d6b632a-a3b0-4bb7-a494-f884804d1a97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Algo Nb</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>753</x>
  <y>59</y>
  <width>69</width>
  <height>25</height>
  <uuid>{c6f8304a-e803-4196-9b00-b1356a228da1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Feedback</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>_SetPresetIndex</objectName>
  <x>700</x>
  <y>178</y>
  <width>119</width>
  <height>30</height>
  <uuid>{f2e13afc-4068-4d76-90c2-2765a4b0bede}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>P00 - Algo 13</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P01 - Algo 07</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P02 - Algo 26</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P03 - Algo 14</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P04 - Algo 15</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P05 - Algo 15</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P06 - Algo 08</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P07 - Algo 24</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P08 - Algo 07</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P09 - Algo 23</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P10 - Algo 21</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P11 - Algo 24</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P12 - Algo 17</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P13 - Algo 19</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P14 - Algo 24</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P15 - Algo 26</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P16 - Algo 12</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P17 - Algo 30</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P18 - Algo 11</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P19 - Algo 07</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P20 - Algo 14</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P21 - Algo 16</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P22 - Algo 05</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P23 - Algo 21</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P24 - Algo 10</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P25 - Algo 10</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P26 - Algo 25</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P27 - Algo 09</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P28 - Algo 26</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P29 - Algo 11</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P30 - Free</name>
    <value>30</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>P31 - Free
</name>
    <value>31</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>28</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Lock</objectName>
  <x>708</x>
  <y>113</y>
  <width>65</width>
  <height>21</height>
  <uuid>{7b81436f-ee9d-441a-b954-c9debb293494}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Lock</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>711</x>
  <y>366</y>
  <width>100</width>
  <height>20</height>
  <uuid>{478b85b5-5666-4fc9-85df-6fe39e82bdb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Print i line</text>
  <image>/</image>
  <eventLine>i17 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>midinote</objectName>
  <x>776</x>
  <y>260</y>
  <width>30</width>
  <height>20</height>
  <uuid>{6178a00b-9991-4d50-bdcf-0d551d62c7d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>60.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>5.00000000</minimum>
  <maximum>100.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>2</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>midiveloc</objectName>
  <x>776</x>
  <y>281</y>
  <width>30</width>
  <height>20</height>
  <uuid>{30f711f8-7c4c-4b23-bfae-839797614164}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>83.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>5.00000000</minimum>
  <maximum>100.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>2</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>699</x>
  <y>258</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7ab39d44-4919-44d3-93c7-2138c56bc609}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MIDI note</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>699</x>
  <y>280</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d48aa18b-4a28-4c83-a362-403736b357ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MIDI velocity</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>711</x>
  <y>340</y>
  <width>100</width>
  <height>20</height>
  <uuid>{1037b6f2-2b24-42d6-803e-12bef76e2701}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play note</text>
  <image>/</image>
  <eventLine>i18 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>mididur</objectName>
  <x>776</x>
  <y>302</y>
  <width>30</width>
  <height>20</height>
  <uuid>{3d8cd06f-a792-4cb8-ae3c-3630b115d9ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>1.18000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>9.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>2</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>698</x>
  <y>303</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b07a50ec-6dcf-4da2-bc5e-a9299c7d506d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Duration</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>573</x>
  <y>56</y>
  <width>111</width>
  <height>82</height>
  <uuid>{03c821aa-f92a-4202-8232-368655a79ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>An FM synthesizer emulating the DX7's operator algorithm chains</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="P0 - Algo 13" number="0" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.25450301</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.43530500</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.19585600</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.83604801</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.01150100</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.43558201</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.80738503</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.21833897</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.47250399</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.28248700</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.87443900</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.31644499</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.91523600</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.36860800</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.39242801</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.23324203</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.29464000</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.34461001</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.65878999</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.76137102</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.72918397</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.49390501</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.71536899</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.35582301</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.24415500</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.25816101</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.79564601</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.62656200</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.50804299</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.87787497</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.21652600</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >13.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P1 - Algo 07" number="1" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.32471600</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.06244500</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.75034899</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.60848594</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.34538600</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.49344099</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.36916199</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.00228798</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.01258200</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.18536700</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.38395399</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.67496610</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.64393097</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.49774101</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.16753300</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.48408794</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.63940001</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.49247301</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.25797600</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.15704100</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.86945200</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.04877900</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.13796300</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.84186196</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.92798603</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.23917794</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.15250993</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.09084000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.00006700</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.02313000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.34098199</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.16657799</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.57656300</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >0.95882797</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.95250899</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.69871902</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.87756300</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >7.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P2 - Algo 26" number="2" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.69507301</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.40784299</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.90780997</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.72501302</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.74015898</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.25382200</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.14452900</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.08824503</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.55535197</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.18172900</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.14516200</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.55922103</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.60046500</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.42442700</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.63027501</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.55875492</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.21692500</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.47022200</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.10574600</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.78931999</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.69052303</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.07672400</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.96136999</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.76046610</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.24029499</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.09945405</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.47087801</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.15870100</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.06581800</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >2.93732905</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.98465401</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.61538899</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.67599398</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.14022899</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.40321201</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.76487398</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.77061099</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >26.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P3 - Algo 14" number="3" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.00407700</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.25679001</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.16539700</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.84062505</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.46517399</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.00483000</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.64676303</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.84629899</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.09854400</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.00791600</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.61062300</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.95030999</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.48667899</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.00477800</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.06993700</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.75130600</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.38942501</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.00782500</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.41104200</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.27949202</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.00407700</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.25679001</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.16539700</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.84062505</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.25864300</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.01353800</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.48522902</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.59696198</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.71312600</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.28748798</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.27241999</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.26588702</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.52572203</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.19395995</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.25864300</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.01353800</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.63984501</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >14.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P4 - Algo 15" number="4" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.90662998</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.48714399</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.32139200</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.40606797</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.59760898</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.49327299</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.56078398</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.40237296</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.04600400</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.39965501</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.05707600</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.04576000</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.44999999</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.28834999</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.00503100</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.17394197</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.92234999</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.22074100</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.62240303</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.88463002</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.90662998</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.48714399</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.32139200</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >1.40606797</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.06800900</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >1</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >3.00000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.77275300</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.22676900</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >2.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.60844398</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.50000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >1</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.88679200</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.06800900</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >1</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >1.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >1.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.00601800</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >15.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P5 - Algo 15" number="5" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.96287501</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.32337701</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.49186000</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.84020996</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.14415100</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.42526099</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.01630100</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.32837796</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.20652400</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.27811700</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.61361903</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.18526995</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.73841202</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.24419101</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.50996602</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.19765794</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.73597401</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.48602799</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.25236100</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.40226901</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.96287501</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.32337701</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.49186000</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.84020996</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.01365200</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.23144400</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.93768698</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.23669700</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.15309800</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >1</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.01365200</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >1.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.12722600</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >15.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P6 - Algo 08" number="6" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.81103301</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.19524901</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.15327699</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.32556105</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.71396601</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.41044101</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.30742201</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.31188798</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.98332000</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.27352101</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.24180700</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.17765599</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.32503101</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.10960800</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.73476899</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.73964906</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.84789199</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.09648500</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.15781300</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.42514896</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.89338702</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.46208900</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.06203600</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.45611811</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.97840399</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.11081800</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.55583501</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.93838799</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.15476701</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >1</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.11298200</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >1.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.40838400</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >8.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P7 - Algo 24" number="7" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.68189102</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.22785500</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.41098601</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.26900300</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.04051900</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.02405200</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.96321398</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.84745193</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.48727500</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.41811299</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.36472699</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.76593304</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.13210601</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.05269400</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.29848301</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.65822399</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.41052499</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.26225600</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.30913699</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.56427097</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.68189102</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.22785500</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.41098601</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.26900300</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.17146300</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >4.00000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.37208101</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.54000002</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >2.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.76440197</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.50000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.92068797</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >1</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.17146300</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >1.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.14582400</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >24.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P8 - Algo 07" number="8" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.09296600</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.01106000</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.41159299</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.32867101</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.88549602</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.05908600</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.25205699</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.80500400</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.73803598</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.14921799</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.42981800</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.30328202</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.28909501</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.18803400</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.56299400</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.21094298</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.16266599</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.23342501</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.12233800</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.47749805</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.65335798</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.46830699</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.94292903</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.86815000</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.10522500</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.42262501</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.25552100</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.79826999</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.10552800</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >1</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.44779399</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >1.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.22811700</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >7.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P9 - Algo 23" number="9" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.30290899</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.38707501</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.26899201</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.93231797</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.67502397</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.16093500</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.00041800</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.09141400</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.10366600</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.00193500</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.65878701</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.73744899</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.11271000</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.00127300</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.13676400</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.77189898</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.66087103</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.11100000</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.56050003</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.47329211</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.15989500</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.05934400</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.42551801</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.53765297</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.80677301</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.08207405</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.95053005</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.82139701</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.74280202</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.76222098</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.20409100</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.21000600</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.02970600</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.06597495</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >1</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.51645303</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.60639203</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >1.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.27058801</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >23.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P10 - Algo 21" number="10" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.78712398</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.38222501</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.60606301</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.01900101</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.38098401</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.38171500</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.00842500</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.55589998</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.63217998</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.37100300</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.11930500</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.79399598</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.83714998</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.41228899</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.78403801</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.48295796</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.96009499</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.14098400</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.34484199</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.25588202</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.78712398</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.38222501</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.60606301</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >1.01900101</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.63155597</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.27752101</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >1</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.53373897</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.08883700</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.36743101</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.12660694</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >1</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.02274300</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.47378397</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.32596001</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >0.85691702</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.63155597</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.27752101</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >1</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >1.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >1.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.71440899</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >21.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P11 - Algo 24" number="11" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.55057502</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.28151101</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.57013702</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.33602899</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.17948000</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.40776300</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.71761900</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.50740802</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.07635500</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.06939400</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.89899898</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.85662103</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.95121902</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.19002099</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.48948199</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.06731796</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.13138400</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.45652601</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.54585701</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.86505198</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.92295599</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.06201200</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.44819301</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >1.31787705</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.08997200</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >0.36475399</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >1</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.03827596</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.25973499</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.62208498</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >2.61496711</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >1</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.30903700</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >2.03379107</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.00942300</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.75860596</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.62478399</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.60636699</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >1</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >1.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >1.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.09093800</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >24.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P12 - Algo 17" number="12" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.06184500</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.18314400</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.26473701</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.50914299</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.35317299</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.47947001</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.23464701</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.62661004</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.68691301</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.45220801</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.34187001</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.57641500</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.32253101</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.09449300</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.29848000</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.30342501</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.86478400</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.14833499</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.61851001</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.83720899</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.06184500</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.18314400</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.26473701</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.50914299</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.97426099</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >0.89722699</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.46009195</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.17400999</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.35568899</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.70105302</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.15574400</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.44481200</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >1</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.14632700</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.59608006</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.97426099</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.89722699</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >1.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.01144100</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >17.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P13 - Algo 19" number="13" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.78176397</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.23148599</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.54540098</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.93233103</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.58119798</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.11617000</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.82642901</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.94590598</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.98476100</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.35559401</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.47756001</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.08059406</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.68707597</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.33787799</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.01246800</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.11196303</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.13531201</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.27141100</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.27999699</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.57654297</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.49249601</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.00849400</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.09917300</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.66176891</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.43127501</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.99018407</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.29410791</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.53852302</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.91766798</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.88567400</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.90632898</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >2.80335593</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >1</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.12578000</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.61598992</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.46996701</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.80258501</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >1.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.05722800</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >19.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P14 - Algo 24" number="14" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.04051900</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.02405200</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.96321398</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.84745193</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.48727500</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.41811299</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.36472699</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.76593304</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.13210601</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.05269400</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.29848301</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.65822399</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.41052499</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.26225600</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.30913699</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.56427097</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.68189102</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.22785500</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.41098601</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.26900300</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.56184000</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.37059399</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.24527000</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.12130000</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.37208101</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >4.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >1</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.25938499</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >1.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.76440197</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.92068797</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >1</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.17146300</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.30930999</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >1.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.14582400</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >24.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P15 - Algo 26" number="15" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.29052499</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.13725600</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.17913701</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.56427097</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.56189102</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.10285500</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.28098601</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.26900300</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.44183999</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.24559399</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.63000000</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.12130000</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.36727500</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.29311299</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.23472700</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.76593304</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.01210600</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.00769400</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.16848300</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.65822399</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.29052499</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.13725600</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.17913701</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.56427097</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.92068797</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >1.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >1</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >1.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.00000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.17146300</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.30930999</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >1</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.25938499</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >2.50000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >1</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.76440197</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.50000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.92068797</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >1</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >1.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >1.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >1.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.14582400</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >26.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P16 - Algo 12" number="16" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.27658999</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.31777000</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.44996101</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.05572402</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.91769600</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.44628599</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.59008002</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.65562391</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.77112699</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.42695999</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.87276697</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.13654800</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.16403900</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.45280400</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.41386899</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.11435200</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.52534097</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.39708701</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.37820500</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.88185894</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.87234199</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.34754500</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.70688897</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >1.33864200</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.74655998</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >0.91443402</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.77510905</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.61886102</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.24749100</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.41286299</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.25611001</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >2.11687398</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.90341300</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.57318711</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.12195400</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.48871401</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.69721597</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >12.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P17 - Algo 30" number="17" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.26855099</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.00533900</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.53064102</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.13739491</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.45144701</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.02572500</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.17569099</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.24896002</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.57700300</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.44702300</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.09245700</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.70819604</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.21690901</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.31302601</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.94681799</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.24434400</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.37954900</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.21851000</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.33855501</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.75737000</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.49831599</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.43701699</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.24248400</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.01477500</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.63926399</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.30046201</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.68335700</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.73356599</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.56252998</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >2.26305389</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.72073901</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.01972100</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.61866403</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.46972203</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.13364699</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.58789003</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.96073598</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >30.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P18 - Algo 11" number="18" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.05231300</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.08738600</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.60656798</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.17305303</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.67517501</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.26934001</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.51314199</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.53349090</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.29817301</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.19738300</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.13538200</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.06582999</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.43128100</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.35978299</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.39927500</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.38053799</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.65932202</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.23905100</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.99628001</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.19318300</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.44209501</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.00868300</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.94765502</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.75910300</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.85168600</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >1.59138405</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.85746896</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.85711801</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.44163999</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.62058496</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.73742402</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >2.24599910</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.39660200</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.07884300</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.94573897</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.34294599</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.15249400</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >11.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P19 - Algo 07" number="19" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.54509300</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.00899200</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.00643000</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.21438909</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.42325899</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.28699100</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.31149900</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.10191500</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.50685102</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.35204500</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.46165800</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.20269001</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.83165199</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.06610500</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.77183002</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.56026000</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.76837897</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.32045200</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.12263400</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.92189801</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.54509300</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.00899200</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.00643000</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.21438909</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.18926699</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.88968611</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.37872601</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.68845999</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.36115700</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.34201699</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.59354299</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.04208100</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.83082902</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.79363799</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.18926699</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >2.88968611</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.36568499</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >7.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P20 - Algo 14" number="20" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.46453500</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.48956999</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.93937999</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.03628898</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >1.00000000</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.32740700</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.47048399</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.24387705</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.81681699</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.50000000</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.69632202</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.77511698</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >1.00000000</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.41962001</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.01667600</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.00918000</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.73848301</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.50000000</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.94604099</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.70425391</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.62902802</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.49122101</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.08456700</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.53539097</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.55164403</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.30511594</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.86446190</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.08653800</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.30016100</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >2.48239112</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.41751400</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >2.84011507</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.40138599</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.10733700</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.86019200</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.94504499</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.46223399</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >14.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P21 - Algo 16" number="21" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.03241300</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.08691600</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.68804699</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.80739594</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.83407402</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.14569101</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.02095100</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.27844599</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.65941602</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.18590300</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.81029898</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.14286709</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.52000600</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.22144100</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.41426000</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.44613799</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.09562300</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.35394001</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.92782199</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.40898001</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.64489597</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.24118100</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.93643302</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.96572399</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.97551399</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.17137098</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.52256405</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.58462101</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.47975299</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.46678001</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.40848801</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.01305700</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.68540800</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.37050605</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.19872300</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >2.16014910</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.58240199</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >16.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P22 - Algo 05" number="22" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.23916200</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.08770400</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.89437097</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >1.52234697</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.81272000</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.25922200</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.96838701</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.12591290</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.64652401</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.33795699</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.47286999</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.99362504</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.63035899</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.26633999</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.29960099</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.60404301</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.02706700</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.27904901</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.48954499</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.13578701</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.63044399</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.09747300</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.08727700</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.19057100</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.74908298</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >0.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >0.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.49709800</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.52811497</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.44996500</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.50000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.36945200</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >0.50000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.61666799</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.50000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.20736299</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >5.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P23 - Algo 21" number="23" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.91995102</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.33722299</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.68866700</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.16228509</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.53526300</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.20471600</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.79104298</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.15002704</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.21004400</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.35217801</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.50008100</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.63198203</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.16871899</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.12298700</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.89698100</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.42943299</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.95814300</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.40693399</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.66670799</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.32055306</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.00002200</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.18308200</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.12883700</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.50649309</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.13508700</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >3.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.00000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.34951901</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.50450099</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.72504503</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.01597300</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.50840598</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.28419799</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >21.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P24 - Algo 10" number="24" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.10470500</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.10358400</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.56874800</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.79983401</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.32337001</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.38603401</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.52599198</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >1.99449205</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.48365000</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.27375999</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.19407301</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.22080004</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.43899599</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.24141601</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.04524800</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.11567300</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.85937399</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.06276800</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.75091100</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.44574809</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.20408200</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.20029099</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.63003600</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.95319009</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.52362901</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >4.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.45657501</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.92094702</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.59587097</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.04398100</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.49999899</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.46419501</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >10.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P25 - Algo 10" number="25" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.17877600</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.38086501</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.39065000</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.53042400</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.43850800</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.47037700</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.08890700</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.69870698</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.40060201</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.29610500</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.30326000</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >0.26688600</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.07780500</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.27648300</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.67251998</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.96119189</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.24368000</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.36659601</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.95869398</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >1.57798195</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.73978603</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.41572100</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.87559199</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >1.68976200</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.89934099</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >1.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.59100002</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.64803201</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.27841601</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.64029300</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.07316200</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.33109999</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >10.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P26 - Algo 25" number="26" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.46394399</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.03210900</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.69260800</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.88093501</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.99844003</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.22127700</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.04087300</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.65061307</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.07460200</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.16510101</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.37237799</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.69723105</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.69413000</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.34761599</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.69451702</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.42279994</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.88061303</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.23919100</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.69146901</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.60271102</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.66862297</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.42887500</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.32051501</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.88448191</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.54464000</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >3.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.00000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.02034300</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.59094203</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.27689001</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.10319900</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.98963398</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.49329099</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >25.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P27 - Algo 09" number="27" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.03753500</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.42680499</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.04015100</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >2.39068794</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.08108700</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.26633501</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.80921900</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.35860899</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.57362199</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.15157300</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.27601799</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.04409695</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.48450801</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.09601800</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.43276301</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >1.42178297</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.06220300</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.15226801</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.90364599</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >2.13056111</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.22056501</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.36957100</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.07999400</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >0.79585898</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.09950300</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >0.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >0.50000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.86280501</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.46525499</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >0.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.68029600</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.50000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.11961100</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >0.50000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.34352100</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >0.50000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.32942501</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >9.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P28 - Algo 26" number="28" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.99401802</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.08326400</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.01230800</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.32462600</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.79793000</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.04049500</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.05883400</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >0.14089100</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.28384900</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.45321801</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.23447800</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >2.51869893</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.41266999</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.00450100</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.31876501</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >0.31244701</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.67784601</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.17919800</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.81159401</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.67874199</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.94327098</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.20377000</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.60800099</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >2.50008392</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.35392901</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >3.50000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >2.00000000</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.44061500</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.36724699</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.50000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.59197998</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >1.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.45980299</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >1.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.81254101</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.18504199</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >26.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
<preset name="P29 - Algo 11" number="29" >
<value id="{9e13da35-ce6a-4581-abec-2c5395a24f1f}" mode="1" >0.68392801</value>
<value id="{a92533d8-c015-4de0-a136-76bc296de24d}" mode="1" >0.35826099</value>
<value id="{6b7dcbf2-c631-415b-9bfd-5d1f108316d9}" mode="1" >0.48088899</value>
<value id="{e5c6b99d-3423-4958-864e-bbffe3d7fafe}" mode="1" >0.98559397</value>
<value id="{871077d5-13ce-4ad8-a12a-ebc4180b0c86}" mode="1" >0.43086100</value>
<value id="{05ec1dfd-fdaf-4381-8048-ae47a50cf679}" mode="1" >0.08430000</value>
<value id="{36e27d45-a162-4fd9-9d98-2e439b3f91ec}" mode="1" >0.43642500</value>
<value id="{2c345a9a-0d6e-4381-aeee-d4b74b2316cf}" mode="1" >2.89685106</value>
<value id="{33f07b85-57c7-4dac-aecd-8a88397672a2}" mode="1" >0.87961203</value>
<value id="{d37dc860-9122-4463-941a-baf3d9964fb7}" mode="1" >0.34089699</value>
<value id="{f72b09db-2caa-4461-825b-62ec9795be78}" mode="1" >0.71361601</value>
<value id="{0325a2d5-bbc5-4209-809b-f3882f92c49a}" mode="1" >1.74028206</value>
<value id="{27f72d99-dcf9-41eb-957f-b961a831e299}" mode="1" >0.33409300</value>
<value id="{a46c3e5c-a08b-430b-b712-eca9cdeafb6f}" mode="1" >0.40771300</value>
<value id="{a77c4ed0-b2d4-460a-9364-8960bc569e44}" mode="1" >0.15986900</value>
<value id="{95170189-8693-4ad0-8208-2e11a78f0c92}" mode="1" >2.06114411</value>
<value id="{00476cf1-49a1-443c-b2d0-e5a58fffb07b}" mode="1" >0.21029700</value>
<value id="{de3ea287-8def-4d60-ab7f-227e03a58b89}" mode="1" >0.40020400</value>
<value id="{68f9c5c8-0c0e-44b9-a40f-5513b3ea32c7}" mode="1" >0.10994800</value>
<value id="{aef1719c-c106-4de5-8877-a83bcb0e303a}" mode="1" >0.54680097</value>
<value id="{1cb2460b-4f1e-4960-9e4d-bb8b12b2fe3a}" mode="1" >0.18720700</value>
<value id="{39bbe82d-bf66-4390-af28-728bf48bf553}" mode="1" >0.36063799</value>
<value id="{8175dd03-fb0b-4510-95a1-5e64decf4956}" mode="1" >0.27625600</value>
<value id="{14a72510-ba4d-4aaa-8abe-af9434462a84}" mode="1" >1.48997998</value>
<value id="{0b032eae-9a65-4ae9-9c6a-35c7d53551bc}" mode="1" >0.18111300</value>
<value id="{07822872-42f0-4f92-8750-01a4be5f8a8d}" mode="1" >2.17971802</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="1" >0.00000000</value>
<value id="{eca47157-c2db-455e-9f7b-8aad20172dab}" mode="4" >0</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="1" >0.00000000</value>
<value id="{4524406b-cd2a-443c-905a-f75ae638a7e3}" mode="2" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="1" >0.00000000</value>
<value id="{4057129d-e5b6-4d43-a7b3-cc89da41cf95}" mode="4" >0</value>
<value id="{5bb7f949-bc2e-4ecd-9c4f-144cb3889d0d}" mode="1" >0.08031700</value>
<value id="{52cdd897-93c5-4ce6-8363-2f1b80beffab}" mode="1" >0.52856100</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="1" >0.00000000</value>
<value id="{2d3bc5fe-7027-46b1-9cc8-249259c15fb8}" mode="2" >0.00000000</value>
<value id="{8af14ba4-ad9f-4ba8-85ec-45a83238fdbb}" mode="1" >0.88808298</value>
<value id="{6fd61b15-bc21-41f0-888d-526675b6ec12}" mode="1" >1.83663595</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="1" >0.00000000</value>
<value id="{2ee5c696-e953-46b9-a0fc-3c0a6b50644f}" mode="4" >0</value>
<value id="{546eff0f-e7a8-40f3-9450-9fffe360958f}" mode="1" >0.19596300</value>
<value id="{62157ee3-b7e1-404a-925d-973bfa2e48d5}" mode="1" >0.89963597</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="1" >0.00000000</value>
<value id="{93af235b-99d6-4ecb-9ec7-7d1421350c86}" mode="4" >0</value>
<value id="{37c7aa17-e643-4e75-bf58-6969b2ed6c31}" mode="1" >0.58686298</value>
<value id="{1b153ca8-1cc5-4578-850d-6ba111c78a82}" mode="1" >2.84586692</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="1" >0.00000000</value>
<value id="{ba06f48d-fd4f-4ea2-b22d-8b6e6a8f48ef}" mode="4" >0</value>
<value id="{9f825ec8-2820-4a22-b358-03e0db0f6f49}" mode="1" >0.29890800</value>
<value id="{04bcd67b-1f71-4738-a580-5d34453e3158}" mode="1" >1.45816803</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="1" >0.00000000</value>
<value id="{79864394-9898-4781-bbfb-184658696f75}" mode="4" >0</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="1" >0.00000000</value>
<value id="{cbf3123a-da5d-4a4b-a00f-fb4c616ea9ce}" mode="2" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="1" >0.00000000</value>
<value id="{0143b8ab-2979-4e92-99e2-490b0574111d}" mode="2" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="1" >0.00000000</value>
<value id="{1fd0c423-2ff8-4928-bbfc-256559958e19}" mode="2" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="1" >0.00000000</value>
<value id="{f75e7659-703c-4211-b6c5-933965e48faf}" mode="2" >0.00000000</value>
<value id="{487c8bfd-d023-43ea-b959-dac28c1e341d}" mode="4" >0</value>
<value id="{a5dc696a-15ba-47c2-9cf7-5788a868b0d4}" mode="4" >0</value>
<value id="{a21166bb-8c6d-48a7-8005-837613fc83b5}" mode="4" >0</value>
<value id="{c2e1dc15-bcc8-4ee5-9a36-334ce7a3f448}" mode="4" >0</value>
<value id="{2e11e07e-5d93-42b2-8886-62ae9b5e75bb}" mode="4" >0</value>
<value id="{a509c2de-6235-4dd2-9449-757808be3cef}" mode="4" >0</value>
<value id="{c1d6dfa2-27a8-4abb-9977-4570671e6f3a}" mode="4" >0</value>
<value id="{b419a8fc-7dfb-4c6f-84f5-88a7ffdd888a}" mode="4" >0</value>
<value id="{ebdf3efb-c5bb-411c-adde-e324295ac1b6}" mode="4" >0</value>
<value id="{bed43a1a-6250-459f-b05a-f3fd98bc5318}" mode="4" >0</value>
<value id="{58a81e21-97d6-4731-8910-53f1f0537605}" mode="1" >0.40724799</value>
<value id="{6bef771a-4786-43cb-a9c1-3d8f9e0d0728}" mode="1" >11.00000000</value>
<value id="{f2e13afc-4068-4d76-90c2-2765a4b0bede}" mode="1" >1.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="1" >0.00000000</value>
<value id="{7b81436f-ee9d-441a-b954-c9debb293494}" mode="4" >0</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="1" >0.00000000</value>
<value id="{77612985-9528-4347-a5ab-f7302ad4f5fc}" mode="2" >0.00000000</value>
</preset>
</bsbPresets>
<EventPanel name="Tests" tempo="60.00000000" loop="8.00000000" x="453" y="425" width="802" height="346" visible="false" loopStart="0" loopEnd="0">i 10  0  3.000000  440.000000 100 24 0.090938 0.550575 0.281511 0.570137 0.336029 0.364754 0.089972 0.179480 0.407763 0.717619 1.507408 2.038276 0.259735 0.076355 0.069394 0.898999 2.856621 2.614967 0.622085 0.951219 0.190021 0.489482 2.067318 2.033791 0.309037 0.131384 0.456526 0.545857 1.865052 2.758606 0.009423 0.922956 0.062012 0.448193 1.317877 1.606367 0.624784 1 0 1 0 0 1 
    
i 10  1  3.000000  440.000000 100 1 0.478926 0.599167 0.028437 0.206165 2.547630 3.000000 0.154535 0.435037 0.410224 0.935346 2.917274 1.000000 0.507214 0.527054 0.351074 0.123741 1.529569 3.500000 0.299779 0.483123 0.321528 0.215652 2.631786 5.000000 0.584880 0.575536 0.251249 0.363890 1.449478 2.000000 0.847388 0.195493 0.153552 0.211472 1.048423 2.000000 0.137826 0 0 0 0 0 0 
    
i 10  2  3.000000  440.000000 100 23 0.270588 0.302909 0.387075 0.268992 1.932318 1.082074 0.806773 0.675024 0.160935 0.000418 0.091414 1.950530 0.821397 0.103666 0.001935 0.658787 0.737449 0.762221 0.742802 0.112710 0.001273 0.136764 2.771899 0.210006 0.204091 0.660871 0.111000 0.560500 2.473292 1.065975 0.029706 0.159895 0.059344 0.425518 2.537653 0.606392 0.516453 0 1 0 0 1 0 
    
i 10  3  3.000000  440.000000 56 23 0.270588 0.302909 0.387075 0.268992 1.932318 1.082074 0.806773 0.675024 0.160935 0.000418 0.091414 1.950530 0.821397 0.103666 0.001935 0.658787 0.737449 0.762221 0.742802 0.112710 0.001273 0.136764 2.771899 0.210006 0.204091 0.660871 0.111000 0.560500 2.473292 1.065975 0.029706 0.159895 0.059344 0.425518 2.537653 0.606392 0.516453 0 1 0 0 1 0 
    </EventPanel>
