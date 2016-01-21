<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

giWave  ftgen  0, 0, 2^10, 10, 1,0,1/4,0,1/16,0,1/64,0,1/256,0,1/1024

  instr 1 ; an instrument with no 'humanising'
inote =       p4
aEnv  linen   0.1,0.01,p3,0.01
aSig  poscil  aEnv,cpsmidinn(inote),giWave
      outs    aSig,aSig
  endin

  instr 2 ; an instrument with 'humanising'
inote   =       p4

; generate some i-time 'static' random paramters
iRndAmp random	-3,3   ; amp. will be offset by a random number of decibels
iRndNte random  -5,5   ; note will be offset by a random number of cents

; generate some k-rate random functions
kAmpWob rspline -1,1,1,10   ; amplitude 'wobble' (in decibels)
kNteWob rspline -5,5,0.3,10 ; note 'wobble' (in cents)

; calculate final note function (in CPS)
kcps    =        cpsmidinn(inote+(iRndNte*0.01)+(kNteWob*0.01))

; amplitude envelope (randomisation of attack time)
aEnv    linen   0.1*ampdb(iRndAmp+kAmpWob),0.01+rnd(0.03),p3,0.01
aSig    poscil  aEnv,kcps,giWave
        outs    aSig,aSig
  endin

</CsInstruments>

<CsScore>
t 0 80
#define SCORE(i) #
i $i 0 1   60
i .  + 2.5 69
i .  + 0.5 67
i .  + 0.5 65
i .  + 0.5 64
i .  + 3   62
i .  + 1   62
i .  + 2.5 70
i .  + 0.5 69
i .  + 0.5 67
i .  + 0.5 65
i .  + 3   64 #
$SCORE(1)  ; play melody without humanising
b 17
$SCORE(2)  ; play melody with humanising
e
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy
