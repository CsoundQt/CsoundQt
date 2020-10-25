<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

;****POSSIBLE DURATIONS AS ARRAY****
giDurs[]   array      3/2, 1, 2/3, 1/2, 1/3, 1/4
giLenDurs  lenarray   giDurs

;****POSSIBLE PITCHES AS ARRAY****
 ;initialize array with 31 steps
giScale[]  init       31
giLenScale lenarray   giScale
 ;iterate to fill from 65 hz onwards
iStart     =          65
iDenom     =          3 ;start with 3/2
iCnt       =          0
 until iCnt = giLenScale do
giScale[iCnt] =       iStart
iStart     =          iStart * iDenom / (iDenom-1)
iDenom     +=         1 ;next proportion is 4/3 etc
iCnt       +=         1
 enduntil

;****SEQUENCE OF UNITS AS ARRAY****
giSequence[] array    0, 1.2, 1.4, 2.2, 2.4, 3.2, 3.6
giSeqIndx  =          0 ;startindex

;****UDO DEFINITIONS****
opcode linrnd_low, i, iii
 ;linear random with precedence of lower values
iMin, iMax, iMaxCount xin
 ;set counter and initial (absurd) result
iCount     =          0
iRnd       =          iMax
 ;loop and reset iRnd
 until iCount == iMaxCount do
iUniRnd    random     iMin, iMax
iRnd       =          iUniRnd < iRnd ? iUniRnd : iRnd
iCount += 1
enduntil
           xout       iRnd
endop

opcode linrnd_high, i, iii
 ;linear random with precedence of higher values
iMin, iMax, iMaxCount xin
 ;set counter and initial (absurd) result
iCount     =          0
iRnd       =          iMin
 ;loop and reset iRnd
 until iCount == iMaxCount do
iUniRnd    random     iMin, iMax
iRnd       =          iUniRnd > iRnd ? iUniRnd : iRnd
iCount += 1
enduntil
           xout       iRnd
endop

opcode trirnd, i, iii
iMin, iMax, iMaxCount xin
 ;set a counter and accumulator
iCount     =          0
iAccum     =          0
 ;perform loop and accumulate
 until iCount == iMaxCount do
iUniRnd    random     iMin, iMax
iAccum += iUniRnd
iCount += 1
enduntil
 ;get the mean and output
iRnd       =          iAccum / iMaxCount
           xout       iRnd
endop

;****ONE INSTRUMENT TO PERFORM ALL DISTRIBUTIONS****
;0 = uniform, 1 = linrnd_low, 2 = linrnd_high, 3 = trirnd
;the fractional part denotes the number of units, e.g.
;3.4 = triangular distribution with four sub-units

instr notes
 ;how many notes to be played
iHowMany   =          p4
 ;by which distribution with how many units
iWhich     =          giSequence[giSeqIndx]
iDistrib   =          int(iWhich)
iUnits     =          round(frac(iWhich) * 10)

 ;trigger as many instances of instr play as needed
iThisNote  =          0
iStart     =          0
iPrint     =          1

 ;for each note to be played
 until iThisNote == iHowMany do

  ;calculate iMidiPch and iDur depending on type
  if iDistrib == 0 then
printf_i   "%s", iPrint, "... uniform distribution:\n"
printf_i   "%s", iPrint, "EQUAL LIKELINESS OF ALL PITCHES AND DURATIONS\n"
iScaleIndx random     0, giLenScale-.0001 ;midi note
iDurIndx   random     0, giLenDurs-.0001 ;duration
  elseif iDistrib == 1 then
printf_i   "... linear low distribution with %d units:\n", iPrint, iUnits
printf_i   "%s", iPrint, "LOWER NOTES AND LONGER DURATIONS PREFERRED\n"
iScaleIndx linrnd_low 0, giLenScale-.0001, iUnits
iDurIndx   linrnd_low 0, giLenDurs-.0001, iUnits
  elseif iDistrib == 2 then
printf_i   "... linear high distribution with %d units:\n", iPrint, iUnits
printf_i   "%s", iPrint, "HIGHER NOTES AND SHORTER DURATIONS PREFERRED\n"
iScaleIndx linrnd_high 0, giLenScale-.0001, iUnits
iDurIndx   linrnd_high 0, giLenDurs-.0001, iUnits
           else
printf_i   "... triangular distribution with %d units:\n", iPrint, iUnits
printf_i   "%s", iPrint, "MEDIUM NOTES AND DURATIONS PREFERRED\n"
iScaleIndx trirnd     0, giLenScale-.0001, iUnits
iDurIndx   trirnd     0, giLenDurs-.0001, iUnits
  endif

 ;call subinstrument to play note
iDur       =          giDurs[int(iDurIndx)]
iPch       =          giScale[int(iScaleIndx)]
           event_i    "i", "play", iStart, iDur, iPch

 ;increase start time and counter
iStart     +=         iDur
iThisNote  +=         1
 ;avoid continuous printing
iPrint     =          0
enduntil

 ;reset the duration of this instr to make all events happen
p3         =          iStart + 2

 ;increase index for sequence
giSeqIndx += 1
 ;call instr again if sequence has not been ended
 if giSeqIndx < lenarray(giSequence) then
           event_i    "i", "notes", p3, 1, iHowMany
 ;or exit
           else
           event_i    "i", "exit", p3, 1
 endif
endin

;****INSTRUMENTS TO PLAY THE SOUNDS AND EXIT CSOUND****
instr play
 ;increase duration in random range
iDur       random     p3*2, p3*5
p3         =          iDur
 ;get frequency
iFreq      =          p4
 ;generate note with karplus-strong algorithm
aPluck     pluck      .2, iFreq, iFreq, 0, 1
aPluck     linen      aPluck, 0, p3, p3
 ;filter
aFilter    mode       aPluck, iFreq, .1
 ;mix aPluck and aFilter according to freq
 ;(high notes will be filtered more)
aMix       ntrpol     aPluck, aFilter, iFreq, 65, 65*16
 ;panning also according to freq
 ;(low = left, high = right)
iPan       =          (iFreq-65) / (65*16)
aL, aR     pan2       aMix, iPan
           outs       aL, aR
endin

instr exit
           exitnow
endin
</CsInstruments>
<CsScore>
i "notes" 0 1 23 ;set number of notes per instr here
e 99999 ;make possible to perform long (exit will be automatically)
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz