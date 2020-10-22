<CsoundSynthesizer>
<CsOptions>
-odac  -m128
</CsOptions>
<CsInstruments>

sr  = 44100
ksmps = 32
nchnls  = 2
0dbfs   = 1

;create IR table
giIR_record ftgen 0, 0, 131072, 2, 0

instr Input

 ain diskin "beats.wav", 1, 0, 1
 chnset ain, "input"
 if timeinsts() < 2 then
  outch 2, ain/2
 endif
endin

instr Record_IR

 ;set p3 to table duration
 p3 = ftlen(giIR_record)/sr
 iskip = p4
 irlen = p5

 ;mimic live input for impulse response
 asnd diskin "fox.wav", 1, iskip
 amp linseg 0, 0.01, 1, irlen, 1, 0.01, 0
 asnd *= amp

 ;fill IR table
 andx_IR line 0, p3, ftlen(giIR_record)
 tablew asnd, andx_IR, giIR_record

 ;send 1 at first k-cycle, otherwise 0
 ktrig init 1
 chnset ktrig, "conv_update"
 ktrig = 0

 ;output the IR for reference
    outch 1, asnd

endin

instr Convolver

 ;receive information about updating the table
 kupdate    chnget "conv_update"

 ;different dB values for the different IR
 kdB[] fillarray -34, -35, -40, -28, -40, -40, -40
 kindx init -1
 if kupdate==1 then
  kindx += 1
 endif

 ;apply live convolution
 ain chnget "input"
 aconv liveconv ain, giIR_record, 2048, kupdate, 0
    outch 2, aconv*ampdb(kdB[kindx])

endin

</CsInstruments>
<CsScore>
;play input sound alone first
i "Input" 0 15.65

;record impulse response multiple times
;                  skip  IR_dur
i "Record_IR" 2 1  0.17  0.093
i .           4 .  0.50  0.13
i .           6 .  0.76  0.19
i .           8 .  0.97  0.12
i .          10 .  1.72  0.12
i .          12 .  2.06  0.12
i .          14 .  2.37  0.27

;convolve continuously
i "Convolver"   2   13.65
</CsScore>
</CsoundSynthesizer>
;example by Oeyving Brandtsegg and Sigurd Saue