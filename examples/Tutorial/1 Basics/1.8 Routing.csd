/* Getting started.. 1.8 Routing
Combining Csound's Opcodes is based on the same signal flow principle you have with most analog synths.

As a first example (instr 1) a raw SAWTOOTH oscillator is directly sent to the computer audio output.
SAW -> Output

In the second instrument (instr 2), the same SAWTOOTH Oscillator will first pass a resonant low pass filter, before the filtered signal goes to the audio output.
SAW -> LP -> Output

The third example (instr 3) shows, how the frequency of the SAW can be modulated by a low frequency sine oscillator (LFO).
LFO ~> SAW -> LP -> Output 

In the last example (instr 4) the same LFO is now used to modulate the filters frequency and not the SAW pitch anymore.
SAW -> LP -> Output
	  ^
	 LFO
*/
 
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

#define SAWFREQ #150# ;freq in Hz
/*
The expression #define is used for textual replacement, also called macros.
Here it is used to paste the same frequency-value (150) in every instrument. If you want to change the SAW frequency for all instruments at once, just change the #150# to the desired Hz. 
Find out more about macro usage in the Csound Manual: 1. Overview->Syntax of the Orchestra->Macros
direct: OrchMacros (Shift+F1)
*/


instr 1
aSaw oscili 0.2, $SAWFREQ, 1 	;$-sign calls the defined macro
outs aSaw, aSaw
endin

instr 2
aSaw oscili 0.2, $SAWFREQ, 1
aFiltered lowpass2 aSaw, 200, 5 	;butlp
outs aFiltered, aFiltered
endin

instr 3
kSinLFO oscili 50, 3, 2
aSaw oscili 0.2, $SAWFREQ+kSinLFO, 1
aFiltered lowpass2 aSaw, 200, 5
outs aFiltered, aFiltered
endin

instr 4
kSinLFO oscili 50, 3, 2
aSaw oscili 0.2, $SAWFREQ, 1
aFiltered lowpass2 aSaw, 200+kSinLFO, 5
outs aFiltered, aFiltered
endin

</CsInstruments>
; In this example we use the score to play the four different instruments one after the other for 2 seconds, with a one second break inbetween.
<CsScore>
f 1 0 1024 7 -1 1024 1 		;saw-waveform functiontable
f 2 0 1024 10 1 				;sine-waveform functiontable
; instr  start  dur
i1 		0 	2
i2 		3 	2
i3 		6 	2
i4		9	2
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 519 212 290 395
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioGraph {8, 110} {268, 148} scope 2.000000 -1.000000 
ioText {8, 20} {269, 86} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder See how the SAW output-waveform changes, because of the used LP filter and the modulation.
</MacGUI>

