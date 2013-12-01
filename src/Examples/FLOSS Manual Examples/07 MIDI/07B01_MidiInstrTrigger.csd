<CsoundSynthesizer>

<CsOptions>
-Ma -odac -m0
;activates all midi devices, real time sound output, and suppress note printings
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

gisine ftgen 0,0,2^12,10,1

  instr 1 ; 1 impulse (midi channel 1)
prints "instrument/midi channel: %d%n",p1 ; print instrument number to terminal
reset:                                    ; label 'reset'
     timout 0, 1, impulse                 ; jump to 'impulse' for 1 second
     reinit reset                         ; reninitialize pass from 'reset'
impulse:                                  ; label 'impulse'
aenv expon     1, 0.3, 0.0001             ; a short percussive envelope
aSig poscil    aenv, 500, gisine          ; audio oscillator
     out       aSig                       ; audio to output
  endin

  instr 2 ; 2 impulses (midi channel 2)
prints "instrument/midi channel: %d%n",p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                 ; short delay adds another impulse
     out       aSig+a2                    ; mix two impulses at output
  endin

  instr 3 ; 3 impulses (midi channel 3)
prints "instrument/midi channel: %d%n",p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                 ; delay adds a 2nd impulse
a3   delay     a2, 0.15                   ; delay adds a 3rd impulse
     out       aSig+a2+a3                 ; mix the three impulses at output
  endin

</CsInstruments>
<CsScore>
f 0 300
e
</CsScore>
<CsoundSynthesizer>
</pre>
<h2>Using massign to Map MIDI Channels to Instruments
</h2>
<p>We can use the <a target="_blank" href="http://www.csounds.com/manual/html/massign.html">massign</a> opcode, which is used just after the header statement, to explicitly map midi channels to specific instruments and thereby overrule Csound's default mappings. <em>massign</em> takes two input arguments, the first defines the midi channel to be redirected and the second stipulates which instrument it should be directed to. The following example is identical to the previous one except that the <em>massign</em> statements near the top of the orchestra jumble up the default mappings. Midi notes on channel 1 will be mapped to instrument 3, notes on channel 2 to instrument 1 and notes on channel 3 to instrument 2. Undefined channel mappings will be mapped according to the default arrangement and once again midi notes on channels for which an instrument does not exist will be mapped to instrument 1.
  <br />
</p>
<p><strong> <em>  EXAMPLE 07B02_massign.csd</em></strong>
  <br />
</p>
<pre><CsoundSynthesizer>

<CsOptions>
-Ma -odac -m0
; activate all midi devices, real time sound output, and suppress note printing
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

gisine ftgen 0,0,2^12,10,1

massign 1,3  ; channel 1 notes directed to instr 3
massign 2,1  ; channel 2 notes directed to instr 1
massign 3,2  ; channel 3 notes directed to instr 2

  instr 1 ; 1 impulse (midi channel 1)
iChn midichn                                  ; discern what midi channel
prints "channel:%d%tinstrument: %d%n",iChn,p1 ; print instr num and midi channel
reset:                                        ; label 'reset'
     timout 0, 1, impulse                     ; jump to 'impulse' for 1 second
     reinit reset                             ; reninitialize pass from 'reset'
impulse:                                      ; label 'impulse'
aenv expon     1, 0.3, 0.0001                 ; a short percussive envelope
aSig poscil    aenv, 500, gisine              ; audio oscillator
     out       aSig                           ; send audio to output
  endin

  instr 2 ; 2 impulses (midi channel 2)
iChn midichn
prints "channel:%d%tinstrument: %d%n",iChn,p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                      ; delay generates a 2nd impulse
     out       aSig+a2                         ; mix two impulses at the output
  endin

  instr 3 ; 3 impulses (midi channel 3)
iChn midichn
prints "channel:%d%tinstrument: %d%n",iChn,p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                      ; delay generates a 2nd impulse
a3   delay     a2, 0.15                        ; delay generates a 3rd impulse
     out       aSig+a2+a3                      ; mix three impulses at output
  endin

</CsInstruments>

<CsScore>
f 0 300
e
</CsScore>

<CsoundSynthesizer>
</pre>
<p><em>massign</em> also<em> </em>has a couple of additional functions that may come in useful. A channel number of zero is interpreted as meaning 'any'. The following instruction will map notes on any and all channels to instrument 1.
</p>
<pre>massign 0,1
</pre>
<p> An instrument number of zero is interpreted as meaning 'none' so the following instruction will instruct Csound to ignore triggering for notes received on any and all channels.
</p>
<pre>massign 0,0
</pre>
<p>The above feature is useful when we want to scan midi data from an already active instrument using the <a target="_blank" href="http://www.csounds.com/manual/html/midiin.html">midiin</a> opcode, as we did in EXAMPLE 0701.csd.
</p>
<h2> Using Multiple Triggering
  <br />
</h2>
<p>Csound's <a href="http://www.csounds.com/manual/html/event.html">event</a>/<a href="http://www.csounds.com/manual/html/event_i.html">event_i</a> opcode (see the <a href="http://en.flossmanuals.net/bin/view/Csound/TriggeringInstrumentEvents">Triggering Instrument Events chapter</a>) makes it possible to trigger any other instrument from a midi-triggered one. As you can assign a fractional number to an instrument, you can distinguish the single instances from each other. This is an example for using fractional instrument numbers.
</p>
<p><strong> <em>  EXAMPLE 07B03_MidiTriggerChain.csd</em></strong>
</p>
<pre><CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -Ma
</CsOptions>
<CsInstruments>
;Example by Joachim Heintz, using code of Victor Lazzarini
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

          massign   0, 1 ;assign all incoming midi to instr 1

  instr 1 ;global midi instrument, calling instr 2.cc.nnn (c=channel, n=note number)
inote     notnum    ;get midi note number
ichn      midichn   ;get midi channel
instrnum  =         2 + ichn/100 + inote/100000 ;make fractional instr number
     ; -- call with indefinite duration
           event_i   "i", instrnum, 0, -1, ichn, inote
kend      release   ;get a "1" if instrument is turned off
 if kend == 1 then
          event     "i", -instrnum, 0, 1 ;then turn this instance off
 endif
  endin

  instr 2
ichn      =         int(frac(p1)*100)
inote     =         round(frac(frac(p1)*100)*1000)
          prints    "instr %f: ichn = %f, inote = %f%n", p1, ichn, inote
          printks   "instr %f playing!%n", 1, p1
  endin

</CsInstruments>
<CsScore>
f 0 36000
e
</CsScore>
</CsoundSynthesizer>
