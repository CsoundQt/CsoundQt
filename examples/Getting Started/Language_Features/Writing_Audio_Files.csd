/* Getting started.. File Output

Now we are going to write an audiofile to hardisk. The easiest way, is pressing the red "Record" button in the menu-bar.

But when automating the process (eg. for sound-installations), it is useful to trigger the process from Csound and give each recorded file a unique name. In this case date and time fits best.
The date information is stored into a stringvariable. This string becomes included into the file name. 

Make sure you save this file first to a known location, as the audio file will be created in the same directory as the running file, and if you haven't saved the example, this could be anywhere!

Manipulation of strings, see in manual: -> Opcodes Overview -> Strings ( StringsTop )
*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

instr 1
; generate a testtone
	iAmp = 10000
	kFreq line p4, 3, p5
	asig poscil3 iAmp, kFreq, 1
	out asig
; prepare writing the audiofile with it's unique name
Sdate dates -1					; Returns date and time as a string but including the weekday
; extract useful information from the string
 Stime strsub Sdate, 10, 19			; cut the time information
	Shour strsub Stime, 1, 3
	Smin strsub Stime, 4, 6
	Ssec strsub Stime, 7, 9
 Syear strsub Sdate, 19, 24			; cut the year information
 Sday strsub Sdate, 8, 10			; cut the day information
 Smonth strsub Sdate, 4, 7			; cut the month information
SfileName sprintf "%s-%s-%s-%s_%s_%s-sweep.aiff", Syear, Smonth, Sday, Shour, Smin, Ssec  ; create a unique filename as stringvariable
puts SfileName, 1					; output the filename to the console for checking
fout SfileName, 2, asig			; write the audio-file to disk
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1

i 1 0 1 200 500
i 1 3 1 1000 800
i 1 5 1 500 700
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 1078 327 359 167
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView background {65535, 65535, 65535}
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>