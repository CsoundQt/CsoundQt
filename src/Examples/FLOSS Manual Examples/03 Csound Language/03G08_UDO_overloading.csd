<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>
ksmps  = 32

  opcode Defaults, iii, opj
ia, ib, ic xin
xout ia, ib, ic
  endop

  opcode Defaults, kkkk, OPVJ
k1, k2, k3, k4 xin
xout k1, k2, k3, k4
  endop


instr 1
ia, ib, ic Defaults
           prints    "ia = %d, ib = %d, ic = %d\n", ia, ib, ic
ia, ib, ic Defaults  10
           prints    "ia = %d, ib = %d, ic = %d\n", ia, ib, ic
ia, ib, ic Defaults  10, 100
           prints    "ia = %d, ib = %d, ic = %d\n", ia, ib, ic
ia, ib, ic Defaults  10, 100, 1000
           prints    "ia = %d, ib = %d, ic = %d\n", ia, ib, ic
ka1, kb1, kc1, kd1 Defaults
printks   "ka = %d, kb = %d, kc = %.1f, kd = %d\n", 0, ka1, kb1, kc1, kd1
ka2, kb2, kc2, kd2 Defaults 2
printks   "ka = %d, kb = %d, kc = %.1f, kd = %d\n", 0, ka2, kb2, kc2, kd2
ka3, kb3, kc3, kd3 Defaults 2, 4
printks   "ka = %d, kb = %d, kc = %.1f, kd = %d\n", 0, ka3, kb3, kc3, kd3
ka4, kb4, kc4, kd4 Defaults 2, 4, 6
printks   "ka = %d, kb = %d, kc = %.1f, kd = %d\n", 0, ka4, kb4, kc4, kd4
ka5, kb5, kc5, kd5 Defaults 2, 4, 6, 8
printks   "ka = %d, kb = %d, kc = %.1f, kd = %d\n", 0, ka5, kb5, kc5, kd5
			turnoff
endin

</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
