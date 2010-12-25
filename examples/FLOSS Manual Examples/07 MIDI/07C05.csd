see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>
<CsOptions>
-Ma -odac
</CsOptions>
<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen    0,0,2^12,10,1
         initc7   1,1,1; initialize controller 1 on midi channel 1 to its maximum level

  instr 1
iOct      octmidi; read in midi pitch in Csound's 'oct' format
iAmp      ampmidi 0.1; read in note velocity - re-range to be from 0 to 0.2
kVol      ctrl7   1,1,0,1; read in controller 1, channel 1. Re-range to be from 0 to 1
kPortTime linseg  0,0.001,0.01; create a value that quickly ramps up to 0.01
kVol      portk   kVol, kPortTime; create a new version of kVol that has been filtered (smoothed) using portk
aVol      interp  kVol; create an a-rate version of kVol. Use intepolation to smooth this signal even further
iBndRange =       2; pitch bend range in semitones
imin      =       0; equilibrium position
imax      =       iBndRange * 1/12; max pitch displacement (in oct format)
kPchBnd	  pchbend imin, imax; pitch bend variable (in oct format)
kPchBnd   portk   kPchBnd, kPortTime; create a new version of kPchBnd that has been filtered (smoothed) using portk
aEnv      linsegr 0,0.005,1,0.1,0; amplitude envelope with release stage
kMul      aftouch 0.4,0.85; read in a value that will be used with gbuzz as a kind of tone control
kMul      portk   kMul,kPortTime; create a new version of kPchBnd that has been filtered (smoothed) using portk
aSig      gbuzz   iAmp*aVol*aEnv, cpsoct(iOct+kPchBnd), 70,0,kMul,giSine
          out     aSig
  endin

</CsInstruments>
<CsScore>
f 0 300
e
</CsScore>
<CsoundSynthesizer>
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
