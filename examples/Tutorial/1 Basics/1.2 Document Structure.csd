/* Getting started.. 1.2 Basic Document Structure

This file explains the "Document Structure". If you press run, you won't hear anything!

A Csound document is structured in four main parts. Each part is opened by <xyz> and closed with </xyz>. Every Csound file starts with the <CsoundSynthesizer> head, and ends with </CsoundSynthesizer>, only text inbetween, will become compiled by Csound.
*/

<CsoundSynthesizer> 	; A CSOUND FILE

<CsOptions> 		; OPTIONS
; If you run Csound from QuteCsound, you can set options in the 'Preferences' menu more comfortable.
; Read more details in the Csound Manual under: 1.Overview->The Csound Command->Comand-line Flags (by Category).
</CsOptions> 		;close OPTIONS


<CsInstruments> 		; INSTRUMENTSECTION
; The instrumentheader section, specifies global options for instrument performance.
sr = 44100 			; the samplerate for audiosignals is set to 44100 Hz (calculations per second)
ksmps = 128 		; is the number of samples per control-block, -> ~345 Hz is the controlrate (sr/ksmps = controlrate HZ) 
nchnls = 2 			; the number of used hardware output channels is set to 2 (stereo)
0dbfs = 1 			; the maximum outputlevel of 0dB is set as value 1, so the volume range is 0-1

; Now you can define your instruments
instr 1 			; first instrument
				; this is empty, so nothing will be played
endin

instr 2 			; second instrument
				; this is also empty, so nothing will be played
endin
</CsInstruments> 		;ends the INSTUMENTSECTION


<CsScore> 			; SCORE
				; timescale information will be set here but here it is empty as well 
e
</CsScore> 			; ends the SCORE
</CsoundSynthesizer> 	; ending of Csoundfile
this will not become compiled :-), so I don't need the comment sign
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 564 163 400 244
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioText {117, 58} {80, 25} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border empty :-)
</MacGUI>

