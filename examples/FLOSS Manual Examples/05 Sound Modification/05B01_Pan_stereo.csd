<CsoundSynthesizer>

<CsOptions>
-odac ; activates real time sound output
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 10
nchnls = 2
0dbfs = 1

  instr 1
imethod  =         p4; read panning method variable from score (p4)

;---------------- generate a source sound -------------------
a1       pinkish   0.3; pink noise
a1       reson     a1, 500, 30, 1; bandpass filtered
aPan     lfo       0.5, 1, 1; panning controlled by an lfo
aPan     =         aPan + 0.5; offset shifted +0.5
;------------------------------------------------------------

 if imethod=1 then
;------------------------ method 1 --------------------------
aPanL    =         aPan
aPanR    =         1 - aPan
;------------------------------------------------------------
 endif

 if imethod=2 then
;------------------------ method 2 --------------------------
aPanL    =       sqrt(aPan)
aPanR    =       sqrt(1 - aPan)
;------------------------------------------------------------
 endif

 if imethod=3 then
;------------------------ method 3 --------------------------
aPanL    =       sin(aPan*$M_PI_2)
aPanR    =       cos(aPan*$M_PI_2)
;------------------------------------------------------------
 endif

 if imethod=4 then
;------------------------ method 4 --------------------------
aPanL   =  sin ((aPan + 0.5) * $M_PI_2)
aPanR   =  cos ((aPan + 0.5) * $M_PI_2)
;------------------------------------------------------------
 endif

         outs    a1*aPanL, a1*aPanR ; audio sent to outputs
  endin

</CsInstruments>

<CsScore>
; 4 notes one after the other to demonstrate 4 different methods of panning
;p1 p2  p3   p4(method)
i 1 0   4.5  1
i 1 5   4.5  2
i 1 10  4.5  3
i 1 15  4.5  4
e
</CsScore>

</CsoundSynthesizer>