see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>

<CsOptions> 
-odac ;activates real time sound output 
</CsOptions>

<CsInstruments> ;Example by Iain McCurdy

sr =  44100  
ksmps = 32 
nchnls = 2 
0dbfs = 1   

instr 1 ;sound generating instrument (sparse noise bursts) 
kEnv         loopseg   0.5,0, 0,1,0.003,1,0.0001,0,0.9969,0; amplitude envelope: a repeating pulse 
aSig         pinkish   kEnv; pink noise. pulse envelope applied
             outs      aSig, aSig; send audio to outputs 
iRvbSendAmt  =         0.4; reverb send amount (try range 0 - 1) 
             chnmix    aSig*iRvbSendAmt, "ReverbSend" ;write audio into the named software channel
endin   

instr 5; reverb - always on 
aInSig       chnget    "ReverbSend"; read audio from the named software channel  
kTime        init      4; reverb time 
kHDif        init      0.5; 'high frequency diffusion' - control of a filter within the feedback loop 0=no damping 1=maximum damping 
aRvb         nreverb   aInSig, kTime, kHDif; create reverberated version of input signal (note stereo input and output)             
             outs      aRvb, aRvb; send audio to outputs 
             chnclear  "ReverbSend"; clear the named channel   
endin 

</CsInstruments> 

<CsScore> 
i 1 0 10; noise pulses (input sound) 
i 5 0 12; start reverb 
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
