<CsoundSynthesizer>
<CsOptions>
-i adc -o dac -d
</CsOptions>
<CsInstruments>
;example written by joachim heintz
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  opcode BufCrt2, ii, io ;creates a stereo buffer
ilen, inum xin ;ilen = length of the buffer (table) in seconds
iftL      ftgen     inum, 0, -(ilen*sr), 2, 0
iftR      ftgen     inum, 0, -(ilen*sr), 2, 0
          xout      iftL, iftR
  endop

  opcode BufRec1, k, aikkkk ;records to a buffer
ain, ift, krec, kstart, kend, kwrap xin
		setksmps	1
kendsmps	=		kend*sr ;end point in samples
kendsmps	=		(kendsmps == 0 || kendsmps > ftlen(ift) ? ftlen(ift) : kendsmps)
kfinished	=		0
knew		changed	krec ;1 if record just started
 if krec == 1 then
  if knew == 1 then
kndx		=		kstart * sr - 1 ;first index to write
  endif
  if kndx >= kendsmps-1 && kwrap == 1 then
kndx		=		-1
  endif
  if kndx < kendsmps-1 then
kndx		=		kndx + 1
andx		=		kndx
		tabw		ain, andx, ift
  else
kfinished	=		1
  endif
 endif
 		xout		kfinished
  endop

  opcode BufRec2, k, aaiikkkk ;records to a stereo buffer
ainL, ainR, iftL, iftR, krec, kstart, kend, kwrap xin
kfin      BufRec1     ainL, iftL, krec, kstart, kend, kwrap
kfin      BufRec1     ainR, iftR, krec, kstart, kend, kwrap
          xout        kfin
  endop

  opcode BufPlay1, ak, ikkkkkk
ift, kplay, kspeed, kvol, kstart, kend, kwrap xin
;kstart = begin of playing the buffer in seconds
;kend = end of playing in seconds. 0 means the end of the table
;kwrap = 0: no wrapping. stops at kend (positive speed) or kstart
;  (negative speed).this makes just sense if the direction does not
;  change and you just want to play the table once
;kwrap = 1: wraps between kstart and kend
;kwrap = 2: wraps between 0 and kend
;kwrap = 3: wraps between kstart and end of table
;CALCULATE BASIC VALUES
kfin		init		0
iftlen		=		ftlen(ift)/sr ;ftlength in seconds
kend		=		(kend == 0 ? iftlen : kend) ;kend=0 means end of table
kstart01	=		kstart/iftlen ;start in 0-1 range
kend01		=		kend/iftlen ;end in 0-1 range
kfqbas		=		(1/iftlen) * kspeed ;basic phasor frequency
;DIFFERENT BEHAVIOUR DEPENDING ON WRAP:
if kplay == 1 && kfin == 0 then
 ;1. STOP AT START- OR ENDPOINT IF NO WRAPPING REQUIRED (kwrap=0)
 if kwrap == 0 then
; -- phasor freq so that 0-1 values match distance start-end
kfqrel		=		kfqbas / (kend01-kstart01)
andxrel	phasor 	kfqrel ;index 0-1 for distance start-end
; -- final index for reading the table (0-1)
andx		=		andxrel * (kend01-kstart01) + (kstart01)
kfirst		init		1 ;don't check condition below at the first k-cycle (always true)
kndx		downsamp	andx
kprevndx	init		0
 ;end of table check:
  ;for positive speed, check if this index is lower than the previous one
  if kfirst == 0 && kspeed > 0 && kndx < kprevndx then
kfin		=		1
 ;for negative speed, check if this index is higher than the previous one
  else
kprevndx	=		(kprevndx == kstart01 ? kend01 : kprevndx)
   if kfirst == 0 && kspeed < 0 && kndx > kprevndx then
kfin		=		1
   endif
kfirst		=		0 ;end of first cycle in wrap = 0
  endif
 ;sound out if end of table has not yet reached
asig		table3		andx, ift, 1	
kprevndx	=		kndx ;next previous is this index
 ;2. WRAP BETWEEN START AND END (kwrap=1)
 elseif kwrap == 1 then
