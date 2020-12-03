<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

opcode Chan,S,Si
 Sname, id xin
 Sout sprintf "%s_%d", Sname, id
 xout Sout
endop

giSample ftgen 0, 0, 0, -1, "fox.wav", 0, 0, 1
giSinc ftgen 0, 0, 1024, 20, 9, 1
gi_ID init 1

instr Quick
 id = gi_ID
 gi_ID += 1
 iStart = .2
 chnset(1/100, Chan("PointerSpeed",id))
 chnset(linseg:k(10,p3,1), Chan("GrainDur",id))
 chnset(randomi:k(15,20,1/3,3), Chan("Density",id))
 chnset(linseg:k(7000,p3/2,6000), Chan("Transpos",id))
 chnset(600,Chan("TransposRndDev",id))
 chnset(linseg:k(-10,p3-3,-10,3,-30), Chan("Volume",id))
 chnset(randomi:k(.2,.8,1,3), Chan("Pan",id))
 chnset(.2,Chan("PanRndDev",id))
 schedule("Granulator",0,p3,id,iStart)
 schedule("Output",0,p3,id,0)
endin

instr Brown
 id = gi_ID
 gi_ID += 1
 iStart = .42
 chnset(1/100, Chan("PointerSpeed",id))
 chnset(50, Chan("GrainDur",id))
 chnset(50, Chan("Density",id))
 chnset(100,Chan("TransposRndDev",id))
 chnset(linseg:k(-50,3,-10,12,-10,3,-50), Chan("Volume",id))
 chnset(.5, Chan("Pan",id))
 schedule("Granulator",0,p3,id,iStart)
 schedule("Output",0,p3+3,id,.3)
endin

instr F
 id = gi_ID
 gi_ID += 1
 iStart = .68
 chnset(50, Chan("GrainDur",id))
 chnset(40, Chan("Density",id))
 chnset(100,Chan("TransposRndDev",id))
 chnset(linseg:k(-30,3,-10,p3-6,-10,3,-30)+randomi:k(-10,10,1/3),
                 Chan("Volume",id))
 chnset(.5, Chan("Pan",id))
 chnset(.5, Chan("PanRndDev",id))
 schedule("Granulator",0,p3,id,iStart)
 schedule("Output",0,p3+3,id,.9)
endin

instr Ox
 id = gi_ID
 gi_ID += 1
 iStart = .72
 chnset(1/100,Chan("PointerSpeed",id))
 chnset(50, Chan("GrainDur",id))
 chnset(40, Chan("Density",id))
 chnset(-2000,Chan("Transpos",id))
 chnset(linseg:k(-20,3,-10,p3-6,-10,3,-30)+randomi:k(-10,0,1/3),
        Chan("Volume",id))
 chnset(randomi:k(.2,.8,1/5,2,.8), Chan("Pan",id))
 schedule("Granulator",0,p3,id,iStart)
 schedule("Output",0,p3+3,id,.9)
endin

instr Jum
 id = gi_ID
 gi_ID += 1
 iStart = 1.3
 chnset(0.01,Chan("PointerRndDev",id))
 chnset(50, Chan("GrainDur",id))
 chnset(40, Chan("Density",id))
 chnset(transeg:k(p4,p3/3,0,p4,p3/2,5,3*p4),Chan("Transpos",id))
 chnset(linseg:k(0,1,-10,p3-7,-10,6,-50)+randomi:k(-10,0,1,3),
        Chan("Volume",id))
 chnset(p5, Chan("Pan",id))
 schedule("Granulator",0,p3,id,iStart)
 schedule("Output",0,p3+3,id,.7)
 if p4 < 300 then
  schedule("Jum",0,p3,p4+500,p5+.3)
 endif
endin

instr Whole
 id = gi_ID
 gi_ID += 1
 iStart = 0
 chnset(1/2,Chan("PointerSpeed",id))
 chnset(5, Chan("GrainDur",id))
 chnset(20, Chan("Density",id))
 chnset(.5, Chan("Pan",id))
 chnset(.3, Chan("PanRndDev",id))
 schedule("Granulator",0,p3,id,iStart)
 schedule("Output",0,p3+1,id,0)
endin

instr Granulator
 //get ID for resolving string channels
 id = p4
 //standard input parameter
 iSndTab = giSample
 iSampleLen = ftlen(iSndTab)/sr
 iStart = p5
 kPointerSpeed = chnget:k(Chan("PointerSpeed",id))
 kGrainDur = chnget:k(Chan("GrainDur",id))
 kTranspos = chnget:k(Chan("Transpos",id))
 kVolume = chnget:k(Chan("Volume",id))
 iEnv = giSinc
 kPan = chnget:k(Chan("Pan",id))
 kDensity = chnget:k(Chan("Density",id))
 iDistribution = 1
 //random deviations
 kPointerRndDev = chnget:k(Chan("PointerRndDev",id))
 kTransposRndDev = chnget:k(Chan("TransposRndDev",id))
 kPanRndDev = chnget:k(Chan("PanRndDev",id))
 //perform
 kPhasor = phasor:k(kPointerSpeed/iSampleLen,iStart/iSampleLen)
 kTrig = metro(kDensity)
 if kTrig==1 then
  kPointer = kPhasor*iSampleLen + rnd31:k(kPointerRndDev,0)
  kOffset = random:k(0,iDistribution/kDensity)
  kTranspos = cent(kTranspos+rnd31:k(kTransposRndDev,0))
  kPan = kPan+rnd31:k(kPanRndDev,0)
  schedulek("Grain",kOffset,kGrainDur/1000,iSndTab,iSampleLen,
            kPointer,kTranspos,kVolume,iEnv,kPan,id)
 endif
endin

instr Grain
 //input parameters
 iSndTab = p4
 iSampleLen = p5
 iStart = p6
 iSpeed = p7
 iVolume = p8
 iEnvTab = p9
 iPan = p10
 id = p11
 //perform
 aEnv = poscil3:a(ampdb(iVolume),1/p3,iEnvTab)
 aSound = poscil3:a(aEnv,iSpeed/iSampleLen,iSndTab,iStart/iSampleLen)
 aL, aR pan2 aSound, iPan
 //write audio to channels for id
 chnmix(aL,Chan("L",id))
 chnmix(aR,Chan("R",id))
endin

instr Output
 id = p4
 iRvrbTim = p5
 aL_dry = chnget:a(Chan("L",id))
 aR_dry = chnget:a(Chan("R",id))
 aL_wet, aR_wet reverbsc aL_dry, aR_dry, iRvrbTim,sr/2
 out(aL_dry+aL_wet,aR_dry+aR_wet)
 chnclear(Chan("L",id),Chan("R",id))
endin

</CsInstruments>
<CsScore>
i "Quick" 0 20
i "Brown" 10 20
i "F" 20 50
i "Ox" 30 40
i "Jum" 72 30 -800 .2
i "Quick" 105 10
i "Whole" 118 5.4
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
