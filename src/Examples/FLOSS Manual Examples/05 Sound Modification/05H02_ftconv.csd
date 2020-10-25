<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>
<CsInstruments>

sr     =  44100
ksmps  =  128
nchnls =  2
0dbfs  =  1

; impulse responses stored as mono GEN01 function tables
giStairwell     ftgen   1,0,131072,1,"Stairwell.wav",0,0,0
giDish          ftgen   2,0,131072,1,"dish.wav",0,0,0

gasig init 0

; reverse function table UDO
 opcode tab_reverse,0,i
ifn             xin
iTabLen         =               ftlen(ifn)
iTableBuffer    ftgentmp        0,0,-iTabLen,-2, 0
icount          =               0
loop:
ival            table           iTabLen-icount-1, ifn
                tableiw         ival,icount,iTableBuffer
                loop_lt         icount,1,iTabLen,loop
icount          =               0
loop2:
ival            table           icount,iTableBuffer
                tableiw         ival,icount,ifn
                loop_lt         icount,1,iTabLen,loop2
 endop

 instr 3 ; reverse the contents of a function table
          tab_reverse p4
 endin

 instr 1 ; sound file player
gasig           diskin    p4,1,0,1
 endin

 instr 2 ; convolution reverb
; buffer length
iplen   =       1024
; derive the length of the impulse response
iirlen  =       nsamp(p4)
aconv ftconv  gasig, p4, iplen,0, iirlen
; delay compensation. Add extra delay if reverse reverb is used.
adel            delay     gasig,(iplen/sr) + ((iirlen/sr)*p6)
; create a dry/wet mix
aMix   ntrpol    adel,aconv*0.1,p5
        outs      aMix, aMix
gasig           =         0
 endin

</CsInstruments>
<CsScore>
; instr 1. sound file player
;    p4=input soundfile
; instr 2. convolution reverb
;    p4=impulse response file
;    p5=dry/wet mix (0 - 1)
;    p6=reverse reverb switch (0=off,1=on)
; instr 3. reverse table contents
;    p4=function table number

; 'stairwell' impulse response
i 1 0 8.5 "loop.wav"
i 2 0 10 1 0.3 0

; 'dish' impulse response
i 1 10 8.5 "loop.wav"
i 2 10 10 2 0.8 0

; reverse the impulse responses
i 3 20 0 1
i 3 20 0 2

; 'stairwell' impulse response (reversed)
i 1 21 8.5 "loop.wav"
i 2 21 10 1 0.5 1

; 'dish' impulse response (reversed)
i 1 31 8.5 "loop.wav"
i 2 31 10 2 0.5 1
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy