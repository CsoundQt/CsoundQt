<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  opcode RndInt, k, kk
kMin, kMax xin
kRnd random kMin, kMax+.999999
kRnd = int(kRnd)
xout kRnd
  endop

instr 1 ;opcode

 kBla init 10
 kBla random 1, 2
 prints "instr 1: kBla initialized to %d\n", i(kBla)
 turnoff

endin

instr 2 ;udo has different effect at i-time

 kBla init 10
 kBla RndInt 1, 2
 prints "instr 2: kBla initialized to %d\n", i(kBla)
 turnoff

endin

instr 3 ;but the functional syntax makes it different

 kBla init 10
 kBla = RndInt(1, 2)
 prints "instr 3: kBla initialized to %d\n", i(kBla)
 turnoff

endin

</CsInstruments>
<CsScore>
i 1 0 .1
i 2 + .
i 3 + .
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
