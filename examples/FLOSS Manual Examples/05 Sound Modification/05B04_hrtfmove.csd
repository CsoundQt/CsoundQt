<CsoundSynthesizer>

<CsOptions>
-odac ; activates real time sound output
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 10
nchnls = 2
0dbfs = 1

giSine         ftgen       0, 0, 2^12, 10, 1             ; sine wave
giLFOShape     ftgen       0, 0, 131072, 19, 0.5,1,180,1 ; U-shape parabola

  instr 1
; create an audio signal (noise impulses)
krate          oscil       30,0.2,giLFOShape            ; rate of impulses
; amplitude envelope: a repeating pulse
kEnv           loopseg     krate+3,0, 0,1, 0.05,0, 0.95,0,0
aSig           pinkish     kEnv                             ; noise pulses

; -- apply binaural 3d processing --
; azimuth (direction in the horizontal plane)
kAz            linseg      0, 8, 360
; elevation (held horizontal for 8 seconds then up, then down, then horizontal
kElev          linseg      0, 8,   0, 4, 90, 8, -40, 4, 0
; apply hrtfmove2 opcode to audio source - create stereo ouput
aLeft, aRight  hrtfmove2   aSig, kAz, kElev, \
                               "hrtf-44100-left.dat","hrtf-44100-right.dat"
               outs        aLeft, aRight                 ; audio to outputs
endin

</CsInstruments>

<CsScore>
i 1 0 24 ; instr 1 plays a note for 24 seconds
e
</CsScore>

</CsoundSynthesizer>
