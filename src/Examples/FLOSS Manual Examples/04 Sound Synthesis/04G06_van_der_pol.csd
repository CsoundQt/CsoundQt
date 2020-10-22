<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;Van der Pol Oscillator ;outputs a nonliniear oscillation
;inputs: a_excitation, k_frequency in Hz (of the linear part),
;nonlinearity (0 < mu < ca. 0.7)
opcode v_d_p, a, akk
 setksmps 1
 av init 0
 ax init 0
 ain,kfr,kmu xin
 kc = 2-2*cos(kfr*2*$M_PI/sr)
 aa = -kc*ax + kmu*(1-ax*ax)*av
 av = av + aa
 ax = ax + av + ain
 xout ax
endop

instr 1
 kaex = .001
 kfex = 830
 kamp = .15
 kf = 455
 kmu linseg 0,p3,.7
 a1 poscil kaex,kfex
 aout v\_d\_p a1,kf,kmu
 out kamp*aout,a1*100
endin

</CsInstruments>
<CsScore>
i1 0 20
</CsScore>
</CsoundSynthesizer>
;example by martin neukom, adapted by joachim heintz