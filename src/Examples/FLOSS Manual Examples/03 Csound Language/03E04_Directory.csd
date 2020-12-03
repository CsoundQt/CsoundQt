<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Files
 S_array[] directory "."
 iNumFiles lenarray S_array
 prints "Number of files in %s = %d\n", pwd(), iNumFiles
 printarray S_array
endin

</CsInstruments>
<CsScore>
i "Files" 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
