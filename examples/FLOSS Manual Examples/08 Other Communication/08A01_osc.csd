<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

; localhost means communication on the same machine, otherwise you need
; an IP adress
#define IPADDRESS	# "localhost" #
#define S_PORT 		# 47120 #
#define R_PORT 		# 47120 #

turnon 1000  ; starts instrument 1000 immediately
turnon 1001  ; starts instrument 1001 immediately
	

instr 1000  ; this instrument sends OSC-values
	kValue1 randomh 0, 0.8, 4
	kNum randomh 0, 8, 8
	kMidiKey tab (int(kNum)), 2
	kOctave randomh 0, 7, 4
	kValue2 = cpsmidinn (kMidiKey*kOctave+33)
	kValue3 randomh 0.4, 1, 4
	Stext sprintf "%i", $S_PORT
	OSCsend   kValue1+kValue2, $IPADDRESS, $S_PORT, "/QuteCsound",
                  "fff", kValue1, kValue2, kValue3
endin


instr 1001  ; this instrument receives OSC-values	
	kValue1Received init 0.0
	kValue2Received init 0.0
	kValue3Received init 0.0
	Stext sprintf "%i", $R_PORT
	ihandle OSCinit $R_PORT
	kAction  OSClisten	ihandle, "/QuteCsound", "fff",
                 kValue1Received, kValue2Received, kValue3Received
		if (kAction == 1) then	
			printk2 kValue2Received
			printk2 kValue1Received
			
		endif
	aSine poscil3 kValue1Received, kValue2Received, 1
	; a bit reverbration
	aInVerb = aSine*kValue3Received
	aWetL, aWetR freeverb aInVerb, aInVerb, 0.4, 0.8
outs aWetL+aSine, aWetR+aSine
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
f 2 0 8 -2      0 2 4 7 9 11 0 2
e 3600
</CsScore>
</CsoundSynthesizer>
; example by Alex Hofmann (Mar. 2011)
