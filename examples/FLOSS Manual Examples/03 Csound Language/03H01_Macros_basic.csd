<CsoundSynthesizer>

<CsOptions>
-odac
</CsOptions>

<CsInstruments>
sr 	= 	44100
ksmps 	= 	16
nchnls 	= 	1
0dbfs	=	1

; define the macro
#define SOUNDFILE # "loop.wav" #

 instr  1
; use an expansion of the macro in deriving the duration of the sound file
idur  filelen   $SOUNDFILE
      event_i   "i",2,0,idur
 endin

 instr  2
; use another expansion of the macro in playing the sound file
a1  diskin2  $SOUNDFILE,1
    out      a1
 endin

</CsInstruments>

<CsScore>
i 1 0 0.01
e
</CsScore>
</CsoundSynthesizer>
; example written by Iain McCurdy
