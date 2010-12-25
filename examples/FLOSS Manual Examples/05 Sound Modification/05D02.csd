see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>

<CsOptions>
-odac ;activates real time sound output
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen   0, 0, 2^12, 10, 1; a sine wave

  instr 1
; create an input signal
kEnv    loopseg  0.5, 0, 0, 0,0.0005, 1 , 0.1, 0, 1.9, 0; repeating envelope
kCps    randomh  400, 600, 0.5; 'held' random values
aEnv    interp   kEnv; interpolate kEnv to create a-rate version
aSig    poscil   aEnv, kCps, giSine; generate audio

; create a delay buffer
iFdback =        0.5; this value defines the amount of delayed signal fed back into the delay buffer
aBufOut delayr   0.3; read audio from end of 0.3s buffer
        delayw   aSig + (aBufOut*iFdback); write audio into buffer (mix in feedback signal)

; send audio to ther output (mix the input signal with the delayed signal)
        out      aSig + (aBufOut*0.2)
  endin


</CsInstruments>

<CsScore>
i 1 0 25
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
