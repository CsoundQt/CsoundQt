<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

instr 1

iamp =      p4                  ;amplitude scaler
ifreq =     p5                  ;frequency scaler
iatsfile =  p7                  ;atsfile
itab =      p6                  ;audio table
ifreqscal = 1                   ;frequency scaler
ipars   ATSinfo iatsfile, 3     ;how many partials
idur    ATSinfo iatsfile, 7     ;get duration
ktime   line    0, p3, idur     ;time pointer

        ATSbufread ktime, ifreqscal, iatsfile, ipars ;reads an ATS buffer
kamp    ATSinterpread ifreq         ;get the amp values according to freq
aamp    interp kamp                               ;interpolate amp values
aout    oscil3 aamp, ifreq, itab                  ;synthesize

        out aout*iamp
endin

</CsInstruments>
<CsScore>
; sine wave table
f 1 0 16384 10 1
#define atsfile #"test.ats"#

;  start dur amp freq atab atsfile
i1 0     3   1   440  1    $atsfile     ;first partial
i1 +     3   1   550  1    $atsfile     ;closer to first partial
i1 +     3   1   660  1    $atsfile     ;half way between both
i1 +     3   1   770  1    $atsfile     ;closer to second partial
i1 +     3   1   880  1    $atsfile     ;second partial
e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia
