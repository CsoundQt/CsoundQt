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
 kFloat = 1.23456789
 Sstring = "bla bla"
 OSCsend kSendTrigger, "", 47120, "/exmp_2/more", "fs", kFloat, Sstring
endin

instr Receive
 kReceiveFloat init 0
 SReceiveString init ""
 kGotIt OSClisten giPortHandle, "/exmp_2/more", "fs", 
                  kReceiveFloat, SReceiveString
 if kGotIt == 1 then
  printf "kReceiveFloat = %f\nSReceiveString = '%s'\n", 
         1, kReceiveFloat, SReceiveString
 endif
endin

</CsInstruments>
<CsScore>
i "Receive" 0 3 ;start listening process first
i "Send" 1 1    ;then after one second send message
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
