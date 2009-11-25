/* Getting started.. 1.2 Basic Document Structure

This file explains the "Document Structure". If you press run, you won't hear anything!

A Csound document is structured in four main sections. Each sections is opened with a <xyz> tag and closed with </xyz> tag. Every Csound file starts with a <CsoundSynthesizer> tag, and ends with </CsoundSynthesizer>, only text that is inbetween, will be compiled by Csound.
*/

<CsoundSynthesizer> 	; START OF A CSOUND FILE

<CsOptions> 		; OPTIONS
; If you run Csound from QuteCsound, you can set options in the 'Preferences' menu more comfortably.
; Read more details in the Csound Manual under: 1.Overview->The Csound Command->Comand-line Flags (by Category).
</CsOptions> 		;close OPTIONS


<CsInstruments> 		; INSTRUMENT SECTION
; The instrumentheader section, specifies global options for instrument performance.
sr = 44100 			; the samplerate for audiosignals is set to 44100 Hz (calculations per second)
ksmps = 128 		; is the number of samples per control-block, -> ~345 Hz is the controlrate (sr/ksmps = controlrate HZ) 
nchnls = 2 			; the number of output channels is set to 2 (stereo)
0dbfs = 1 			; the maximum output level before clipping (0dB FS) is set to 1, so the amplitude range is 0-1

; Now you can define your instruments
instr 1 			; first instrument
				; this is empty, so nothing will be played
endin

instr 2 			; second instrument
				; this is also empty, so nothing will be played
endin
</CsInstruments> 		;ends the INSTUMENT SECTION


<CsScore> 			; SCORE
				; instruments will be triggered here but this is empty as well
e
</CsScore> 			; ends the SCORE
</CsoundSynthesizer> 	; ending of CSOUND FILE
this will not become compiled :-), so I don't need the comment sign
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 974 367 200 140
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioText {51, 30} {80, 25} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border empty :-)
</MacGUI>

