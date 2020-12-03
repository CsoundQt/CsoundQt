<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1

 ;k-variables
 k_var init 20
 k_var linseg 10, 1, 0

 ;string variables
 S_var init "goodbye"
 S_var strcpyk "world"

 ;print out at init-time
 prints "k_var -> %d\n", k_var
 printf_i "S_var -> %s\n", 1, S_var

endin

</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
