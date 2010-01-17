/*Getting started.. Realtime Interaction: MIDI Controller 01 (Modulation)

The quickest way to control instruments with MIDI control-data (Modulation, Aftertouch, etc.) can be set up, by using 'ctrl7' opcode. It can be used  directly in an instrument definition, and outputs the desired k-rate data. 
..
kMidiCC ctrl7 1, 1, 10, 5000   	; read 7-bit MIDI CC data from Ch.1, CC 01, and map to a range between 10-5000 
aSrc oscili 0.8, kMidiCC, 1	; now CC 01 controlls the frequency of this oscillator
..
The disadvantage of that method is, that you have no communication with the Widget-GUI.

In the example below, a sperate instrument (100) is built to receive the MIDI CC 01 (Modulation) constantly and send it's values to the userchannel "filter_freq". 
In Instrument 101 the data from this userchannel is read-out and mapped to the filters frequency input. 

By sending MIDI-Data on Ch.1 / CC01 (with your keyboards modualtion wheel, or any other MIDI faderbox) you see the Widget-fader moving and can hear the filter adjustments in realtime, when playing a note. Adjusting the fader with the mouse is also still possible.
*/

<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 256
nchnls = 2
0dbfs = 1

massign 1, 101				; send notes on MIDI Ch.1 to instr 101
gaOut init 0.0

instr 100				; MIDI Controller Receive Instrument
kFilterCC1 ctrl7 1, 1, 10, 5000		; read 7-bit MIDI CC data from Ch.1, CC1, and map to a range between 10-5000 
printk2 kFilterCC1				; print the value to the console
kChanged changed kFilterCC1		; check if new values are incoming
if kChanged == 1 then			; so if, update the chanel..
	outvalue "filter_freq", kFilterCC1	; send the value to the widgetpanel
endif
endin


instr 101  				; Sawthooth Oscillator triggered by notes on MIDI CH: 1
icps = p4
iamp = p5/127
kFfreq invalue "filter_freq"
kFfreq port kFfreq, 0.05
aSrc oscili iamp, icps, 1
aFiltered moogvcf aSrc, kFfreq, 0.1
aEnv madsr 0.01, 0.1, 0.9, 0.01
gaOut = gaOut + aFiltered*aEnv
endin

instr 102 				; Global Feedback Delay
kDryWet invalue "d_w_delay"
kDelTime invalue "time_delay"
kFeedback invalue "feedb_delay"
kDelTime port kDelTime, 0.05
aDelTime = a(kDelTime)
aDelay delayr 1
aWet	deltapi aDelTime
	delayw gaOut+(aWet*kFeedback)
gaOut		=	(1-kDryWet) * gaOut + (kDryWet * aWet)
endin

instr 103 				; Global Reverb
kroomsize init 0.4
khfdamp init  0.8
kDryWet invalue "d_w_reverb"
aWetL, aWetR freeverb gaOut, gaOut, kroomsize, khfdamp
aOutL	= (1-kDryWet) * gaOut + (kDryWet * aWetL)
aOutR	= (1-kDryWet) * gaOut + (kDryWet * aWetR)
outs aOutL, aOutR
gaOut = 0.0
endin



</CsInstruments>
<CsScore>
f 1 0 256 7 0 128 1 0 -1 128 0
i 100 0 3600					; the MIDI CC 01will become received  for one hour
i 102 0 3600					; the delay runs for one hour
i 103 0 3600					; the reverb runs for one hour				
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
WindowBounds: 664 149 468 564
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {46811, 28108, 0}
ioSlider {22, 458} {311, 38} 0.000000 1.000000 0.244373 d_w_reverb
ioText {22, 421} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Reverb Mix
ioSlider {22, 277} {311, 38} 0.000000 1.000000 0.257235 d_w_delay
ioText {22, 240} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Delay Mix
ioSlider {244, 147} {20, 100} 0.050000 1.000000 0.420500 time_delay
ioSlider {313, 148} {20, 100} 0.050000 1.000000 0.316000 feedb_delay
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
ioText {19, 44} {273, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Filterfrequency Control with CC 01 (Modulation)
ioText {20, 10} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border SYNTH SECTION
ioSlider {18, 68} {311, 38} 10.000000 5000.000000 2320.482315 filter_freq
</MacGUI>


<EventPanel tempo="60.00000000" name="Events" x="383" y="237" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
</EventPanel>
