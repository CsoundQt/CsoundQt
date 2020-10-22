<CsoundSynthesizer>
<CsOptions>
-m 128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

gifil ftgen 0, 0, 0, 1, "fox.wav", 0, 0, 1

instr Raw
 fStretch pvstanal 1/10, 1, 1, gifil, 0 ;kdetect is turned off
 aStretch pvsynth fStretch
 out aStretch, aStretch
endin

instr Smooth
 iAmpCutoff = p4 ;0-1
 iFreqCutoff = p5 ;0-1
 fStretch pvstanal 1/10, 1, 1, gifil, 0
 fSmooth pvsmooth fStretch, iAmpCutoff, iFreqCutoff
 aSmooth pvsynth fSmooth
 out aSmooth, aSmooth
endin

instr Blur
 iBlurtime = p4 ;sec
 fStretch pvstanal 1/10, 1, 1, gifil, 0
 fBlur pvsblur fStretch, iBlurtime, 1
 aSmooth pvsynth fBlur
 out aSmooth, aSmooth
endin

instr Smooth_var
 fStretch pvstanal 1/10, 1, 1, gifil, 0
 kAmpCut randomi .001, .1, 10, 3
 kFreqCut randomi .05, .5, 50, 3
 fSmooth pvsmooth fStretch, kAmpCut, kFreqCut
 aSmooth pvsynth fSmooth
 out aSmooth, aSmooth
endin

instr Blur_var
 kBlurtime randomi .005, .5, 200, 3
 fStretch pvstanal 1/10, 1, 1, gifil, 0
 fBlur pvsblur fStretch, kBlurtime, 1
 aSmooth pvsynth fBlur
 out aSmooth, aSmooth
endin

instr SmoothBlur
    iacf = p4
    ifcf = p5
    iblurtime = p6
    fanal pvstanal 1/10, 1, 1, gifil, 0
    fsmot pvsmooth fanal, iacf, ifcf
    fblur pvsblur fsmot, iblurtime, 1
    a_smt pvsynth fblur
    aOut linenr a_smt, 0, iblurtime*2, .01
    out aOut, aOut
endin

</CsInstruments>
<CsScore>
i "Raw" 0 16
i "Smooth" 17 16 .01 .1
i "Blur" 34 16 .2
i "Smooth_var" 51 16
i "Blur_var" 68 16
i "SmoothBlur" 85 16 1 1 0
i . 102 . .1 1 .25
i . 119 . .01 .1 .5
i . 136 . .001 .01 .75
i . 153 . .0001 .001 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz and farhad ilaghi hosseini