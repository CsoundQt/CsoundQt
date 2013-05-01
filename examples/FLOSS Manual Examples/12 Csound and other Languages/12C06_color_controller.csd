<CsoundSynthesizer>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2

garvb  init     0
alwayson "_reverb"

;============================================================================;
;==================================== RED ===================================;
;============================================================================;
; parameters from original score
;i 8   15.5   3.1     3      50       4000   129    8      2.6    0.3
       instr   red
ifuncl =       16

p4 = 2.2 ; amp
p5 = 50 ; FilterSweep StartFreq
p6 = 4000 ; FilterSweep EndFreq
p7= 129 ; bandwidth
p8 = 8 ; cps of rand1
p9 = 2.6 ; cps of rand2
p10 = 0.3 ; reverb send factor

k1     expon   p5, p3, p6
k2     line    p8, p3, p8 * .93
k3     phasor  k2
k4     table   k3 * ifuncl, 20
anoise rand    8000
aflt1  reson   anoise, k1, 20 + (k4 * k1 / p7), 1

k5     linseg  p6 * .9, p3 * .8, p5 * 1.4, p3 * .2, p5 * 1.4
k6     expon   p9 * .97, p3, p9
k7     phasor  k6
k8     tablei  k7 * ifuncl, 21
aflt2  reson   anoise, k5, 30 + (k8 * k5 / p7 * .9), 1

abal   oscil   1000, 1000, 1
a3     balance aflt1, abal
a5     balance aflt2, abal


k11    linen   p4, .15, p3, .5
a3     =       a3 * k11
a5     =       a5 * k11

k9     randh   1, k2
aleft  =       ((a3 * k9) * .7) + ((a5 * k9) * .3)
k10    randh   1, k6
aright =       ((a3 * k10) * .3)+((a5 * k10) * .7)
klevel invalue "red"
klevel port klevel,0.05	
       outs    aleft*klevel, aright*klevel
garvb  =       garvb + (a3 * p10)*klevel
endin

;============================================================================;
;==================================== BLUE ==================================;
;============================================================================;
;i 2   80.7   8       0      8.077    830    0.7    24     19     0.13
       instr blue                               ; p6 = amp

p5 = 8.077 ; pitch
p6 = 830 ; amp
p7 = 0.7 ; reverb send factor
p8 = 24 ; lfo freq
p9 = 19 ; number of harmonic
p10 = 0.1+rnd(0.2) ;0.5 ; sweep rate

ifreq  random 500,1000;cpspch(p5)
k1     randi    1, 30
k2     linseg   0, p3 * .5, 1, p3 * .5, 0
k3     linseg   .005, p3 * .71, .015, p3 * .29, .01
k4     oscil    k2, p8, 1,.2
k5     =        k4 + 2

ksweep linseg   p9, p3 * p10, 1, p3 * (p3 - (p3 * p10)), 1

kenv   expseg   .001, p3 * .01, p6, p3 * .99, .001
asig   gbuzz    kenv, ifreq + k3, k5, ksweep, k1, 15

klevel invalue "blue"
klevel port klevel,0.05	
asig = asig*klevel
       outs     asig, asig
garvb  =        garvb + (asig * p7)
       endin


;============================================================================;
;==================================== GREEN =================================;
;============================================================================;
; i 5   43     1.1     9.6    3.106    2500   0.4    1.0    8      3    17  34

        instr  green                             ; p6 = amp
p5 = 3.106 ; pitch
p6 = 2500 ; amp
p7 = 0.4 ; reverb send
p8 = 0.5 ; pan direction
p9 = 8 ; carrier freq
p10 = 3 ; modulator freq
p11 = 17 ; modulation index
p12 = 34 ; rand freq

ifreq   =      cpspch(p5)                    ; p7 = reverb send factor
                                             ; p8 = pan direction
k1     line    p9, p3, 1                     ; ... (1.0 = L -> R, 0.1 = R -> L)
k2     line    1, p3, p10                    ; p9 = carrier freq
k4     expon   2, p3, p12                    ; p10 = modulator freq
k5     linseg  0, p3 * .8, 8, p3 * .2, 8     ; p11 = modulation index
k7     randh   p11, k4                       ; p12 = rand freq
k6     oscil   k4, k5, 1, .3

kenv1  linen   p6, .03, p3, .2
a1     foscil  kenv1, ifreq + k6, k1, k2, k7, 1

kenv2  linen   p6, .1, p3, .1
a2     oscil   kenv2, ifreq * 1.001, 1

amix   =       a1 + a2
kpan   linseg  int(p8), p3 * .7, frac(p8), p3 * .3, int(p8)
klevel invalue "green"
klevel port klevel,0.05
amix = amix*klevel
       outs    amix * kpan, amix * (1 - kpan)
garvb  =       garvb + (amix * p7)
       endin


 instr   _reverb
p4 = 1/10                          ; p4 = panrate
k1     oscil   .5, p4, 1
k2     =       .5 + k1
k3     =       1 - k2	
asig   reverb  garvb, 2.1
       outs    asig * k2, (asig * k3) * (-1)
garvb  =       0
       endin

</CsInstruments>
<CsScore>
;============================================================================;
;========================= FUNCTIONS ========================================;
;============================================================================;
f1   0  8192  10   1
; 15 - vaja
f15  0  8192  9    1   1   90
;kasutusel red
f16  0  2048  9    1   3   0   3   1   0   6   1   0
f20  0  16   -2    0   30  40  45  50  40  30  20  10  5  4  3  2  1  0  0  0
f21  0  16   -2    0   20  15  10  9   8   7   6   5   4  3  2  1  0  0

r 3 COUNT
i "red" 0 20
i "green" 0 20
i "blue" 0 6
i . + 3
i . + 4
i . + 7
s

f 0 1800

</CsScore>
</CsoundSynthesizer>
;example by tarmo johannes, after richard boulanger
