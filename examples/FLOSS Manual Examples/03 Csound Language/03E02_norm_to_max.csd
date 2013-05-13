<CsoundSynthesizer>
<CsOptions>
-odac ; no -d -allow displays
;Example by Tarmo Johannes
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

#define ELEMENTS #5#
seed 0

giTab1 ftgen 0,0,-$ELEMENTS,-21,1,100 ; table of random numbers, 5 elements, maximum 100
giTab2 ftgen 0,0,-$ELEMENTS,-21,1,100


instr 1
        
        t1 init $ELEMENTS
        t2 init $ELEMENTS
        
        copy2ttab t1, giTab1 ; f-tables to vectors
        copy2ttab t2, giTab2
        
        ; find out maxima
        kmax1 maxtab t1
        kmax2 maxtab t2
        
        if (kmax1>kmax2) then
                scalet t2, 0,kmax1 ; scale to the maximum of the higer table
                printks "Vector 1 has higer maximum: %f\n",0, kmax1
                copy2ftab t2, giTab2 ; and write it back to f-table
        else
                scalet t1, 0,kmax2 ; scale to the maximum of the higer table
                printks "Vector 2 has higer maximum %f\n",0, kmax2
                copy2ftab t1, giTab1
        endif

        ; output the new values of the vectors
        kindex=0
loop2:
        event "i", 2, 0, 0, 1,kindex,t1[kindex]
        event "i", 2, 0, 0, 2,kindex,t2[kindex]
        loop_lt kindex,1,$ELEMENTS, loop2
        
        turnoff ; finish after 1 performance pass       
endin

instr 2 ; output values
        prints "Vector: %d index: %d value: %f\n", p4,p5,p6
endin

</CsInstruments>
<CsScore>
i 1 0 0.1
</CsScore>
</CsoundSynthesizer> 
