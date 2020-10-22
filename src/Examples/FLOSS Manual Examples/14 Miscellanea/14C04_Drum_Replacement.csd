<CsoundSynthesizer>
<CsOptions>
-dm0 -odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

instr   1
 asig   diskin  "beats.wav",1

 iThreshold = 0.05
 iWait      = 0.1*sr
 kTimer     init iWait+1
 iSampTim =       0.02             ; time across which RMS change is measured
 kRms   rms     asig ,20
 kRmsPrev       delayk  kRms,iSampTim ; rms from earlier
 kChange =      kRms - kRmsPrev       ; change (+ve or -ve)

 if kTimer > iWait then               ; prevent double triggerings
  ; generate a trigger
  kTrigger   =  kChange > iThreshold ? 1 : 0
  ; if trigger is generated, reset timer
  kTimer  =   kTrigger == 1 ? 0 : kTimer
 else
  kTimer  +=  ksmps                   ; increment timer
  kTrigger = 0                        ; clear trigger
 endif

 ifftsize = 1024
 ; centroid triggered 0.02 after sound onset to avoid noisy attack
 kDelTrig delayk kTrigger,0.02
 kcent  centroid asig, kDelTrig, ifftsize  ; scan centroid
        printk2  kcent            ; print centroid values
 if kDelTrig==1 then
  if kcent>0 && kcent<2500 then   ; first freq. band
   event "i","Cowbell",0,0.1
  elseif kcent<8000 then          ; second freq. band
   event "i","Clap",0,0.1
  else                            ; third freq. band
   event "i","Tambourine",0,0.5
  endif
 endif
endin

instr   Cowbell
 kenv1  transeg 1,p3*0.3,-30,0.2, p3*0.7,-30,0.2
 kenv2  expon   1,p3,0.0005
 kenv   =       kenv1*kenv2
 ipw    =       0.5
 a1     vco2    0.65,562,2,0.5
 a2     vco2    0.65,845,2,0.5
 amix   =       a1+a2
 iLPF2  =       10000
 kcf    expseg  12000,0.07,iLPF2,1,iLPF2
 alpf   butlp   amix,kcf
 abpf   reson   amix, 845, 25
 amix   dcblock2        (abpf*0.06*kenv1)+(alpf*0.5)+(amix*0.9)
 amix   buthp   amix,700
 amix   =       amix*0.5*kenv
        out     amix
endin

instr   Clap
 if frac(p1)==0 then
  event_i       "i", p1+0.1, 0,     0.02
  event_i       "i", p1+0.1, 0.01,  0.02
  event_i       "i", p1+0.1, 0.02,  0.02
  event_i       "i", p1+0.1, 0.03,  2
 else
  kenv  transeg 1,p3,-25,0
  iamp  random  0.7,1
  anoise        dust2   kenv*iamp, 8000
  iBPF          =       1100
  ibw           =       2000
  iHPF          =       1000
  iLPF          =       1
  kcf   expseg  8000,0.07,1700,1,800,2,500,1,500
  asig  butlp   anoise,kcf*iLPF
  asig  buthp   asig,iHPF
  ares  reson   asig,iBPF,ibw,1
  asig  dcblock2        (asig*0.5)+ares
        out     asig
 endif
endin

instr   Tambourine
        asig    tambourine      0.3,0.01 ,32, 0.47, 0, 2300 , 5600, 8000
                out     asig    ;SEND AUDIO TO OUTPUTS
endin

</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy