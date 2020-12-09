<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1

 ;a string to be copied at init- and performance-time
 String strcpyk "yes!\n"

 ;print it at init-time
 printf_i "INIT 1: %s", 1, String

 ;a copy assignment that will never become true during performance
 kBla = 0
 if kBla == 1 then
  String strcpyk "no!\n"
 endif

 ;nevertheless the string variable is initialized by it
 printf_i "INIT 2: %s", 1, String

 ;during performance only "yes!" remains
 printf "PERF %d: %s", timeinstk(), timeinstk(), String

 ;turn off after three k-cycles
 if timeinstk() == 3 then
  turnoff
 endif

endin

</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
