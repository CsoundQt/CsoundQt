see http://www.flossmanuals.net/csound/ch041_a-record-and-play-soundfiles

<CsoundSynthesizer>

<CsOptions>
-odac
</CsOptions>

<CsInstruments>
;example written by Iain McCurdy

sr 	= 	44100
ksmps 	= 	32
nchnls 	= 	1	

  instr	1; play audio from disk using diskin2 opcode
kSpeed  init     1; playback speed
iSkip   init     0; inskip into file (in seconds)
iLoop   init     0; looping switch (0=off 1=on)
; READ AUDIO FROM DISK
a1      diskin2  "loop.wav", kSpeed, iSkip, iLoop
        out      a1; send audio to outputs
  endin

</CsInstruments>

<CsScore>
i 1 0 6
e
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>630</x>
 <y>260</y>
 <width>380</width>
 <height>205</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>140</g>
  <b>36</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {59110, 35980, 9252}
</MacGUI>
