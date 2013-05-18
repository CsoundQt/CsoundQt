<CsoundSynthesizer>
<CsOptions>
 -o dac -d
</CsOptions>
<CsInstruments>
; Example by Bjørn Houdorf, february 2013

sr     = 44100
ksmps  = 128
nchnls = 2
0dbfs  = 1

; First we hear each grain, but later on it sounds more like a drum roll.
; If your computer have problems with running this CSD-file in real-time,
; you can render to a soundfile. Just write "-o filename" in the <CsOptions>,
; instead of "-o dac"
gareverbL  init       0
gareverbR  init       0
giFt1      ftgen      0, 0, 1025, 20, 2, 1 ; GEN20, Hanning window for grain envelope
; The soundfile(s) you use should be in the same folder as your csd-file
; The soundfile "fox.wav" can be downloaded at http://csound-tutorial.net/node/1/58
giFt2      ftgen      0, 0, 524288, 1, "fox.wav", 0, 0, 0
; Instead you can use your own soundfile(s)

instr 1 ; Granular synthesis of soundfile
ipitch     =          sr/ftlen(giFt2) ; Original frequency of the input sound
kdens1     expon      3, p3, 500
kdens2     expon      4, p3, 400
kdens3     expon      5, p3, 300
kamp       line       1, p3, 0.05
a1         grain      1, ipitch, kdens1, 0, 0, 1, giFt2, giFt1, 1
a2         grain      1, ipitch, kdens2, 0, 0, 1, giFt2, giFt1, 1
a3         grain      1, ipitch, kdens3, 0, 0, 1, giFt2, giFt1, 1
aleft      =          kamp*(a1+a2)
aright     =          kamp*(a2+a3)
           outs       aleft, aright ; Output granulation
gareverbL  =          gareverbL + a1+a2 ; send granulation to Instr 2 (Reverb)
gareverbR  =          gareverbR + a2+a3
endin

instr 2 ; Reverb
kkamp      line       0, p3, 0.08
aL         reverb     gareverbL, 10*kkamp ; reverberate what is in gareverbL
aR         reverb     gareverbR, 10*kkamp ; and garaverbR
           outs       kkamp*aL, kkamp*aR ; and output the result
gareverbL  =          0 ; empty the receivers for the next loop
gareverbR  =          0
endin
</CsInstruments>
<CsScore>
i1 0 20 ; Granulation
i2 0 21 ; Reverb
</CsScore>
</CsoundSynthesizer>
