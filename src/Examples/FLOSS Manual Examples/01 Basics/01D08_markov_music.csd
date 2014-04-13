<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -dnm128 -odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 2
seed 0

;****USER DEFINED OPCODES FOR MARKOV CHAINS****
  opcode Markov, i, i[][]i
iMarkovTable[][], iPrevEl xin
iRandom    random     0, 1
iNextEl    =          0
iAccum     =          iMarkovTable[iPrevEl][iNextEl]
 until iAccum >= iRandom do
iNextEl    +=         1
iAccum     +=         iMarkovTable[iPrevEl][iNextEl]
 enduntil
           xout       iNextEl
  endop
  opcode Markovk, k, k[][]k
kMarkovTable[][], kPrevEl xin
kRandom    random     0, 1
kNextEl    =          0
kAccum     =          kMarkovTable[kPrevEl][kNextEl]
 until kAccum >= kRandom do
kNextEl    +=         1
kAccum     +=         kMarkovTable[kPrevEl][kNextEl]
 enduntil
           xout       kNextEl
  endop

;****DEFINITIONS FOR NOTES****
 ;notes as proportions and a base frequency
giNotes[]  array      1, 9/8, 6/5, 5/4, 4/3, 3/2, 5/3
giBasFreq  =          330
 ;probability of notes as markov matrix:
  ;first -> only to third and fourth
  ;second -> anywhere without self
  ;third -> strong probability for repetitions
  ;fourth -> idem
  ;fifth -> anywhere without third and fourth
  ;sixth -> mostly to seventh
  ;seventh -> mostly to sixth
giProbNotes[][] init  7, 7
giProbNotes array     0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0,
                      0.2, 0.0, 0.2, 0.2, 0.2, 0.1, 0.1,
                      0.1, 0.1, 0.5, 0.1, 0.1, 0.1, 0.0,
                      0.0, 0.1, 0.1, 0.5, 0.1, 0.1, 0.1,
                      0.2, 0.2, 0.0, 0.0, 0.2, 0.2, 0.2,
                      0.1, 0.1, 0.0, 0.0, 0.1, 0.1, 0.6,
                      0.1, 0.1, 0.0, 0.0, 0.1, 0.6, 0.1

;****DEFINITIONS FOR DURATIONS****
 ;possible durations
gkDurs[]    array     1, 1/2, 1/3
 ;probability of durations as markov matrix:
  ;first -> anything
  ;second -> mostly self
  ;third -> mostly second
gkProbDurs[][] init   3, 3
gkProbDurs array      1/3, 1/3, 1/3,
                      0.2, 0.6, 0.3,
                      0.1, 0.5, 0.4

;****SET FIRST NOTE AND DURATION FOR MARKOV PROCESS****
giPrevNote init       1
gkPrevDur  init       1

;****INSTRUMENT FOR DURATIONS****
  instr trigger_note
kTrig      metro      1/gkDurs[gkPrevDur]
 if kTrig == 1 then
           event      "i", "select_note", 0, 1
gkPrevDur  Markovk    gkProbDurs, gkPrevDur
 endif
  endin

;****INSTRUMENT FOR PITCHES****
  instr select_note
 ;choose next note according to markov matrix and previous note
 ;and write it to the global variable for (next) previous note
giPrevNote Markov     giProbNotes, giPrevNote
 ;call instr to play this note
           event_i    "i", "play_note", 0, 2, giPrevNote
 ;turn off this instrument
           turnoff
  endin

;****INSTRUMENT TO PERFORM ONE NOTE****
  instr play_note
 ;get note as index in ginotes array and calculate frequency
iNote      =          p4
iFreq      =          giBasFreq * giNotes[iNote]
 ;random choice for mode filter quality and panning
iQ         random     10, 200
iPan       random     0.1, .9
 ;generate tone and put out
aImp       mpulse     1, p3
aOut       mode       aImp, iFreq, iQ
aL, aR     pan2       aOut, iPan
           outs       aL, aR
  endin

</CsInstruments>
<CsScore>
i "trigger_note" 0 100
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz 
