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
 kSendTrigger = 1
 kSendValue = 17
 OSCsend kSendTrigger, "", 47120, "/exmp_1/int", "i", kSendValue
endin

instr Receive
 kReceiveValue init 0
 kGotIt OSClisten giPortHandle, "/exmp_1/int", "i", kReceiveValue
 if kGotIt == 1 then
  printf "Message Received for '%s' at time %f: kReceiveValue = %d\n",
         1, "/exmp_1/int", times:k(), kReceiveValue
 endif
endin

</CsInstruments>
<CsScore>
i "Receive" 0 3 ;start listening process first
i "Send" 1 1    ;then after one second send message
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
