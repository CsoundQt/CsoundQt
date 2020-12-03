<Cabbage>
form size(420,100)
keyboard bounds(10,10,300,80)
rslider bounds(325,15,80,80), channel("level"), text("Level"), range(0,1,0.3)
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=null -M0
</CsOptions>

<CsInstruments>

sr     = 44100
ksmps  = 32
nchnls = 2
0dbfs  = 1

instr    1
 icps  cpsmidi
 klev  chnget  "level"
 a1    poscil  klev*0.2,icps
       outs    a1,a1
endin

</CsInstruments>

</CsoundSynthesizer>
;example by Iain McCurdy
