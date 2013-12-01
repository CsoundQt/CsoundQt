<CsoundSynthesizer>
<CsInstruments>
sr = 44100
ksmps = 100
nchnls = 2
0dbfs = 1

;Van der Pol Oscillator ;outputs a nonliniear oscillation
;inputs: a_excitation, k_frequency in Hz (of the linear part), nonlinearity (0 < mu < ca. 0.7)
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
kaex invalue "aex"
kfex invalue "fex"
kamp invalue "amp"
kf invalue "freq"
kmu invalue "mu"
a1 oscil kaex,kfex,1
aout v_d_p a1,kf,kmu
out kamp*aout,a1*100
endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
i1 0 95
</CsScore>
</CsoundSynthesizer>
