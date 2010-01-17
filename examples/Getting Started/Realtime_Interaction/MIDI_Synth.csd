/*Getting started.. Realtime Interaction: MIDI Notes / MIDI Synth


Instruments 101 (Feedback Delay) and 102 (Reverb) are global effects, which are not necessary to compute for each individual voice independently. So started once from the score, one instance of each runs constantly whether a note is played or not. The Widget Panel, gives access to some of their parameters. You can add more..
*/

<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

gaOut init 0.0						; a global audio variable is initialised, this can be seen as an "global audio Bus" (g.a.Bus), where audiodata can be send and read from, but first it is NULL

instr 1 						; Sawthooth Oscillator triggered with notes on MIDI CH: 1
icps = p4
iamp = p5/127						; MIDI received velocity (from 0-127), becomes devided by 127 -> amplitude-range is now 0-1 
kFfreq invalue "filter_freq"
kFfreq port kFfreq, 0.05

aSrc oscili iamp, icps, 1				; reads form f-table 1, containing a sawthooth waveform
aFiltered moogvcf aSrc, kFfreq, 0.1			; the source signal becomes low pass filtered
aEnv madsr 0.01, 0.1, 0.9, 0.01			; defining the envelope
gaOut =  (aFiltered*aEnv) + gaOut 			; the signal becomes scaled by the envelope and is added to the "g.a.Bus" 
							; that no information (from other sources, or simultaneous voices) which already exists on the global variable will be lost, itself needs to become added as well
endin

instr 2 						; SIne Oscillator triggered with notes on MIDI CH: 2
icps = p4
iamp = p5/127
aSrc oscili iamp, icps, 2				; this instrument reads from f-table 2, containing a sinus waveform
aEnv madsr 0.01, 0.1, 0.9, 0.01			; madsr is used, now the instrument will be triggered by MIDI notes
gaOut = (aSrc*aEnv) + gaOut
endin


instr 101					 ; Global Feedback Delay
kDryWet invalue "d_w_delay"			; receive values from the Widget Panel
kDelTime invalue "time_delay"
kFeedback invalue "feedb_delay"
aDelay delayr 1					;  a delaylne, with 1 second maximum delay-time is initialised
aWet	deltapi kDelTime				; data at a flexible position is read from the delayline 
	delayw gaOut+(aWet*kFeedback)		; the "g.a.Bus" is written to the delayline, - to get a feedbackdelay, the delaysignal (aWet) is also added, but scaled by kFeedback 
gaOut	= (1-kDryWet) * gaOut + (kDryWet * aWet)	; the amount of pure-signal and delayed-signal is mixed, and written to the "g.a.Bus"
endin

instr 102					 			; Global Reverb
kroomsize init 0.4								; fixed values for reverb-roomsize and damp, but you can add knobs or faders on the Widget Panel and invalue the data here...
khfdamp init  0.8
kDryWet invalue "d_w_reverb"
aWetL, aWetR freeverb gaOut, gaOut, kroomsize, khfdamp		; the freeverb opcode works with stereo input, so we read twice the "g.a.Bus"
aOutL	 = (1-kDryWet) * gaOut + (kDryWet * aWetL)				; the amount of pure-signal (g.a.Bus) and reverbed-signal for the left side is mixed, and written to a local variable
aOutR	 = (1-kDryWet) * gaOut + (kDryWet * aWetR)
outs aOutL, aOutR								; main output of the final signal
gaOut = 0.0									; clear the global audio channel for the next k-loop
endin


</CsInstruments>
<CsScore>
f 1 0 1024 7 0 512 1 0 -1 512 0
f 2 0 1024 10 1
i 101 0 3600						; the delay runs for one hour
i 102 0 3600						; the reverb runs for one hour
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 664 156 410 573
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {46774, 28013, 0}
ioSlider {22, 458} {311, 38} 0.000000 1.000000 0.189711 d_w_reverb
ioText {22, 421} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Reverb Mix
ioSlider {22, 277} {311, 38} 0.000000 1.000000 0.070740 d_w_delay
ioText {22, 240} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Delay Mix
ioSlider {244, 147} {20, 100} 0.050000 1.000000 0.268500 time_delay
ioSlider {313, 148} {20, 100} 0.050000 1.000000 0.525000 feedb_delay
ioText {235, 121} {45, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Time
ioText {294, 121} {57, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Feedback
ioText {22, 116} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border DELAY SECTION
ioText {21, 313} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {294, 315} {37, 27} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {22, 494} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {296, 494} {37, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {20, 381} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border REVERB SECTION
ioText {223, 250} {69, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50-1000 ms
ioText {300, 251} {69, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0-100 %
ioText {19, 44} {273, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Filterfrequency Control for Instr 1
ioText {19, 9} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border SYNTH SECTION
ioSlider {18, 68} {311, 38} 10.000000 5000.000000 1967.491961 filter_freq
</MacGUI>

<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="60" y="304" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>