<CsoundSynthesizer>
<CsOptions>
;Linux options with JACK
;-d -odac:system:playback_ -+rtaudio=jack

;OSX options
;-odac -d -b 128 -B 128
</CsOptions>
<CsInstruments>
/*
Basic Monome Patch in Csound
By Paul Batchelor

Monomeserial must be started first before running the csd with all the default
ports and "monome" hostname. 

Tested on Slackware Linux 13.37 in the Spring of 2013

*/
sr = 96000
ksmps = 1
nchnls = 2
0dbfs = 1

gihandle OSCinit 8000
gisine ftgen 0, 0, 4096, 10, 1
gadel init 0

instr OSC_listen
kx 		init 	0
ky 		init 	0
ks 		init 	0


nxtmsg:
	kk OSClisten gihandle, "/monome/press", "iii", kx, ky, ks
if (kk == 0) goto ex
	event "i", "LED", 0, 0.001, kx, ky, ks
	if (ks == 1) then
		event "i", 1, 0, 0.4, kx, ky, ks
	endif
	kgoto nxtmsg
ex:

endin

instr LED
OSCsend 1, "localhost", 8080, "/monome/led", "iii", p4, p5, p6
endin

instr 1
ix 		= 		p4
iy 		= 		p5
is 		= 		p6

icps 	= 		cpsmidinn(60 + 2 * ix + iy)

kenv 	expseg 	1, p3, 0.00001

a1 		foscili 	0.4 * kenv, icps, 2, 3, 3 * kenv, gisine
		outs 	a1, a1
gadel 	= 		gadel + a1
endin

instr delay
adel 	init 	0
adel 	delay 	gadel + (adel * 0.3), 0.3
adel 	butlp 	adel, 4000
		outs 	adel, adel
gadel 	= 		0
endin

</CsInstruments>
<CsScore>
i"OSC_listen" 0 1500
i"delay" 0 1500
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
