
<CsoundSynthesizer>
<CsOptions>
-m0 -odac --omacro:PAT=(kt*(kt>>5|kt>>8))>>(kt>>16)
</CsOptions>
<CsInstruments>

sr     = 48000
ksmps  = 6       ; kr = 8kHz
nchnls = 2

;; bytesong.csd by Tito Latini

#define T #0#
#define V #0#

instr 1
 kt init $T
 av init $V
 av = ($PAT) & 255
 asrc = av << 7
 aflt butlp asrc, 3500
 aout dcblock aflt
 kt = kt+1
 outs aout*0.7, aout*0.7
 dispfft aout, 0.05, 2048
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>












<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>21</x>
  <y>16</y>
  <width>528</width>
  <height>220</height>
  <uuid>{e048b15c-0b74-442f-88ee-6406e94c82a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>8.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>25</x>
  <y>248</y>
  <width>523</width>
  <height>227</height>
  <uuid>{14a02a2d-89a0-44ec-943b-fe02308ab41f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
