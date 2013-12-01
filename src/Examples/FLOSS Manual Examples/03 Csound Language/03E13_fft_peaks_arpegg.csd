<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -d -m128
; Example by Tarmo Johannes
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine     ftgen      0, 0, 4096, 10, 1

instr getPeaks

;generate signal to analyze
kfrcoef    jspline    60, 0.1, 1 ; change the signal in time a bit for better testing
kharmcoef  jspline    4, 0.1, 1
kmodcoef   jspline    1, 0.1, 1
kenv       linen      0.5, 0.05, p3, 0.05
asig       foscil     kenv, 300+kfrcoef, 1, 1+kmodcoef, 10, giSine
           outs       asig*0.05, asig*0.05 ; original sound in backround

;FFT analysis
ifftsize   =          1024
ioverlap   =          ifftsize / 4
iwinsize   =          ifftsize
iwinshape  =          1
fsig       pvsanal    asig, ifftsize, ioverlap, iwinsize, iwinshape
ithresh    =          0.001 ; detect only peaks over this value

;FFT values to array
kFrames[]  init       iwinsize+2 ; declare array
kframe     pvs2array  kFrames, fsig ; even member = amp of one bin, odd = frequency

;detect peaks
kindex     =          2 ; start checking from second bin
kcounter   =          0
iMaxPeaks  =          13 ; track up to iMaxPeaks peaks
ktrigger   metro      1/2 ; check after every 2 seconds
 if ktrigger == 1 then
loop:
; check with neigbouring amps - if higher or equal than previous amp
; and more than the coming one, must be peak.
   if (kFrames[kindex-2]<=kFrames[kindex] &&
      kFrames[kindex]>kFrames[kindex+2] &&
      kFrames[kindex]>ithresh &&
      kcounter<iMaxPeaks) then
kamp        =         kFrames[kindex]
kfreq       =         kFrames[kindex+1]
; play sounds with the amplitude and frequency of the peak as in arpeggio
            event     "i", "sound", kcounter*0.1, 1, kamp, kfreq
kcounter = kcounter+1
    endif
            loop_lt   kindex, 2,  ifftsize, loop
  endif
endin

instr sound
iamp       =          p4
ifreq      =          p5
kenv       adsr       0.1,0.1,0.5,p3/2
kndx       line       5,p3,1
asig       foscil     iamp*kenv, ifreq,1,0.75,kndx,giSine
           outs       asig, asig
endin

</CsInstruments>
<CsScore>
i "getPeaks" 0 60
</CsScore>
</CsoundSynthesizer>
