<CsoundSynthesizer> ; Wobble bass made with additive synthesis

<CsOptions> ; and frequency modulation
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>

<CsInstruments>
; Example by Bjørn Houdorf, March 2013
sr = 44100
ksmps = 1
nchnls = 2
0dbfs = 1

instr 1
kamp       =          24 ; Amplitude
kfreq      expseg     p4, p3/2, 50*p4, p3/2, p4 ; Base frequency
iloopnum   =          p5 ; Number of all partials generated
alyd1      init       0
alyd2      init       0
           seed       0
kfreqmult  oscili     1, 2, 1
kosc       oscili     1, 2.1, 1
ktone      randomh    0.5, 2, 0.2 ; A random input
icount     =          1

loop: ; Loop to generate partials to additive synthesis
kfreq      =          kfreqmult * kfreq
atal       oscili     1, 0.5, 1
apart      oscili     1, icount*exp(atal*ktone) , 1 ; Modulate each partials
anum       =          apart*kfreq*kosc
asig1      oscili     kamp, anum, 1
asig2      oscili     kamp, 1.5*anum, 1 ; Chorus effect to make the sound more "fat"
asig3      oscili     kamp, 2*anum, 1
asig4      oscili     kamp, 2.5*anum, 1
alyd1      =          (alyd1 + asig1+asig4)/icount ;Sum of partials
alyd2      =          (alyd2 + asig2+asig3)/icount
           loop_lt    icount, 1, iloopnum, loop ; End of loop

           outs       alyd1, alyd2 ; Output generated sound
endin
</CsInstruments>

<CsScore>
f1 0 128 10 1
i1 0 60 110 50
e
</CsScore>

</CsoundSynthesizer>
