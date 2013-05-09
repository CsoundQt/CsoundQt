<CsoundSynthesizer>

<CsOptions>
</CsOptions>

<CsInstruments>

sr = 44100
nchnls = 2
0dbfs = 1
ksmps = 32

 instr 1
; read in controller data from Pd via the API using 'invalue'
kctrl1  invalue  "ctrl1"
kctrl2  invalue  "ctrl2"
; re-range controller values from 0 - 1 to 7 - 11
koct    =        (kctrl2*4)+7
; create an oscillator
a1      vco2     kctrl1,cpsoct(koct),4,0.1
        outs     a1,a1	
 endin
</CsInstruments>

<CsScore>
i 1 0 10000
e
</CsScore>

</CsoundSynthesizer>
