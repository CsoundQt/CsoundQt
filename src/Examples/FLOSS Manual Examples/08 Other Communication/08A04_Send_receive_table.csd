<CsoundSynthesizer>
<CsOptions>
-m 128
</CsOptions>
<CsInstruments>

sr  = 44100
ksmps = 32
nchnls  = 2
0dbfs   = 1

giPortHandle OSCinit 47120

giTable_1 ftgen 0, 0, 1024, 10, 1
giTable_2 ftgen 0, 0, 1024, 10, 1, 1, 1, 1, 1
giTable_3 ftgen 0, 0, 1024, 10, 1, .5, 3, .1

instr Send
 kSendTrigger init 1
 kTable init giTable_1
 kTime init 0
 OSCsend kSendTrigger, "", 47120, "/exmp_4/table", "G", kTable
 if timeinsts() >= kTime+1 then
  kSendTrigger += 1
  kTable += 1
  kTime = timeinsts()
 endif
endin

instr Receive
 iReceiveTable ftgen 0, 0, 1024, 2, 0
 kGotIt OSClisten giPortHandle, "/exmp_4/table", "G", iReceiveTable
 aOut poscil .2, 400, iReceiveTable
 out aOut, aOut
endin

</CsInstruments>
<CsScore>
i "Receive" 0 3
i "Send" 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz