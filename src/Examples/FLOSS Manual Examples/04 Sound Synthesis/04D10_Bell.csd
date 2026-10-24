<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr bell_like
  kCarFreq = 200  ; 200/280 = 5:7 -> inharmonic spectrum
  kModFreq = 280
  kIndex = 12
  kIndexM = 0
  kMaxDev = kIndex*kModFreq
  kMinDev = kIndexM * kModFreq
  kVarDev = kMaxDev-kMinDev
  aEnv = expseg(.001, 0.001, 1, 0.3, 0.5, 8.5, .001)
  aModAmp = kMinDev+kVarDev*aEnv
  aModulator = poscil(aModAmp, kModFreq)
  aCarrier = poscil(0.3*aEnv, kCarFreq+aModulator)
  out(aCarrier, aCarrier)
endin

</CsInstruments>
<CsScore>
i "bell_like" 0 9
</CsScore>
</CsoundSynthesizer>
;example by Alex Hofmann
<bsbPanel>
 <label/>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>53</r>
  <g>53</g>
  <b>53</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
