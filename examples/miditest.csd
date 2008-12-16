<CsoundSynthesizer>
<CsOptions>
-+rtmidi=pmall -Ma
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1
; Based on manual example by schwaheed

massign         0, 0  ; disable triggering of notes
pgmassign       0, 0

instr 1  ;Generate MIDI notes
	xtratim 1
	noteon 1, 60, 100
	kflag release
	if (kflag == 1) then
		noteoff 1, 60, 100
	endif
endin

instr   130

knotelength    init    0
knoteontime    init    0

kstatus, kchan, kdata1, kdata2                  midiin

if (kstatus == 128) then
	knoteofftime    times
	knotelength = (knoteofftime - knoteontime)*1000
	Stext sprintfk "Note Off: chan = %d note#  = %d velocity = %d length = %d", kchan, kdata1,kdata2, knotelength
	outvalue "note", Stext

elseif (kstatus == 144) then
	if (kdata2 == 0) then
		knoteofftime    times
		knotelength = (knoteofftime - knoteontime)*1000
printk2 knotelength
		Stext sprintfk "Note On: chan = %d note#  = %d velocity = %d length = %d", kchan, kdata1, kdata2, knotelength
	else
		Stext sprintfk "Note On: chan = %d note#  = %d velocity = %d", kchan, kdata1, kdata2
		knoteontime    times
	endif
	outvalue "note", Stext

elseif (kstatus == 160) then
	printks "kstatus= %d, kchan = %d, \\tkdata1 = %d, kdata2 = %d \\tPolyphonic Aftertouch\\n", 0, kstatus, kchan, kdata1, kdata2

elseif (kstatus == 176) then
	Stext sprintfk "%d",  kdata1
	outvalue "cc", Stext
	Stext sprintfk "%d",  kdata2
	outvalue "ccvalue", Stext
	Stext sprintfk "%d",  kchan
	outvalue "channel", Stext

elseif (kstatus == 192) then
	printks "kstatus= %d, kchan = %d, \\tkdata1 = %d, kdata2 = %d \\tProgram Change\\n", 0, kstatus, kchan, kdata1, kdata2

elseif (kstatus == 208) then
	printks  "kstatus= %d, kchan = %d, \\tkdata1 = %d, kdata2 = %d \\tChannel Aftertouch\\n", 0, kstatus, kchan, kdata1, kdata2

elseif (kstatus == 224) then
	printks "kstatus= %d, kchan = %d, \\t ( data1 , kdata2 ) = ( %d, %d )\\tPitch Bend\\n", 0, kstatus, kchan, kdata1, kdata2
endif

kcontinuous invalue "continuous"
if (kcontinuous == 1) then
	ktrigger metro 1
	schedkwhen  ktrigger, 0.2, 2, 1, 0, 0.5
endif

endin


</CsInstruments>
<CsScore>

i130 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 658 191 417 232
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {0, 41891, 41891}
ioText {5, 30} {379, 36} label 0.000000 0.00100 "note" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Note On: chan = 0 note# = 0 velocity = 0
ioText {5, 2} {379, 60} label 0.000000 0.00100 "" left "Courier 10 Pitch" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border Note events:
ioText {5, 80} {184, 116} label 0.000000 0.00100 "" left "Courier 10 Pitch" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border Control Change:
ioText {131, 110} {40, 25} display 0.000000 0.00100 "cc" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} background border 0
ioText {131, 135} {40, 25} display 0.000000 0.00100 "ccvalue" left "DejaVu Sans" 12 {0, 0, 0} {61440, 56320, 58624} background border 0
ioText {131, 160} {40, 25} display 0.000000 0.00100 "channel" left "DejaVu Sans" 12 {0, 0, 0} {56320, 55552, 65280} background border 0
ioButton {202, 84} {179, 26} event 1.000000 "button1" "Generate note" "/" i1 0 0.5
ioCheckbox {206, 122} {20, 20} off continuous
ioText {224, 117} {164, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Generate continuously
ioText {5, 113} {125, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Controller number CC#
ioText {20, 138} {110, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Value
ioText {34, 162} {96, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Channel
</MacGUI>

