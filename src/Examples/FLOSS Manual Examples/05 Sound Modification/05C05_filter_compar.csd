<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

gaOut init 0
giSpb init 0.45


; Filter types
#define MOOG_LADDER #1#
#define MOOG_VCF    #2#
#define LPF18       #3#
#define BQREZ       #4#
#define CLFILT      #5#
#define BUTTERLP    #6#
#define LOWRES      #7#
#define REZZY       #8#
#define SVFILTER    #9#
#define VLOWRES     #10#
#define STATEVAR    #11#
#define MVCLPF1     #12#
#define MVCLPF2     #13#
#define MVCLPF3     #14#


opcode Echo, 0, S
Smsg xin
    printf_i "\n%s\n\n", 1, Smsg
endop

opcode EchoFilterName, 0, i
iType xin

if iType == $MOOG_LADDER then
    Echo "moogladder"
elseif iType == $MOOG_VCF then
    Echo "moogvcf"
elseif iType == $LPF18 then
    Echo "lpf18"
elseif iType == $BQREZ then
    Echo "bqrez"
elseif iType == $CLFILT then
    Echo "clfilt"
elseif iType == $BUTTERLP then
    Echo "butterlp"
elseif iType == $LOWRES then
    Echo "lowres"
elseif iType == $REZZY then
   Echo "rezzy"
elseif iType == $SVFILTER then
  Echo "svfilter"
elseif iType == $VLOWRES then
    Echo "vlowres"
elseif iType == $STATEVAR then
    Echo "statevar"
elseif iType == $MVCLPF1 then
    Echo "mvclpf1"
elseif iType == $MVCLPF2 then
    Echo "mvclpf2"
elseif iType == $MVCLPF3 then
    Echo "mvclpf3"
else
endif
endop

opcode MultiFilter, a, akki
ain, kcfq, kres, iType xin

kType init iType
if kType == $MOOG_LADDER then
    aout    moogladder ain, kcfq, kres
elseif kType == $MOOG_VCF then
    aout    moogvcf ain, kcfq, kres
elseif kType == $LPF18 then
    aout    lpf18 ain, kcfq, kres, 0.5
elseif kType == $BQREZ then
    aout    bqrez ain, kcfq, 99 * kres + 1
elseif kType == $CLFILT then
    aout    clfilt ain, kcfq, 0, 2
elseif kType == $BUTTERLP then
    aout    butterlp ain, kcfq
elseif kType == $LOWRES then
    aout    lowres ain, kcfq, kres
elseif kType == $REZZY then
   aout     rezzy ain, kcfq, kres
elseif kType == $SVFILTER then
  aout, ahigh, aband  svfilter ain, kcfq, (499 / 10) * kres + 1 ; rescale
elseif kType == $VLOWRES then
    aout    vlowres ain, kcfq, kres, 2, 0
elseif kType == $STATEVAR then
    ahp, aout, abp, abr     statevar ain, kcfq, kres
elseif kType == $MVCLPF1 then
    aout mvclpf1 ain, kcfq, kres
elseif kType == $MVCLPF2 then
    aout mvclpf2 ain, kcfq, kres
elseif kType == $MVCLPF3 then
    aout mvclpf3 ain, kcfq, kres
else
    aout = 0
endif
    xout aout
endop


opcode Wave, a, k
kcps    xin

asqr    vco2 1, kcps * 0.495, 10      ; square
asaw    vco2 1, kcps * 1.005, 0       ; wave
        xout    0.5 * (asqr + asaw)
endop


opcode Filter, a, aiii
ain, iFilterType, iCoeff, iCps  xin

iDivision = 1 / (iCoeff * giSpb)
kLfo    loopseg iDivision, 0, 0, 0, 0.5, 1, 0.5, 0
iBase   = iCps
iMod    = iBase * 9

kcfq    = iBase + iMod * kLfo
kres    init 0.6

aout    MultiFilter ain,   kcfq, kres, iFilterType
aout    balance aout, ain

        xout aout
endop

opcode Reverb, aa, aaii
adryL, adryR, ifeedback, imix xin
awetL, awetR reverbsc adryL, adryR, ifeedback, 10000

aoutL  = (1 - imix) * adryL  + imix * awetL
aoutR  = (1 - imix) * adryR  + imix * awetR

       xout aoutL, aoutR
endop

instr Bass
    iCoeff      = p4
    iCps        = p5
    iFilterType = p6

    aWave   Wave iCps
    aOut    Filter aWave, iFilterType, iCoeff, iCps
    aOut    linen aOut, .01, p3, .1

    gaOut   = gaOut + aOut
endin

opcode Note, 0, iiii
    idt = 2 * giSpb
    iNum, iCoeff, iPch, iFilterType xin
    event_i "i", "Bass", idt * iNum, idt, iCoeff, cpspch(iPch), iFilterType
endop

