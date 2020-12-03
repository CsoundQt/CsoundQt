<CsoundSynthesizer>
<CsOptions>
-m 128
</CsOptions>
<CsInstruments>

sr	= 44100
ksmps = 32
nchnls	= 2
0dbfs	= 1

giPortHandle OSCinit 47120

instr Send
 kSendTrigger init 0
 kArray[] fillarray 1, 2, 3, 4, 5, 6, 7
 if metro(1)==1 then
  kSendTrigger += 1
  kArray *= 2
 endif
 OSCsend kSendTrigger, "", 47120, "/exmp_3/array", "A", kArray
endin

instr Receive
 kReceiveArray[] init 7
 kGotIt OSClisten giPortHandle, "/exmp_3/array", "A", kReceiveArray
 if kGotIt == 1 then
  printarray kReceiveArray
 endif
endin

</CsInstruments>
<CsScore>
i "Receive" 0 3
i "Send" 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
