see http://www.flossmanuals.net/csound/ch035_e-reverberation

<CsoundSynthesizer>

<CsOptions>
-odac ;activates real time sound output
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr =  44100 
ksmps = 1
nchnls = 2
0dbfs = 1

giSine       ftgen       0, 0, 2^12, 10, 1 ;a sine wave
gaRvbSend    init        0; global audio variable initialized to zero
giRvbSendAmt init        0.4; reverb send amount (try range 0 - 1)

  instr 1 ;trigger drum hits
ktrigger    metro       5; rate of drum strikes
kdrum       random      2, 4.999; randomly choose drum to strike
            schedkwhen  ktrigger, 0, 0, kdrum, 0, 0.1; strike a drum
  endin

  instr 2; sound 1 - bass drum
iamp        random      0, 0.5; amplitude randomly chosen from between the given values
p3          =           0.2; define duration for this sound
aenv        line        1,p3,0.001; amplitude envelope - percussive decay
icps        exprand     30; cycles-per-second offset randomly chosen from an exponential distribution
kcps        expon       icps+120,p3,20; pitch glissando
aSig        oscil       aenv*0.5*iamp, kcps, giSine; oscillator
            outs        aSig, aSig; send audio to outputs
gaRvbSend   =           gaRvbSend + (aSig * giRvbSendAmt); add portion of signal to global reverb send audio variable
  endin

  instr 3; sound 3 - snare
iAmp        random      0, 0.5; amplitude randomly chosen from between the given values
p3          =           0.3; define duration for this sound
aEnv        expon       1, p3, 0.001; amplitude envelope - percussive decay
aNse        noise       1, 0; create noise component for snare drum sound   
iCps        exprand     20; cycles-per-second offset randomly chosen from an exponential distribution
kCps        expon       250 + iCps, p3, 200+iCps; create tone component frequency glissando for snare drum sound
aJit        randomi     0.2, 1.8, 10000; jitter on frequency for tone component
aTne        oscil       aEnv, kCps*aJit, giSine; create tone component
aSig        sum         aNse*0.1, aTne; mix noise and tone sound components
aRes        comb        aSig, 0.02, 0.0035; pass signal through a comb filter to create static harmonic resonance
aSig        =           aRes * aEnv * iAmp; apply envelope and amplitude factor to sound
            outs        aSig, aSig; send audio to outputs
gaRvbSend   =           gaRvbSend + (aSig * giRvbSendAmt); add portion of signal to global reverb send audio variable
  endin

  instr 4; sound 4 - closed hi-hat
iAmp        random      0, 1.5; amplitude randomly chosen from between the given values
p3          =           0.1; define duration for this sound
aEnv        expon       1,p3,0.001; amplitude envelope - percussive decay
aSig        noise       aEnv, 0; create sound for closed hi-hat
aSig        buthp       aSig*0.5*iAmp, 12000; highpass filter sound
aSig        buthp       aSig,          12000; highpass filter sound again to sharpen cutoff
            outs        aSig, aSig; send audio to outputs
gaRvbSend   =           gaRvbSend + (aSig * giRvbSendAmt); add portion of signal to global reverb send audio variable
  endin


  instr 5; schroeder reverb - always on

; read in variables from the score
kRvt        =           p4
kMix        =           p5

; print some information about current settings gleaned from the score
            prints      "Type:"
            prints      p6
            prints      "\\nReverb Time:%2.1f\\nDry/Wet Mix:%2.1f\\n\\n",p4,p5

; four parallel comb filters       
a1          comb        gaRvbSend, kRvt, 0.0297; comb filter 1
a2          comb        gaRvbSend, kRvt, 0.0371; comb filter 2
a3          comb        gaRvbSend, kRvt, 0.0411; comb filter 3
a4          comb        gaRvbSend, kRvt, 0.0437; comb filter 4
asum        sum         a1,a2,a3,a4; sum (mix) the outputs of all 4 comb filters

; two allpass filters in series
a5          alpass      asum, 0.1, 0.005; send comb filter mix through first allpass filter
aOut        alpass      a5, 0.1, 0.02291; send comb filter mix through second allpass filter

amix        ntrpol      gaRvbSend, aOut, kMix; create a dry/wet mix between the dry and the reverberated signal
            outs        amix, amix; send audio to outputs
            clear       gaRvbSend   ;clear global audio variables
  endin

</CsInstruments>

<CsScore>
; room reverb
i 1  0 10; start drum machine trigger instr
i 5  0 11 1 0.5 "Room Reverb"; start reverb

; tight ambience
i 1 11 10; start drum machine trigger instr
i 5 11 11 0.3 0.9 "Tight Ambience"; start reverb

; long reverb (low in the mix)
i 1 22 10; start drum machine trigger instr
i 5 22 15 5 0.1 "Long Reverb (Low In the Mix)"; start reverb

; very long reverb (high in the mix)
i 1 37 10; start drum machine trigger instr
i 5 37 25 8 0.9 "Very Long Reverb (High in the Mix)"; start reverb
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