instr Notes
    iFilterType = p4
    EchoFilterName iFilterType

    Note 0, 2, 6.04, iFilterType
    Note 1, 1/3, 7.04, iFilterType
    Note 2, 2, 6.04, iFilterType
    Note 3, 1/1.5, 7.07, iFilterType

    Note 4, 2, 5.09, iFilterType
    Note 5, 1, 6.09, iFilterType
    Note 6, 1/1.5, 5.09, iFilterType
    Note 7, 1/3, 6.11, iFilterType

    Note 8, 1, 6.04, iFilterType
    Note 9, 1/3, 7.04, iFilterType
    Note 10, 2, 6.04, iFilterType
    Note 11, 1/1.5, 7.07, iFilterType

    Note 12, 2, 6.09, iFilterType
    Note 13, 1, 7.09, iFilterType
    Note 14, 1/1.5, 6.11, iFilterType
    Note 15, 1/3, 6.07, iFilterType

    Note 16, 2, 6.04, iFilterType
    Note 17, 1/3, 7.04, iFilterType
    Note 18, 2, 6.04, iFilterType
    Note 19, 1/1.5, 7.07, iFilterType

    turnoff
endin

opcode TrigNotes, 0, ii
iNum, iFilterType xin
idt = 20
    event_i "i", "Notes", idt * iNum, 0, iFilterType
endop

instr PlayAll
iMixLevel = p4
event_i "i", "Main", 0, (14 * 20), iMixLevel

TrigNotes 0, $MOOG_LADDER
TrigNotes 1, $MOOG_VCF
TrigNotes 2, $LPF18
TrigNotes 3, $BQREZ
TrigNotes 4, $CLFILT
TrigNotes 5, $BUTTERLP
TrigNotes 6, $LOWRES
TrigNotes 7, $REZZY
TrigNotes 8, $SVFILTER
TrigNotes 9, $VLOWRES
TrigNotes 10, $STATEVAR
TrigNotes 11, $MVCLPF1
TrigNotes 12, $MVCLPF2
TrigNotes 13, $MVCLPF3

turnoff
endin

opcode DumpNotes, 0, iiSi
iNum, iFilterType, SFile, iMixLevel xin
idt = 20
Sstr sprintf {{i "%s" %f %f "%s" %f}}, "Dump", idt*iNum, idt, SFile, iMixLevel
        scoreline_i Sstr
        event_i "i", "Notes", idt * iNum, 0, iFilterType
endop


instr DumpAll
iMixLevel = p4

DumpNotes 0, $MOOG_LADDER,  "moogladder-dubstep.wav", iMixLevel
DumpNotes 1, $MOOG_VCF,     "moogvcf-dubstep.wav",  iMixLevel
DumpNotes 2, $LPF18 ,       "lpf18-dubstep.wav",    iMixLevel
DumpNotes 3, $BQREZ,        "bqrez-dubstep.wav",    iMixLevel
DumpNotes 4, $CLFILT,       "clfilt-dubstep.wav",   iMixLevel
DumpNotes 5, $BUTTERLP,     "butterlp-dubstep.wav", iMixLevel
DumpNotes 6, $LOWRES,       "lowres-dubstep.wav",   iMixLevel
DumpNotes 7, $REZZY,        "rezzy-dubstep.wav",    iMixLevel
DumpNotes 8, $SVFILTER,     "svfilter-dubstep.wav", iMixLevel
DumpNotes 9, $VLOWRES ,     "vlowres-dubstep.wav",  iMixLevel
DumpNotes 10, $STATEVAR,    "statevar-dubstep.wav", iMixLevel
DumpNotes 11, $MVCLPF1 ,    "mvclpf1-dubstep.wav",  iMixLevel
DumpNotes 12, $MVCLPF2 ,    "mvclpf2-dubstep.wav",  iMixLevel
DumpNotes 13, $MVCLPF3 ,    "mvclpf3-dubstep.wav",  iMixLevel

turnoff
endin

instr Dump
SFile       = p4
iMixLevel   = p5

iVolume     = 0.2
iReverbFeedback = 0.85

aoutL, aoutR Reverb gaOut, gaOut, iReverbFeedback, iMixLevel
fout SFile, 14, (iVolume * aoutL), (iVolume * aoutR)
endin

instr Main
iVolume = 0.2
iReverbFeedback = 0.3
iMixLevel       = p4

aoutL, aoutR Reverb gaOut, gaOut, iReverbFeedback, iMixLevel
outs (iVolume * aoutL), (iVolume * aoutR)

gaOut = 0
endin

</CsInstruments>
<CsScore>
; the fourth parameter is a reverb mix level
i "PlayAll" 0 1 0.35
; uncomment to save output to wav files
;i "DumpAll" 0 1 0.35
</CsScore>
</CsoundSynthesizer>
;example by Anton Kholomiov
;based on the Jacob Joaquin wobble bass sound
