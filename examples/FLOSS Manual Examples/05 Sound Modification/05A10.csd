see http://www.flossmanuals.net/csound/ch031_a-envelopes

<CsoundSynthesizer>

<CsOptions>
-odac ;activates real time sound output
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 4
nchnls = 1
0dbfs = 1

seed 0; seed random number generators from system clock

  instr 1; Bassline instrument
kTempo    =            90; tempo in beats per second
kCfBase   randomi      1,4,0.2; base filter cutoff frequency described in octaves above the current pitch. Values should be greater than 0 up to about 8
kCfEnv    randomi      0,4,0.2; filter envelope depth. Values probably in the range 0 - 4 although negative numbers could be used for special effects
kRes      randomi      0.5,0.9,0.2; filter resonance. Suggested range 0 - 0.99
kVol      =            0.5; volume control. Suggested range 0 - 1
kDecay    randomi      -10,10,0.2; decay shape of the filter. Suggested range -10 to +10. Zero=linear, negative=increasingly_concave, positive=increasingly_convex
kWaveform =            0;waveform of the audio oscillator. 0=sawtooth 2=square
kDist     randomi      0,0.8,0.1; amount of distortion. Suggested range 0 - 1
;read in phrase event widgets - use a macro to save typing
kPhFreq   =            kTempo/240; frequency with which to repeat the entire phrase
kBtFreq   =            (kTempo)/15; frequency of each 1/16th note
;                                         the first value of each pair defines the relative duration of that segment (just leave these as they are unless you want to create quirky rhythmic variations)
;                                         the second, the value itself. Note numbers (kNum) are defined as MIDI note numbers. Note On/Off (kOn) and hold (kHold) are defined as on/off switches, 1 or zero
;envelopes with held segments        note:1         2         3         4         5         6         7         8         9         10         11         12         13         14         15         16           DUMMY
kNum      lpshold      kPhFreq, 0,        0,40,     1,42,     1,50,     1,49,     1,60,     1,54,     1,39,     1,40,     1,46,     1,36,      1,40,      1,46,      1,50,      1,56,      1,44,      1,47,        1,45; need an extra 'dummy' value
kOn       lpshold      kPhFreq, 0,        0,1,      1,1,      1,1,      1,1,      1,1,      1,1,      1,0,      1,1,      1,1,      1,1,       1,1,       1,1,       1,1,       1,1,       1,0,       1,1,         1,1
kHold     lpshold      kPhFreq, 0,        0,0,      1,1,      1,1,      1,0,      1,0,      1,0,      1,0,      1,1,      1,0,      1,0,       1,1,       1,1,       1,1,       1,1,       1,0,       1,0,         1,0; need an extra 'dummy' value

kHold     vdel_k       kHold, 1/kBtFreq, 1; offset hold by 1/2 note duration
kNum      portk        kNum, (0.01*kHold); apply portamento to pitch changes - if note is not held, no portamento will be applied
kCps      =            cpsmidinn(kNum)
kOct      =            octcps(kCps)
; amplitude envelope
;                                         attack     sustain        decay      gap
kAmpEnv   loopseg      kBtFreq, 0,   0,   0,0.1,  1, 55/kTempo, 1,  0.1,0,  5/kTempo,0 ; sustain segment duration (and therefore attack and decay segment durations) are dependent upon tempo
kAmpEnv   =            (kHold=0?kAmpEnv:1); if hold is off, use amplitude envelope, otherwise use constant value
; filter envelope
kCfOct    looptseg      kBtFreq, 0, 0, kCfBase+kCfEnv+kOct, kDecay, 1, kCfBase+kOct
kCfOct    =             (kHold=0?kCfOct:kCfBase+kOct); if hold is off, use filter envelope, otherwise use steady state value
kCfOct    limit        kCfOct, 4, 14; limit the cutoff frequency to be within sensible limits
;kCfOct    port         kCfOct, 0.05; smooth the cutoff frequency envelope with portamento
kWavTrig  changed      kWaveform; generate a 'bang' if waveform selector changes
 if kWavTrig=1 then; if a 'bang' has been generated...
reinit REINIT_VCO; begin a reinitialization pass from the label 'REINIT_VCO'
 endif
REINIT_VCO:; a label
aSig      vco2         0.4, kCps, i(kWaveform)*2, 0.5; generate audio using VCO oscillator
rireturn; return from initialization pass to performance passes
aSig      moogladder   aSig, cpsoct(kCfOct), kRes; filter audio
;aSig      moogvcf   aSig, cpsoct(kCfOct), kRes ;use moogvcf is CPU is struggling with moogladder
; distortion
iSclLimit ftgentmp     0, 0, 1024, -16, 1, 1024,  -8, 0.01; rescaling curve for clip 'limit' parameter
iSclGain  ftgentmp     0, 0, 1024, -16, 1, 1024,   4, 10; rescaling curve for gain compensation
kLimit    table        kDist, iSclLimit, 1; read Limit value from rescaling curve
kGain     table        kDist, iSclGain, 1;  read Gain value from rescaling curve
kTrigDist changed      kLimit; if limit value changes generate a 'bang'
 if kTrigDist=1 then; if a 'bang' has been generated...
reinit REINIT_CLIP; begin a reinitialization pass from label 'REINIT_CLIP'
 endif
REINIT_CLIP:
aSig      clip         aSig, 0, i(kLimit); clip distort audio signal
rireturn
aSig      =            aSig * kGain; compensate for gain loss from 'clip' processing
kOn       port         kOn, 0.006
          out          aSig * kAmpEnv * kVol * kOn; audio sent to output, apply amp. envelope, volume control and note On/Off status
  endin

</CsInstruments>

<CsScore>
i 1 0 3600
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
