;Written by Iain McCurdy, 2009

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Browser for pluck file
;	INIT instrument added
;	Use event_i and instrument 5 to simulate a FLsetVal_i opcode
;	Removed subinstr opcode in midi instrument 1 because midi note was played with previous freq and amp values (only on my csd, original FLTK csd is ok)
;	Use Base64 encoded files embedded in csd: mandpluk.aiff


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	2	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkamp		invalue	"Amp"
		gkfreq		invalue	"Freq"
		gkpluck		invalue	"Pluck"
		gkdetune		invalue	"Detune"
		gkgain		invalue	"Gain"
		gksize		invalue	"Size"

;AUDIO FILE CHANGE / LOAD IN TABLES ********************************************************************************************************
		Sfile_new		strcpy	""							;INIT TO EMPTY STRING
		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		if	kfile != 0	then								;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
				reinit	NEW_FILE							;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		ilen		filelen	Sfile							;Find length
		isr		filesr	Sfile							;Find sample rate
		isamps	=		ilen * isr						;Total number of samples

		isize	init		1
		LOOP:
		isize	=		isize * 2
		if (isize < isamps) igoto LOOP						;Loop until isize is greater than number of samples

		gifn		ftgen	0, 0, isize, 1, Sfile, 0, 0, 1		;READ AUDIO FILE CHANNEL 1
;*******************************************************************************************************************************************
	endif
endin

instr	1	;MIDI ACTIVATED INSTRUMENT
	ifreq	cpsmidi										;FREQUENCY IS READ FROM INCOMING MIDI NOTE
	iamp		ampmidi	1									;AMPLITUDE IS READ FROM INCOMING MIDI NOTE

			event_i	"i", 5, 0, 0.1, iamp, ifreq				;SEND AMPLITUDE VALUE TO AMPLITUDE SLIDER and FREQUENCY VALUE TO FREQUENCY SLIDER

	ares 	mandol 	iamp, ifreq, gkpluck, gkdetune, gkgain, gksize, gifn ;[, iminfreq]
	aenv		linsegr	1,3600,1,0.1,0							;CREATE AN AMPLITUDE ENVELOPE. THIS WILL BE USED TO PREVENT CLICKS.
			outs 	ares*aenv, ares*aenv					;SEND AUDIO TO OUTPUTS
endin

instr	3	;GUI BUTTON ACTIVATED INSTRUMENT
	ares 	mandol 	i(gkamp), i(gkfreq), gkpluck, gkdetune, gkgain, gksize, gifn ;[, iminfreq]
			outs 	ares, ares							;SEND AUDIO TO OUTPUTS
endin

instr	4	;INIT
		outvalue	"Amp"	, 0.3
		outvalue	"Freq"	,250
		outvalue	"Pluck"	,0.1
		outvalue	"Detune"	,0.9
		outvalue	"Gain"	,0.97
		outvalue	"Size"	,1
endin

instr	5	;UPDATE
		outvalue	"Amp", p4									;SEND AMPLITUDE VALUE TO AMPLITUDE SLIDER
		outvalue	"Freq", p5								;SEND FREQUENCY VALUE TO FREQUENCY SLIDER
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION 
i 2		0		3600	;GUI 
i 4		0		0.1	;INIT 
</CsScore>
<CsFileB filename=mandpluk.aiff>
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
DIkOaBBdEhkTXxQXFH0U1xVNFcwWMhaIFxQYHRm/G7YdaR5bHmMduBy+G8Uawhl7F7QVcBLp
EIUOfAzNCzIJZQdOBP4CpgBn/iD7fvhE9IHwtu1560LqFOmK6SLom+gF55jnhufH6C/of+iO
6D7ngeZa5PrjwuMh42fkneZq6HPqb+xO7j7wa/Le9XP38foc++L9Ov5V/2AAfgHOA0gEyQY/
B7wJXAtADVUPXBEAEgYScBJyEjgR4BF6ESMRIRG+EwcUtBY9FxgXGxaFFb8VFBRuE2URpg8U
DA0JMQcBBbsFQQU9BVUFVAUhBNEEbAQAA4wC8AIBAKX+6v0F+2L6Yfob+mX6uPp5+VP3VPT5
8trxS/BN74Xuc+zb6sLobeZD5JbjmuNo4+nk+OZV58LpEeo9613sj+3b7x/wOfEi8frzF/TW
9136mf41AdcFLQgKCnQMjw55ED0R0BMNE+EUXBTFFWUWWBd9GHUY2Bh2F3oWPBUaFDQTTRIW
EGAOSgw8CrEJ5gnCCekJ8QmjCPcIIgdVBqEF+QU6BEAC+gFz/8T+FPyL+1H6hPoi+gT59fnJ
+WP42vhD9673DvY/9Srz4fKR8X3w4vDD8Q7xhvHs8hXx7vGA8OvwYvAI7/PwFvBc8LHxFPGm
8orz0vV591/5T/sW/In9i/4Y/kb+Sf5X/o7++P+MADsBAgH8Ay4EpAZZCEcKcQzTD2AR7RQe
FZcWIBW/FM4TzRMwEzATtRR3FR0VYxUqFGoTNhGqD+wODQwTCfEHiATbAhf/iv2C/C77fPsw
+uv6cPms+Kb3gPZj9Wf0jfPH8u/x5fCZ7zHt9e1A7UruGe928PnyRvMa82TzUPMw81Lz4vTE
9aX2N/Za9kD2Rvau94/4tPnW+tj7v/yi/Xr+LP6M/qr+0f9sALYChQReBckGlQcVB94JWguD
DcQPVg+sDssNOAu6CuQK5At7DC0MmAyPDCALhAr6CqgKmgq7CtEKmwnfCI0G3wVDBDcECwSk
BYYGDQXEBKQDHwG7ANYAX//5/0n+HfyN+tj5M/fA9pH1vPVK9SH1AfST85zyNfC375nvGe8f
71nvce9T7zPvXvAU8V3zD/To9r/4a/np+zz8cf2U/qH/ngCFAVsCOQM2BFsFoAbeB/YI1gl2
CdwKAAnLCS4IOQceBhwFbAUYBRUFRwWYBgEGgQcHB4oIAghrCMII5gitB/EGsgUsA8MC0AJ8
ArADKQOgA/UEJgRIBGYEhgSXBIkERQO0AsUBdP/g/kP87Pwa++T8Kvyd/On82vxz++r7hfto
+3T7WfrE+aT4Ovb29kv2Xfb898v4dPjS+Pf5A/kG+PL4u/he9/f3m/dU9wz2sfZU9ij2evd1
+QP6wvw9/Sn9ff2M/cX+ff+9AUQCvQP0BOQFvga+B/cJWgq6C/MM+w3UDnoO1w7LDk0NeQyP
C9ALWwsXCtEKVwmjCNEICwdtBu0GcgXWBREEFwLpAZQAH/6n/Vz8YvvF+277K/rT+lb5zflq
+UP5U/ly+W35G/h496D2wvYL9Z/1hfWz9gf2TvZR9fP1RfSP9Cr0XPUc9hb25vda9534F/ks
+uH81v57/3b/zf/WAAMAjwFiAjwC6wNpA90EaAUXBdMGggclB9sIuQm0CpILBArgCi8JOQhK
B5kHMgb+Bt8GwgahBngGTAYvBi0GTQaBBp4GeQYEBU0EhAPdA24DMwMIAtcClAI/AdkBXgDL
ABz/W/6H/Zr8hfs8+dL4Z/cu9kj1v/V/9Wv1ZPVW9T/1LfUz9V71pfXr9hH2CPXq9er2Pfb9
+A75M/pE+zn8Kv0x/kv/UwAhAJ8A5QEQATEBSwFeAXYBwQJtA30ExgX8BuUHcwe7B+cIEQgt
CCIH5weHByoG8AbiBuwG9gb4BvwHHwdoB8cIDQgUB9kHZAbZBkoFsAT7BCkDQwJdAYgAuP/b
/ub93/zi/A77avrq+m/54/lJ+Lr4T/gj+Cv4UviD+K/41fkB+TX5cPmp+dX58Pn++gf6Gfo4
+mf6pPre+wf7GPsN+vn67vsH+1T71Px0/Q/9ff2m/Zj9jP3C/mj/cwCvAc4CqgNFA9EEdQVB
Bh4G3AdlB7MH3Af+CC4IgwkDCawKYAruCx4K0QoSCRcIGgdHBpUF4wUJBAAC3QHKAOgARv/S
/3b/IP7D/mP+Bv21/Wz9LPzv/LT8dvw3/AD73fvR+9r76Pvc+6H7K/qQ+e35Y/j4+KT4VfgD
97v3nffJ+E75G/oP+vz7yvxo/OP9Rv2m/gb+Y/6u/tX+2P7H/sD+7P9tAEoBZQKOA5IEWwTu
BW8F8wZ1BtAG2QZ1BbUEywP0A2YDKQMuA0YDSwMrAu4CrQKDAnwCiAKQAn8CSwIFAcQBpQG/
AhYCogNDA9EEIgQdA8ADLAKNAf0BhAEKAHX/rf7D/dH8/PxW++H7i/tC+vz6uPp2+jz6D/nt
+d754fn5+in6YvqZ+rz6y/rW+vj7S/vQ/Hb9Gf2V/eX+D/4u/lv+pP8J/33/8ABbALUA/wE+
AXYBpwHLAd8B4gHRAbYBlAF2AVkBRAFEAWEBnwH3AlMClgK8AtEC+QNUA+wEowVEBaEFqQV1
BTcFHgUxBVQFVQUMBGsDiwKWAaoA0wAE/y3+S/1s/Lb8Q/wf/Df8bfyc/LT8qfyF/FH8JfwZ
/DD8YvyT/KX8kPxo/FH8Y/yl/QX9Y/20/fX+Jv5I/lv+Xv5a/lL+T/5G/iz+Cf3x/gD+Tv7U
/23/6QAjABL/1v+a/3j/gP+j/88ABABNAMIBbQJFAzMEDwTMBVsFwwYKBi8GLAX7BZ0FIASP
A/QDWgLDAjkBxQFqAR4A2ACKADP/4f+p/43/if+B/2P/If7K/nj+Q/4+/mz+uP8K/0f/V/8w
/tj+aP36/an9f/10/XL9bv1j/Vr9Y/2C/a792P3u/e792/29/Z39ef1R/Sn9Bvzx/PT9F/1Z
/bH+Ef51/tf/Pf+wAC8ArwEcAWcBhQF/AWUBSgE2ATABNQE7ATgBJwD/AMUAiQBTACwAD//s
/7n/fv9P/0H/Xf+Q/8b/7wAMADAAagDBASoBlAH0AkcCjQLOAwsDRgODA70D6wP4A9EDaQLI
AgsBVgDEAFkAB/+z/0r+zv5O/eP9n/2G/Yz9oP2l/Yn9Tvz0/JT8Svwl/C38VvyN/ML89P00
/ZT+G/7B/2f/7wBCAF8AWABBACwAIQAZAAz/8v/K/5v/df9m/33/tgAMAGIApADBALsApQCf
AMEBEgGFAgcCfQLdAyUDYwOiA98EFAQuBCAD5QN9AvMCTQGbAOsATP/N/37/Wv9Y/2T/Z/9Q
/xv+zP51/iD91/2X/V39Jvz3/Nn80/zu/Sj9ff3p/mT+7f9z/+8ATQCKAKgAsgCzAK8AogCH
AFYAE//M/4n/Tf8X/t3+mP5O/gX9yP2d/YL9a/1P/Sn9Bvz3/Rf9aP3m/nj/Af9q/7L/5AAV
AFYApwD/AU4BjQG5AdkB9gIQAiUCLgInAg4B6AGxAW0BHwDVAJkAeAB1AIUAmwCqALMAuADE
ANsA8gD/AQIA/AD2APIA6ADSAKUAbAA2ABsAHgA2AE8AVQBEACH/9f/D/4f/QP7v/p7+Vf4V
/df9lf1P/RH85vzT/NP81/za/OP8/P0v/Xn9y/4a/mb+vf8t/70AWQDoAVMBigGUAYEBXwE5
ARMA5wC2AHwAOP/s/6P/av9P/1f/gP++AAEAPgBtAI0AlQCKAHYAZwBsAIkAuwD1ASgBUwF4
AaIB1wITAk0CdwKLAooCeQJdAjMB+QGxAVsBCADFAJkAfABiADn/+f+m/0n+7P6R/jL9yf1U
/N38dPwr/Aj8Gvxg/Nz9gP49/vf/kP/4ACkAMgAmABD//v/p/8//sP+P/2z/T/84/yz/MP9G
/2z/m//K/+n/7//j/8//yf/W//wALwBiAJIAuQDlARkBUwGNAbsB0wHaAdQByAG3AaIBiAFr
AVYBTgFVAWIBaAFbATgBAQC8AGwAD/+p/0D+4f6U/lr+Kf36/cv9qP2c/av9zP31/hr+Pv5v
/rf/EP9p/7D/4AAAACYAXgCoAPYBMAFCASgA6wCSAC3/yf9n/xD+w/6A/kH+CP3S/az9pf3D
/gj+Wv6k/s/+3f7b/uT/Cv9N/6YAAABQAJIAywD/ATABUwFkAV4BRQEnARIBCwESARgBDQDk
AKIAXAAnABkANQBqAJMAmwBwACb/1v+d/4f/kP+j/6b/lv94/2H/YP9+/70AEABsAMEBAgEl
ASUBBwDVAJ4AagA4AAH/tv9d/wD+sv6B/nH+a/5U/iX93/2c/Xr9g/23/gL+TP6L/r7+9f89
/54AFgCZARIBagGRAY4BcQFOATsBOAEzARwA6ACfAFkAKQATABMAGQAYAAz/9f/Q/5v/V/8K
/sP+jv5x/mj+a/54/pX+zP8g/4b/6gA7AHUApADcASIBbQGlAbsBrQGZAZcBuwH2AisCOgIa
AdMBfAEoANwAkgBC/+//nf9V/xf+4f6v/ob+cv6A/rL+/f9M/4n/qv+2/73/xv/V/97/2f/B
/6D/hP92/3X/cP9b/y3+7/6v/oH+aP5g/lv+TP4y/g/98f3o/f3+Mf53/r3+7P8B/wT/Cf8m
/17/rQAHAFwApQDeAQQBIQE8AWIBlwHeAiACSwJOAioB6AGhAWUBNQEHAM0AiQA+//7/0P+y
/5b/c/9H/xv++v7x/vr/DP8k/0T/b/+yAAwAeADnAU4BqAHzAigCQgI0Af8BqAE/ANUAcAAQ
/6z/RP7g/on+S/4g/gP96f3S/cD9v/3R/e7+Bf4M/f395v3X/eP+Ff5k/r7/D/9H/2P/av9v
/37/of/VABIATQB7AJkAqgC2AMUA3gD5ARABEgD2ALsAbQAY/8z/iv9X/y3/DP76/v7/Hv9g
/8AAMwCqARgBcwG5AeoCCAIOAfwBzQGHATAA2ACFAD4AB//h/8T/r/+S/2n/MP7y/rr+lP6E
/n7+cv5d/j3+I/4j/kP+g/7U/yT/av+m/9gABwA4AGQAiQChALMAxQDhAQcBMwFYAWoBXwE8
AQUAxACEAEoAFv/k/6r/ZP8V/sz+lf59/oT+oP7A/tT+2v7U/tH+2/79/zX/ff/KABYAWACN
ALYA2wECATABZAGWAbwBywG+AZwBawEwAPAAqgBfABn/4/+9/6f/mP+E/2n/TP86/zX/Qf9T
/2r/gf+b/7j/1v/s//j//gAJABwANgBHAEIAIf/q/7D/hP9m/1D/Ov8a/vj+4P7U/tH+z/7J
/rv+rv6m/qT+o/6a/ob+bP5Y/lj+b/6g/uT/OP+S/+0AQgCMAMcA/AEwAWUBlgG5AcIBqgF0
AS4A5QCoAH4AXgA/ABj/5v+p/2r/NP8H/uT+zv7A/r3+xP7Y/vX/Hv9P/4r/zAAQAFMAjAC2
ANAA2QDVAMcAtgCiAJIAhwCCAIcAlgCqAL4AwgCyAIoAUAAQ/9X/pP9+/1X/I/7m/qr+gP5y
/ob+tP7p/xr/Pv9a/3P/kv+4/+YAFgBBAGEAeQCHAI8AkACMAHsAXwA7AA//4/+7/5j/df9Q
/yb++/7a/sz+3f8H/0H/dv+W/5b/gf9j/1L/YP+N/9UAIwBqAJ4AvgDTAOgBBAEiATgBOwEn
AQQA2QCzAJMAdQBQACb/+P/S/7b/pv+W/4f/df9k/1f/UP9S/1j/Y/9y/4f/oP+7/9X/7QAJ
ACwAUwB5AJUAngCTAHgAWwBEAD8ARgBPAFAAPgAb/+z/uf+N/2n/Rv8g/vX+xv6V/mv+S/41
/in+LP4+/mT+m/7h/zL/hv/ZACcAbQCqAN8BCAElATABLgEkARAA9gDVALAAjABwAFwATwA/
ACcAA//Y/7D/k/+D/33/ff+A/4T/h/+N/5L/m/+m/7b/zP/h//YACQAeADYAUwBtAH4AggB/
AHsAgQCSAKcAswCsAIwAVQAN/73/av8d/tf+of5+/mv+Y/5e/mH+b/6P/sP/Cf9S/5P/xP/n
AAAAEgAjAC8ALwAmABkAEAAVACEAMAA2ACwAE//v/8f/pP+H/3D/Xv9Q/0r/Sv9N/0//Sv8+
/y3/Hv8V/xj/JP84/1j/g/+5//wARACEALgA3gD8ARkBOQFbAXEBdgFoAUoBJwEEAOQAwgCZ
AGkAMP/7/8r/of9+/1r/NP8P/u/+1/7H/sb+z/7j/v3/Gv81/03/Z/+G/7D/4wAWAD8AVgBY
AEoAOQAvAC8ANgA7ADYAH//7/9L/qf+G/2f/Sf8m/wb+8v7x/wf/Kv9S/3L/iv+h/73/4AAK
ADMAVgB1AI0AnwCtALUAtgC7AMEAzQDbAOIA3wDQALsApACWAJAAigB5AFYAI//n/7D/hv9t
/1v/R/8s/wn+5/7U/tX+7f8V/0b/e/+z/+kAGQBCAGIAfACSAKQAsACtAJgAbwA8AA//5//G
/6b/gP9V/y//Ev79/un+0v61/p3+kv6e/sT++/84/2//mv+5/9L/6f/+ABIAIQAsADMAQQBS
AGoAiQClAL8A0wDhAOoA7QDqAOIA0gC4AJIAXgAb/83/gP84/wH+2P6+/rH+rv66/tX/AP81
/23/pP/WAAYANQBeAIQAoQCzAL4AvACwAJkAfgBiAE0ARABHAEwASgA8AB7/+P/N/6f/h/9s
/1X/QP8y/y3/Mv9A/1D/Xv9n/23/cv+A/5j/uf/hAAYAHwAsADAAMAAwADIAMwAyACoAHAAJ
/+3/0P+y/5P/eP9h/03/Pf8v/yn/Kf8t/zT/O/9G/1f/bf+K/6r/yf/j//sAFgA1AFgAcwCK
AJwAqgC+ANMA5wDyAOoA0ACsAH4AUgAm//n/zP+b/2D/Gv7H/nH+IP3g/bj9rv3A/ej+Hf5b
/p3+3f8b/1f/j//E//YAJABMAGwAfwCJAIcAfgBwAGQAWwBWAFYAWwBhAGcAbABsAGkAYQBc
AFMARgAyABsABP/2//D/8v/5AAEACgAWACcAPwBbAHUAjwCiALIAwQDTAOoBAQEVARwBFgD+
ANkAqABzADwABP/P/5r/Zv81/wf+3v7A/rH+sv7E/uD/Af8h/z7/Xf+E/7j/8wAqAFUAaQBn
AFwAUgBNAE8AUgBTAFMATwBMAEQANgAfAAT/5//K/6r/gf9Q/xr+6v7M/r7+vv7D/sT+w/7G
/tf++/8v/2n/nf/K//AAGQBHAHgApADCANIA0wDQAMsAxQC8AKgAjwByAFUAOwAhAAb/5P+9
/5P/bf9M/zT/I/8a/xj/IP8t/z3/TP9a/2n/gf+k/9UACQA2AFIAWQBVAFAAVQBpAIEAkACQ
AHsAWwA7ACMAEP/+/+b/xv+d/3D/RP8b/vr+5v7e/ur/B/8t/1X/ev+b/8P/7QAeAEoAaQB5
AH4AfAB8AHsAdQBpAFMAPgAwAC8AOQBMAFYAVQBEACT//v/V/7D/jP9p/0b/I/8D/uz+4/7q
/v3/F/8y/0//b/+W/8P/9QAmAE8AcgCKAJsAqACyALkAvwC8ALIAlgBvAD4ACv/e/7n/nf+E
/2f/Rv8j/wb+9/76/w//MP9Q/2r/df9z/2z/ZP9g/2P/b/+E/6D/wP/b//MACQAbADAASQBh
AHMAeQB1AG8AaQBnAGEATwAs//j/w/+T/3X/ZP9Y/03/QP83/z3/Vf99/6r/0P/tAAcAIQBC
AGkAjQCqALsAvwC7AK0AmQB+AF8AQQAnABMACQAGAAP//v/z/+T/zP+s/4P/Vf8m/v7+5v7d
/uT+8f7+/wn/F/8t/1P/h/++/+8AEwAtAEQAXAB2AI8AnwClAKIAlgCEAGoASQAh//v/3v/N
/8b/wP+y/5v/g/9s/17/YP9v/4b/m/+q/7X/u//D/83/3P/s//b//gAEAAwAHAAzAEwAZAB4
AIQAigCMAIcAfABqAFAALQAJ/9z/rf97/0z/I/8E/vH+5/7p/u/++/8M/yT/RP9v/57/zP/z
ABIAJgAyADkAPwBEAEkAUABbAGcAcwB5AHYAaQBPADAAE//8/+3/3v/Q/73/o/+E/2n/Vf9N
/0//Uv9V/1P/Vf9Y/2T/eP+P/6r/yf/vABkARgBqAIQAkACTAJAAjwCHAHkAZABGAB//+f/T
/6r/gf9V/zL/GP8N/xD/Gv8j/yT/If8a/xj/I/84/1j/ev+Y/7P/yv/j//4AHAA7AFgAcACC
AI8AlgCbAJwAmQCZAJwAnwCeAJAAcABCAA//3P+2/5v/hv9v/1P/OP8k/x7/Kv9E/2f/j/+4
/+QADAAsAD8AQgA8ADAAKQApAC0ANQA7ADkAMwAnABUAAP/n/9D/wP+2/6z/m/+A/17/Q/8+
/1r/jf/K
</CsFileB>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>204</y>
 <width>795</width>
 <height>333</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>510</width>
  <height>330</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>mandol</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>128</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amp</objectName>
  <x>8</x>
  <y>111</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp</objectName>
  <x>448</x>
  <y>128</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>163</y>
  <width>220</width>
  <height>30</height>
  <uuid>{989564b0-b237-4c22-9d10-b76b7c7e4e4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Freq</objectName>
  <x>8</x>
  <y>146</y>
  <width>500</width>
  <height>27</height>
  <uuid>{84cd664e-fb67-4dd4-aac3-adbcf2c81fe6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>20.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>250.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Freq</objectName>
  <x>448</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ba8682a6-056f-4432-946b-4e3ee82c47a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>250.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>197</y>
  <width>200</width>
  <height>30</height>
  <uuid>{76044785-79c4-4202-b7ce-07aee4868219}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pluck Position</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Pluck</objectName>
  <x>8</x>
  <y>180</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0f952e77-ff9b-4621-b1af-23252bb9c2a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pluck</objectName>
  <x>448</x>
  <y>197</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>232</y>
  <width>220</width>
  <height>30</height>
  <uuid>{ca41878c-b561-486b-9cf9-d0da6b48448b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Detune</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Detune</objectName>
  <x>8</x>
  <y>215</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2800fb88-347a-402c-88ed-fc97af6a36be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.90000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.90000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Detune</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.900</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>267</y>
  <width>220</width>
  <height>30</height>
  <uuid>{cdd71125-b224-471a-9c41-9c05d8d28d0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain</objectName>
  <x>8</x>
  <y>250</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7a83bb1f-f25d-47e0-bf2d-9c5c86e0756b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.97000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.97000003</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>267</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.970</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>515</x>
  <y>2</y>
  <width>280</width>
  <height>330</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>mandol</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>25</y>
  <width>279</width>
  <height>304</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------
'mandol' implements a physical model of a mandolin.
This instrument can be triggered by either the GUI button or by a connected MIDI keyboard. 'detune' controls the amount of detuning between each pair of strings.
'Gain' controls the amount of feedback within the algorithm which ultimately gives control over the sustain of the "instrument. 'Size' is a control over the size of the instrument.
'Pluck Position' offers control over where, along the length of the string, plucking occurs.
gifn is the table number containing the pluck wave form. The file mandpluk.aiff is suitable for this.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>16</y>
  <width>100</width>
  <height>30</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pluck !</text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>303</y>
  <width>220</width>
  <height>30</height>
  <uuid>{ca67a321-de0d-4a0f-8efd-864d9a51098c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Size</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Size</objectName>
  <x>8</x>
  <y>286</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0341fedb-6323-4661-b4c3-8207291fcd90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00400000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Size</objectName>
  <x>448</x>
  <y>303</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3c428724-1329-4e7c-bdb5-6e1277f3c2ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>53</y>
  <width>97</width>
  <height>30</height>
  <uuid>{3c19fbdc-3d2b-4583-8316-52f7a3a433e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>PLUCK WAVE :</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>75</y>
  <width>170</width>
  <height>30</height>
  <uuid>{43341095-bc3a-4607-bd0e-01254da7bc67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>mandpluk.aiff</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>177</x>
  <y>76</y>
  <width>330</width>
  <height>28</height>
  <uuid>{b66f3878-dfd0-4290-9b9d-73be88197222}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>mandpluk.aiff</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
