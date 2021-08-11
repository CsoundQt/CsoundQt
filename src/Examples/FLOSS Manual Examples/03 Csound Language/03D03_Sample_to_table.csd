<CsoundSynthesizer>
<CsOptions>
-odac --env:SSDIR=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

gS_file = "fox.wav"
giSample ftgen 0, 0, 0, 1, gS_file, 0, 0, 1

instr PlayOnce
 p3 filelen gS_file ;play whole length of the sound file
 aSamp poscil3 .5, 1/p3, giSample
 out aSamp, aSamp
endin

</CsInstruments>
<CsScore>
i "PlayOnce" 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
