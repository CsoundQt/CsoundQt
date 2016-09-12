/* Getting started.. Writing User Defined Opcodes (UDO)

As described before, opcodes can be seen as little programs. So their usefulness can be exploited in a different way.
If you've build a structure which you like to use often, it may be convenient to pack it into an "User Defined Opcode". This way you can use your own constructions later by just one keyword.

The main advantages are:
- the project has a better structure
- copy and paste mistakes can be avoided
- the final code is smaller and easier to read
- it can be re-used in other contextes
- a correction in one place fixes 

The keyword "opcode" opens the part for an user defined opcode, "endop" closes the part. Then you give your opcode it's name and define outputs and inputs.

In the following example, the Feedback-Delay used in Chapter 2 (MIDI Synth), is wrapped into an UDO. When this Echo effect is used in an Instrument, it is necessary to extend the duration by the time of echos. This extension is put into the UDO as well.

See: (OrchUDO SHIFT+F1), (opcode SHIFT+F1)
*/
 
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; Feedback Delay which forces the instrument stay active as long as the delay plays
opcode MyFeedbackDelay,a,akki		; a= one audio output / akki= one audioinput, two k-rate inputs, one i-rate	
ain, kDryWet, kDelTime, iFeedback xin	; Inputs: Audio-In, DryWet-Mix(0-1), Delay-Time(sec), Feedback-Amount (0-0.95)
iFeedback = (iFeedback > 0.95 ? 0.95 : iFeedback) ; limiting Feedback maximum to 0.95
aDelay delayr 1					; a delayline, with 1 second maximum delay-time is initialised
aWet	deltapi kDelTime				; data at a flexible position is read from the delayline 
	delayw ain+(aWet*iFeedback)		
xout (1-kDryWet) * ain + (kDryWet * aWet) ; the amount of pure-signal and delayed-signal
iNumberOfDelays = (log(0.0004) / log(iFeedback)) ; number of repeats louder than 0.0004
xtratim p7*iNumberOfDelays			; forces the instrument to wait for X Delays
endop



instr 1 						; Sine Instrument
icps = p4
iamp = p5
aSrc oscili iamp, icps, 1
aEnv madsr 0.01, 0.1, 0.0, 0.01		; percussive envelope
aDelayed init 0.0
kDryWet=p6
kDelTime=p7
iFeedback=p8
aDelayed MyFeedbackDelay aSrc*aEnv, kDryWet, kDelTime, iFeedback
outs aDelayed, aDelayed
endin
</CsInstruments>

<CsScore>
f 1 0 1024 10 1
; nr st dur freq amp d/w  d-time   Fdbk
i 1  0  1   400  0.5  0.5   0.2     0.5
i 1  2  1   600  0.6  0.8   0.1     0.8
i 1  3  1  1200  0.3  0.2   0.6     0.3
i 1  4  1   800  0.3  0.2   0.4     0.8
i 1  4  1   400  0.3  0.2   0.6     0.8
i 1  6  1   300  0.3  0.2   0.5     0.9
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>7</r>
  <g>95</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>56</x>
  <y>51</y>
  <width>266</width>
  <height>147</height>
  <uuid>{6886a8e1-368e-408c-b028-88d9716ca673}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="323" y="111" width="616" height="389" visible="true" loopStart="0" loopEnd="0">i 1 1 1 400 
i 1 2 1 
i 1 3 1 
i 1 4 1 
hi    
hi    
hi    
hi    
hi hi   
hi hi   </EventPanel>
