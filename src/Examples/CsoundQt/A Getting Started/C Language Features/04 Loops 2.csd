/* Getting started..  Control structures

Let's add tones, the same way, as we've put T-Shirts into the bag!

*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr     = 44100
ksmps  = 64
nchnls = 2
0dbfs  = 1

seed 0  ; makes the random choice each time different

instr 100  ; Oscillator
  irand = random(0, p4)
  kEnv  = madsr(0.1, 0.1, 0.9, 0.1)
  ; Sine-Osc, producing random freqs between 440 and 1760 hz
  a1 = oscils(0.1, 440*(2^(irand/12)), 0)
  out(a1*kEnv, a1*kEnv)
endin

; A range loop, counting from 1 to 5 (the end is inclusive)..
instr 1
  iLimit = p4
  for idx in [1 ... 5] do
    event_i "i", 100, 0, 1, iLimit  ; this generates a scoreline from the instrument..
    prints  "Instance of instr 100 by loop1_%d created!\n", idx
  od
endin

; The same five iterations, with the range starting at zero..
instr 2
  iLimit = p4
  for idx in [0 ... 4] do
    event_i "i", 100, 0, 1, iLimit  ; this generates a scoreline from the instrument..
    prints  "Instance of instr 100 by loop2_%d created!\n", idx+1
  od
endin
</CsInstruments>

<CsScore>
i 1 0 2 24
i 2 3 2 24
i 2 5 2 12
i 2 7 2 2
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 



<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>24</x>
  <y>26</y>
  <width>350</width>
  <height>150</height>
  <uuid>{bd0a0ae1-2149-4248-82ce-26a3860e190b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>TriggerUp</triggermode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
