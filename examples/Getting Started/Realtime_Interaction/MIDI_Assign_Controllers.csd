/*Getting started.. Realtime Interaction: MIDI Assign Controllers

In the example below, instrument 100 (which is "always on") receives the MIDI control data and sends it as global k-variables (gk...). You can choose the MIDI channel number and the controller numbers via the spinboxes in the widget panel. You can even change these numbers during the performance. As they are i-values, the opcodes 'reinit' and 'rireturn' are used to put the changes into force (for another examples, see Examples->Reinit_Example).

In comparison to the example before, the sliders are not 'invalue'-ed to the instruments, so the only way to control the synth is via MIDI-CC's. The GUI is just for displaying, so 'outvalue' is used to send the CC-values to the Widget GUI. 

All the note-on-/note-off-messages must be sent on MIDI channel 1 (or you have to change the massign statement in the orchestra header). The statement massign 1, 101 sends all these messages to instrument 101. Each note here is added to the global audio variable -gaOut-.

Instrument 102 adds the global feedback delay and the reverb, and finally zeros the -gaOut- variable for the next k-cycle.
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

gaOut init 0.0
massign 1, 101		; assign all incoming midi from midi-chn 1 (= keyboard) to instr 101 (Sawthooth Oscillator)


instr 100; MIDI CONTROLLER RECEIVE INSTRUMENT
; Get information for MIDI Channel and Controller Numbers from the Widget Panel
	kMidiChn_slider invalue "#midichn_slider"							; receive midi channel for the sliders
	kCtrlNo_filt_freq invalue "ctrl#filt_freq"							; receive controller number for filter frequency
	kCtrlNo_DelTime invalue "ctrl#_time_delay"							; receive controller number for delay time
	kCtrlNo_Feedback invalue "ctrl#_feedb_delay"						; receive controller number for delay time
	kCtrlNo_d_w_delay invalue "ctrl#_d_w_delay"						; receive controller number for delay wet-dry-mix
	kCtrlNo_d_w_reverb invalue "ctrl#_d_w_reverb"						; receive controller number for reverb wet-dry-mix
; Receive Values from the MIDI Sliders as global k-Variables
midivalues: ;begin of a possible reinit section
	gkFilterCC1 ctrl7 i(kMidiChn_slider), i(kCtrlNo_filt_freq), 10, 5000				; read 7-bit MIDI CC data and map to a range between 10-5000 
	gkDelTime ctrl7 i(kMidiChn_slider), i(kCtrlNo_DelTime), 0.05, 1
	gkFeedback ctrl7 i(kMidiChn_slider), i(kCtrlNo_Feedback), 0.05, 1
	gkDryWetDelay ctrl7 i(kMidiChn_slider), i(kCtrlNo_d_w_delay), 0, 1
	gkDryWetReverb ctrl7 i(kMidiChn_slider), i(kCtrlNo_d_w_reverb), 0, 1
rireturn; end of a possible reinit section

; Reinit the label "midivalues" only, when a MIDI Channel or any of the CC Number assignments  have changed
kchanged changed kMidiChn_slider, kCtrlNo_filt_freq, kCtrlNo_DelTime, kCtrlNo_Feedback, kCtrlNo_d_w_delay, kCtrlNo_d_w_reverb
	if kchanged == 1 then
		reinit midivalues
	endif
; Send the MIDI-Values to the Widget Panel
outvalue "filter_freq", gkFilterCC1
outvalue "feedb_delay", gkFeedback
outvalue "d_w_delay", gkDryWetDelay
outvalue "time_delay", gkDelTime
outvalue "d_w_reverb", gkDryWetReverb
endin

instr 101	; Sawthooth Oscillator triggered with notes on MIDI CH: 1
icps = p4
iamp = p5/127
kFfreq port gkFilterCC1, 0.05
aSrc oscili iamp, icps, 1
aFiltered moogvcf aSrc, kFfreq, 0.1
aEnv madsr 0.01, 0.1, 0.9, 0.01
gaOut = gaOut + aFiltered*aEnv
endin

instr 102; Global Feedback Delay and Reverb
; DELAY Section
kDelTime port gkDelTime, 0.05
aDelTime = a(kDelTime)
aDelay delayr 1
aWet	deltapi aDelTime
	delayw gaOut+(aWet*gkFeedback)
gaOut		=	(1-gkDryWetDelay) * gaOut + (gkDryWetDelay * aWet)

; REVERB Section
kroomsize init 0.4
khfdamp init  0.8
aWetL, aWetR freeverb gaOut, gaOut, kroomsize, khfdamp
aOutL	= (1-gkDryWetReverb) * gaOut + (gkDryWetReverb * aWetL)
aOutR	= (1-gkDryWetReverb) * gaOut + (gkDryWetReverb * aWetR)
outs aOutL, aOutR
gaOut = 0.0
endin

</CsInstruments>
<CsScore>
f 1 0 256 7 0 128 1 0 -1 128 0
i 100 0 3600					; the MIDI CCs will be received  for one hour
i 102 0 3600					; feedback-delay and reverb run for one hour
e
</CsScore>
</CsoundSynthesizer>
; written by Joachim Heintz & Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 305 204 866 678
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {46774, 28013, 0}
ioSlider {22, 555} {311, 38} 0.000000 1.000000 0.000000 d_w_reverb
ioText {22, 518} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Reverb Mix
ioSlider {22, 374} {311, 38} 0.000000 1.000000 0.000000 d_w_delay
ioText {22, 337} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Delay Mix
ioSlider {244, 244} {20, 100} 0.050000 1.000000 0.601000 time_delay
ioSlider {313, 245} {20, 100} 0.050000 1.000000 0.050000 feedb_delay
ioText {235, 218} {45, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Time
ioText {294, 218} {57, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Feedback
ioText {22, 213} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border DELAY SECTION
ioText {21, 410} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {294, 412} {37, 27} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {22, 591} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {296, 591} {37, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {20, 478} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border REVERB SECTION
ioText {223, 347} {69, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50-1000 ms
ioText {300, 348} {69, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0-100 %
ioText {19, 141} {273, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LP-Filter Cutoff-frequency
ioText {20, 107} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border SYNTH SECTION
ioSlider {18, 165} {311, 38} 10.000000 5000.000000 1454.051447 filter_freq
ioText {382, 107} {319, 64} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border CONTROLLER NUMBERS FOR THE DIFFERENT SLIDERS
ioText {513, 178} {54, 27} editnum 1.000000 1.000000 "ctrl#filt_freq" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {333, 169} {169, 35} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ---------->
ioText {513, 257} {54, 27} editnum 21.000000 1.000000 "ctrl#_time_delay" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21.000000
ioText {278, 252} {221, 36} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ---------------->
ioText {513, 312} {54, 27} editnum 3.000000 1.000000 "ctrl#_feedb_delay" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {342, 304} {162, 39} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ---------->
ioText {513, 385} {54, 27} editnum 4.000000 1.000000 "ctrl#_d_w_delay" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioText {338, 376} {169, 35} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ---------->
ioText {513, 565} {54, 27} editnum 6.000000 1.000000 "ctrl#_d_w_reverb" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6.000000
ioText {339, 556} {169, 35} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ---------->
ioText {404, 6} {267, 64} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border CHANNEL NUMBER FOR ALL SLIDERS
ioText {17, 7} {304, 64} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border MIDI KEYBOARD MUST SEND ON MIDI CHANNEL 1!
ioText {511, 76} {54, 27} editnum 1.000000 1.000000 "#midichn_slider" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {4, 70} {335, 23} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (or you must change the massign statement in the orc header)
</MacGUI>

<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="410" y="239" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>