<CsoundSynthesizer>

<CsOptions>
-o dac
</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 8
nchnls = 1
0dbfs = 1

; handle used to reference osc stream
gihandle OSCinit 12001

 instr 1
; initialise variable used for analog values
gkana0      init       0
; read in OSC channel '/analog/0'
gktrigana0  OSClisten  gihandle, "/analog/0", "i", gkana0
; print changed values to terminal
            printk2    gkana0
 endin

</CsInstruments>

<CsScore>
i 1 0 3600
e
</CsScore>

</CsoundSynthesizer>
