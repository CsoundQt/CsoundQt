<CsoundSynthesizer>
<CsOptions>
-o dac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

opcode AddSynth,a,i[]i[]iooo
 /* iFqs[], iAmps[]: arrays with frequency ratios and amplitude multipliers
 iBasFreq: base frequency (hz)
 iPtlIndex: partial index (first partial = index 0)
 iFreqDev, iAmpDev: maximum frequency (cent) and amplitude (db) deviation */
 iFqs[], iAmps[], iBasFreq, iPtlIndx, iFreqDev, iAmpDev xin
 iFreq = iBasFreq * iFqs[iPtlIndx] * cent(rnd31:i(iFreqDev,0))
 iAmp = iAmps[iPtlIndx] * ampdb(rnd31:i(iAmpDev,0))
 aPartial poscil iAmp, iFreq
 if iPtlIndx < lenarray(iFqs)-1 then
  aPartial += AddSynth(iFqs,iAmps,iBasFreq,iPtlIndx+1,iFreqDev,iAmpDev)
 endif
 xout aPartial
endop

;frequency and amplitude multipliers for 11 partials of Risset's bell
giFqs[] fillarray  .56, .563, .92, .923, 1.19, 1.7, 2, 2.74, 3, 3.74, 4.07
giAmps[] fillarray 1, 2/3, 1, 1.8, 8/3, 5/3, 1.46, 4/3, 4/3, 1, 4/3

instr Risset_Bell
 ibasfreq = p4
 iamp = ampdb(p5)
 ifqdev = p6 ;maximum freq deviation in cents
 iampdev = p7 ;maximum amp deviation in dB
 aRisset AddSynth giFqs, giAmps, ibasfreq, 0, ifqdev, iampdev
 aRisset *= transeg:a(0, .01, 0, iamp/10, p3-.01, -10, 0)
 out aRisset, aRisset
endin

instr PlayTheBells
 iMidiPitch random 60,70
 schedule("Risset_Bell",0,random:i(2,8),mtof:i(iMidiPitch),
          random:i(-30,-10),30,6)
 if p4 > 0 then
  schedule("PlayTheBells",random:i(1/10,1/4),1,p4-1)
 endif
endin

</CsInstruments>
<CsScore>
;         base   db   frequency   amplitude
;         freq        deviation   deviation
;                      in cent     in dB
r 2 ;unchanged sound
i 1 0 5   400    -6   0           0
r 2 ;variations in frequency
i 1 0 5   400    -6   50          0
r 2 ;variations in amplitude
i 1 0 5   400    -6   0           10
s
i "PlayTheBells" 0 1 50 ;perform sequence of 50 bells
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
