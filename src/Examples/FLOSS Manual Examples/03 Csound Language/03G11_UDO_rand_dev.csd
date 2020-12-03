<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 256, 10, 1; sine wave

opcode TabDirtk, 0, ikk
 ;"dirties" a function table by applying random deviations at a k-rate trigger
 ;input: function table, trigger (1 = perform manipulation),
 ;deviation as percentage
 ift, ktrig, kperc xin
 if ktrig == 1 then ;just work if you get a trigger signal
  kndx      =         0
  while kndx < ftlen(ift) do
   kval table kndx, ift; read old value
   knewval = kval + rnd31:k(kperc/100,0); calculate new value
   tablew knewval, kndx, giSine; write new value
   kndx += 1
  od
 endif
endop

  instr 1
kTrig metro 1 ;trigger signal once per second
kPerc linseg 0, p3, 100
TabDirtk giSine, kTrig, kPerc
aSig poscil .2, 400, giSine
out aSig, aSig
  endin

</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