kfqrel		=		kfqbas / (kend01-kstart01) ;same as for kwarp=0
andxrel	phasor 	kfqrel
andx		=		andxrel * (kend01-kstart01) + (kstart01)
asig		table3		andx, ift, 1	;sound out
 ;3. START AT kstart BUT WRAP BETWEEN 0 AND END (kwrap=2)
 elseif kwrap == 2 then
kw2first	init		1
  if kw2first == 1 then ;at first k-cycle:
		reinit		wrap3phs ;reinitialize for getting the correct start phase
kw2first	=		0
  endif
kfqrel		=		kfqbas / kend01 ;phasor freq so that 0-1 values match distance start-end
wrap3phs:
andxrel	phasor 	kfqrel, i(kstart01) ;index 0-1 for distance start-end
		rireturn	;end of reinitialization
andx		=		andxrel * kend01 ;final index for reading the table
asig		table3		andx, ift, 1	;sound out
 ;4. WRAP BETWEEN kstart AND END OF TABLE(kwrap=3)
 elseif kwrap == 3 then
kfqrel		=		kfqbas / (1-kstart01) ;phasor freq so that 0-1 values match distance start-end
andxrel	phasor 	kfqrel ;index 0-1 for distance start-end
andx		=		andxrel * (1-kstart01) + kstart01 ;final index for reading the table
asig		table3		andx, ift, 1	
 endif
else ;if either not started or finished at wrap=0
asig		=		0 ;don't produce any sound
endif
  		xout		asig*kvol, kfin
  endop

  opcode BufPlay2, aak, iikkkkkk ;plays a stereo buffer
iftL, iftR, kplay, kspeed, kvol, kstart, kend, kwrap xin
aL,kfin   BufPlay1     iftL, kplay, kspeed, kvol, kstart, kend, kwrap
aR,kfin   BufPlay1     iftR, kplay, kspeed, kvol, kstart, kend, kwrap
          xout         aL, aR, kfin
  endop

  opcode In2, aa, kk ;stereo audio input
kchn1, kchn2 xin
ain1      inch      kchn1
ain2      inch      kchn2
          xout      ain1, ain2
  endop

  opcode Key, kk, k
;returns '1' just in the k-cycle a certain key has been pressed (kdown)
;  or released (kup)
kascii    xin ;ascii code of the key (e.g. 32 for space)
key,k0    sensekey
knew      changed   key
kdown     =         (key == kascii && knew == 1 && k0 == 1 ? 1 : 0)
kup       =         (key == kascii && knew == 1 && k0 == 0 ? 1 : 0)
          xout      kdown, kup
  endop

instr 1
giftL,giftR BufCrt2   3 ;creates a stereo buffer for 3 seconds
gainL,gainR In2     1,2 ;read input channels 1 and 2 and write as global audio
          prints    "PLEASE PRESS THE SPACE BAR ONCE AND GIVE AUDIO INPUT
                     ON CHANNELS 1 AND 2.\n"
          prints    "AUDIO WILL BE RECORDED AND THEN AUTOMATICALLY PLAYED
                     BACK IN SEVERAL MANNERS.\n"
krec,k0   Key       32
 if krec == 1 then
          event     "i", 2, 0, 10
 endif
endin

instr 2
; -- records the whole buffer and returns 1 at the end
kfin      BufRec2   gainL, gainR, giftL, giftR, 1, 0, 0, 0
  if kfin == 0 then
          printks   "Recording!\n", 1
  endif
 if kfin == 1 then
ispeed    random    -2, 2
istart    random    0, 1
iend      random    2, 3
iwrap     random    0, 1.999
iwrap     =         int(iwrap)
printks "Playing back with speed = %.3f, start = %.3f, end = %.3f,
                    wrap = %d\n", p3, ispeed, istart, iend, iwrap
aL,aR,kf  BufPlay2  giftL, giftR, 1, ispeed, 1, istart, iend, iwrap
  if kf == 0 then
          printks   "Playing!\n", 1
  endif
 endif
krel      release
 if kfin == 1 && kf == 1 || krel == 1 then
          printks   "PRESS SPACE BAR AGAIN!\n", p3
          turnoff
 endif
          outs      aL, aR
endin

</CsInstruments>
<CsScore>
i 1 0 1000
e
</CsScore>
</CsoundSynthesizer>
