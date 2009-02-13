<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	kfreq invalue "freq"

	outvalue "freq", kfreq
	ainput inch 1
	krms rms ainput
	outvalue "rms", krms
	
	alow butlp  ainput, kfreq
	krmslow rms alow
	outvalue "low", krmslow
	
	ahi buthp  ainput, kfreq
	krmshi rms ahi
	outvalue "hi", krmshi
endin

</CsInstruments>
<CsScore>
i 1 0 9600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 624 262 256 214
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {50115, 50886, 51143}
ioText {100, 5} {140, 100} label 0.000000 0.00100 "chann" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Rms values for the complete signal and for two separate parts of the spectrum. Use the knob to select crossover frequency
ioMeter {5, 5} {30, 150} {59904, 18176, 32768} "rms" 0.000032 "" 0.000000 fill 1 0 mouse
ioText {5, 155} {40, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Rms
ioMeter {45, 5} {15, 150} {43520, 21760, 65280} "low" 0.000019 "" 0.000000 fill 1 0 mouse
ioMeter {75, 5} {15, 150} {59904, 58624, 16128} "hi" 0.000026 "" 0.000000 fill 1 0 mouse
ioText {45, 155} {25, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Lo
ioText {75, 155} {25, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hi
ioKnob {100, 110} {50, 50} 100.000000 1000.000000 0.010000 600.000000 freq
ioText {100, 155} {60, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Crossover
ioText {160, 120} {80, 25} display 0.000000 0.00100 "freq" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} background border 600.0000
</MacGUI>

