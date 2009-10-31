<CsoundSynthesizer>
<CsOptions>
-n -m0 ; Don't write audio file to disk and don't write messages
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 1
nchnls = 1
0dbfs = 1

gihandle init 0

; By Andres Cabrera 2009

instr 1
; Receive the name from the text box
Sfilename invalue "_Browse1"
; Check duration and sample rate
ilen filelen Sfilename

; Load the audio file to f-table 50
ftfree 50, 0
Sline sprintf {{f 50 0 0 1 "%s" 0 0 1}}, Sfilename
scoreline_i Sline
;outvalue "fb", "Loading file..."

;receive decimation value
kdec invalue "decimation"
; Turn on instrument that clears progress bar
event_i "i", 97, 0, 1
; Turn on processing instrument for approprate time
event_i "i", 98, 5, ilen / i(kdec)
Soutline strcat Sfilename, ".txt"
gihandle fiopen Soutline, 0 ; open text file for writing
; When finished, quit
event_i "i", 100, (ilen/ i(kdec)) + 6, 1
endin

instr 97 ;clear progress bar
outvalue "fb", 0
endin

instr 98 ;traverse the file
kdec invalue "decimation"
kstart invalue "start"
kend invalue "end"
ktype invalue "type"
kindex init 0
kaccum init 0
ilen = nsamp(50)

; Convert time in ms to number of audio samples
kstart = kstart * sr /1000
kend = kend * sr /1000

loopstart:
kindex = kindex + 1
if ((kindex + kstart >= ilen) || (kindex + kstart > kend)) then
	turnoff
endif
kvalue tab kindex + kstart, 50
if (ktype == 0) then ; if peak
	if (kaccum < abs(kvalue)) then
		kaccum = abs(kvalue)
	endif
elseif (ktype == 1) then ; if average
	kaccum = kaccum + kvalue
endif

; Check if kindex is a multiple of kdec
krem = kindex%kdec
if krem != 0 kgoto loopstart ; do loop

if (ktype == 1) then ; if average divide by number of elements
	kaccum = kaccum / kdec
endif

event "i", 99, 0, 1, kaccum
kaccum = 0

outvalue "fb", kindex/(kend-kstart)
endin

instr 99  ;write one value
fouti gihandle, 0, 0, p4
turnoff
endin

instr 100  ;print end message
ficlose gihandle
exitnow
endin


</CsInstruments>
<CsScore>
f 50 0 2 2 0
i 1 0 6

</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 401 221 580 400
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 40349, 41634}
ioText {95, 258} {80, 25} editnum 1000.000000 1.000000 "decimation" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1000.000000
ioText {11, 227} {445, 26} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder /home/andres/Documentos/04 Javeriana/01 Compresores/test-signal-static.wav
ioButton {458, 225} {100, 30} value 1.000000 "_Browse1" "Browse" "/" 
ioButton {188, 296} {375, 61} value 1.000000 "_Render" "Render" "/" 
ioText {10, 198} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File to load
ioText {12, 258} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Decimation
ioText {95, 292} {80, 25} editnum 0.000000 1.000000 "start" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioText {12, 292} {86, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Start time (ms)
ioText {95, 329} {80, 25} editnum 1000.000000 1.000000 "end" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1000.000000
ioText {12, 329} {86, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder End time (ms)
ioMenu {186, 260} {122, 30} 1 303 "peak,average" type
ioMeter {316, 265} {245, 22} {0, 59904, 0} "vert12" 0.000000 "fb" 0.997732 fill 1 0 mouse
ioText {10, 0} {554, 192} display 0.000000 0.00100 "" center "DejaVu Sans" 12 {65280, 43520, 0} {4352, 4096, 3840} background border Â¬This csd file writes the values from an audio file to a text file, from the selected starting time to the selected end time, in blocks of size determined by the decimation value. If decimation is 100, this means that 100 audio samples will write a single value to the text file.Â¬You can select peak to store the sample with greatest absolute value or average to store the average of the set.Â¬To use, select file to process using the Browse button, then press the render button and wait for the progress bar to go completely green.
</MacGUI>

