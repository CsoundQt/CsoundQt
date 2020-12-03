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

;****DEFINE OPCODES FOR LINEAR DISTRIBUTION****

opcode linrnd_low, i, ii
 ;linear random with precedence of lower values
iMin, iMax xin
 ;generate two random values with the random opcode
iOne       random     iMin, iMax
iTwo       random     iMin, iMax
 ;compare and get the lower one
iRnd       =          iOne < iTwo ? iOne : iTwo
           xout       iRnd
endop

opcode linrnd_high, i, ii
 ;linear random with precedence of higher values
iMin, iMax xin
 ;generate two random values with the random opcode
iOne       random     iMin, iMax
iTwo       random     iMin, iMax
 ;compare and get the higher one
iRnd       =          iOne > iTwo ? iOne : iTwo
           xout       iRnd
endop


;****INSTRUMENTS FOR THE DIFFERENT DISTRIBUTIONS****

instr notes_uniform
           prints     "... instr notes_uniform playing:\n"
           prints     "EQUAL LIKELINESS OF ALL PITCHES AND DURATIONS\n"
 ;how many notes to be played
iHowMany   =          p4
 ;trigger as many instances of instr play as needed
iThisNote  =          0
iStart     =          0
 until iThisNote == iHowMany do
iMidiPch   random     36, 84 ;midi note
iDur       random     .5, 1 ;duration
           event_i    "i", "play", iStart, iDur, int(iMidiPch)
iStart     +=         iDur ;increase start
iThisNote  +=         1 ;increase counter
 enduntil
 ;reset the duration of this instr to make all events happen
p3         =          iStart + 2
 ;trigger next instrument two seconds after the last note
           event_i    "i", "notes_linrnd_low", p3, 1, iHowMany
endin

instr notes_linrnd_low
           prints     "... instr notes_linrnd_low playing:\n"
           prints     "LOWER NOTES AND LONGER DURATIONS PREFERRED\n"
iHowMany   =          p4
iThisNote  =          0
iStart     =          0
 until iThisNote == iHowMany do
iMidiPch   linrnd_low 36, 84 ;lower pitches preferred
iDur       linrnd_high .5, 1 ;longer durations preferred
           event_i    "i", "play", iStart, iDur, int(iMidiPch)
iStart     +=         iDur
iThisNote  +=         1
 enduntil
 ;reset the duration of this instr to make all events happen
p3         =          iStart + 2
 ;trigger next instrument two seconds after the last note
           event_i    "i", "notes_linrnd_high", p3, 1, iHowMany
endin

instr notes_linrnd_high
           prints     "... instr notes_linrnd_high playing:\n"
           prints     "HIGHER NOTES AND SHORTER DURATIONS PREFERRED\n"
iHowMany   =          p4
iThisNote  =          0
iStart     =          0
 until iThisNote == iHowMany do
iMidiPch   linrnd_high 36, 84 ;higher pitches preferred
iDur       linrnd_low .3, 1.2 ;shorter durations preferred
           event_i    "i", "play", iStart, iDur, int(iMidiPch)
iStart     +=         iDur
iThisNote  +=         1
 enduntil
 ;reset the duration of this instr to make all events happen
p3         =          iStart + 2
 ;call instr to exit csound
           event_i    "i", "exit", p3+1, 1
endin


;****INSTRUMENTS TO PLAY THE SOUNDS AND TO EXIT CSOUND****

instr play
 ;increase duration in random range
iDur       random     p3, p3*1.5
p3         =          iDur
 ;get midi note and convert to frequency
iMidiNote  =          p4
iFreq      cpsmidinn  iMidiNote
 ;generate note with karplus-strong algorithm
aPluck     pluck      .2, iFreq, iFreq, 0, 1
aPluck     linen      aPluck, 0, p3, p3
 ;filter
aFilter    mode       aPluck, iFreq, .1
 ;mix aPluck and aFilter according to MidiNote
 ;(high notes will be filtered more)
aMix       ntrpol     aPluck, aFilter, iMidiNote, 36, 84
 ;panning also according to MidiNote
 ;(low = left, high = right)
iPan       =          (iMidiNote-36) / 48
aL, aR     pan2       aMix, iPan
           outs       aL, aR
endin

instr exit
           exitnow
endin

</CsInstruments>
<CsScore>
i "notes_uniform" 0 1 23 ;set number of notes per instr here
;instruments linrnd_low and linrnd_high are triggered automatically
e 99999 ;make possible to perform long (exit will be automatically)
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
