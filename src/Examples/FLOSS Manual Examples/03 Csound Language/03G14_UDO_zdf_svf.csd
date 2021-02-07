<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

    opcode zdf_svf,aaa,aKK

ain, kcf, kR     xin

; pre-warp the cutoff- these are bilinear-transform filters
kwd = 2 * $M_PI * kcf
iT  = 1/sr
kwa = (2/iT) * tan(kwd * iT/2)
kG  = kwa * iT/2

;; output signals
alp init 0
ahp init 0
abp init 0

;; state for integrators
kz1 init 0
kz2 init 0

;;
kindx = 0
while kindx < ksmps do
  khp = (ain[kindx] - (2*kR+kG) * kz1 - kz2) / (1 + (2*kR*kG) + (kG*kG))
  kbp = kG * khp + kz1
  klp = kG * kbp + kz2

  ; z1 register update
  kz1 = kG * khp + kbp
  kz2 = kG * kbp + klp

  alp[kindx] = klp
  ahp[kindx] = khp
  abp[kindx] = kbp
  kindx += 1
od

xout alp, abp, ahp


    endop

    opcode zdf_svf,aaa,aaa

ain, acf, aR     xin

iT  = 1/sr

;; output signals
alp init 0
ahp init 0
abp init 0

;; state for integrators
kz1 init 0
kz2 init 0

;;
kindx = 0
while kindx < ksmps do

  ; pre-warp the cutoff- these are bilinear-transform filters
  kwd = 2 * $M_PI * acf[kindx]
  kwa = (2/iT) * tan(kwd * iT/2)
  kG  = kwa * iT/2

  kR = aR[kindx]

  khp = (ain[kindx] - (2*kR+kG) * kz1 - kz2) / (1 + (2*kR*kG) + (kG*kG))
  kbp = kG * khp + kz1
  klp = kG * kbp + kz2

  ; z1 register update
  kz1 = kG * khp + kbp
  kz2 = kG * kbp + klp

  alp[kindx] = klp
  ahp[kindx] = khp
  abp[kindx] = kbp
  kindx += 1
od

xout alp, abp, ahp


    endop

giSine ftgen 0, 0, 2^14, 10, 1

instr 1

 aBuzz buzz 1, 100, 50, giSine
 aLp, aBp, aHp zdf_svf aBuzz, 1000, 1

 out aHp, aHp

endin


</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>
;example by steven yi
