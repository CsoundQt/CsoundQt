<CsoundSynthesizer>

<CsOptions>
-Ma -odac
; activate all MIDI devices
</CsOptions>

<CsInstruments>
; 'sr' and 'nchnls' are irrelevant so are omitted
ksmps = 32

  instr 1
kCtrl    ctrl7    1,1,0,127    ; read in controller 1 on channel 1
kTrigger changed  kCtrl        ; if 'kCtrl' changes generate a trigger ('bang')
 if kTrigger=1 then
; Print kCtrl to console with formatting, but only when its value changes.
printks "Controller Value: %d%n", 0, kCtrl
 endif
  endin

</CsInstruments>

<CsScore>
i 1 0 3600
e
</CsScore>

<CsoundSynthesizer>
</pre>
<p> There are also 14 bit and 21 bit versions of <em>ctrl7 </em>(<a href="http://www.csounds.com/manual/html/ctrl14.html">ctrl14</a> and <a href="http://www.csounds.com/manual/html/ctrl21.html">ctrl21</a>) which improve upon the 7 bit resolution of 'ctrl7' but hardware that outputs 14 or 21 bit controller information is rare so these opcodes are seldom used.
</p>
<h2>Scanning Pitch Bend and Aftertouch
</h2>
<p>We can scan pitch bend and aftertouch in a similar way by using the opcodes <a href="http://www.csounds.com/manual/html/pchbend.html">pchbend</a> and <a href="http://www.csounds.com/manual/html/aftouch.html">aftouch</a>. Once again we can specify minimum and maximum values with which to rescale the output. In the case of 'pchbend' we specify the value it outputs when the pitch bend wheel is at rest followed by a value which defines the entire range from when it is pulled to its minimum to when it is pushed to its maximum. In this example, playing a key on the keyboard will play a note, the pitch of which can be bent up or down two semitones by using the pitch bend wheel. Aftertouch can be used to modify the amplitude of the note while it is playing. Pitch bend and aftertouch data is also printed at the terminal whenever they change. One thing to bear in mind is that for 'pchbend' to function the Csound instrument that contains it needs to have been activated by a MIDI event, i.e. you will need to play a midi note on your keyboard and then move the pitch bend wheel.
</p>
<p>
</p>
<p><strong><em>  EXAMPLE 07C02_pchbend_aftouch.csd</em></strong>
</p>
<pre><CsoundSynthesizer>

<CsOptions>
-odac -Ma
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine  ftgen  0,0,2^10,10,1  ; a sine wave

  instr 1
; -- pitch bend --
kPchBnd  pchbend  0,4                ; read in pitch bend (range -2 to 2)
kTrig1   changed  kPchBnd            ; if 'kPchBnd' changes generate a trigger
 if kTrig1=1 then
printks "Pitch Bend:%f%n",0,kPchBnd  ; print kPchBnd to console when it changes
 endif

; -- aftertouch --
kAfttch  aftouch 0,0.9               ; read in aftertouch (range 0 to 0.9)
kTrig2   changed kAfttch             ; if 'kAfttch' changes generate a trigger
 if kTrig2=1 then
printks "Aftertouch:%d%n",0,kAfttch  ; print kAfttch to console when it changes
 endif

; -- create a sound --
iNum     notnum                      ; read in MIDI note number
; MIDI note number + pitch bend are converted to cycles per seconds
aSig     poscil   0.1,cpsmidinn(iNum+kPchBnd),giSine
         out      aSig               ; audio to output
  endin

</CsInstruments>

<CsScore>
f 0 300
e
</CsScore>

<CsoundSynthesizer>
</pre>
<h2>Initialising MIDI Controllers
</h2>
<p>It may be useful to be able to define the initial value of a midi controller, that is, the value any ctrl7s will adopt until their corresponding hardware controls have been moved. Midi hardware controls only send messages when they change so until this happens their values in Csound defaults to their minimum settings unless additional initialisation has been carried out. As an example, if we imagine we have a Csound instrument in which the output volume is controlled by a midi controller it might prove to be slightly frustrating that each time the orchestra is launched, this instrument will remain silent until the volume control is moved. This frustration might become greater when many midi controllers are begin utilised. It would be more useful to be able to define the starting value for each of these controllers. The <a href="http://www.csounds.com/manual/html/initc7.html">initc7</a> opcode allows us to do this. If initc7 is placed within the instrument itself it will be reinitialised each time the instrument is called, if it is placed in instrument 0 (just after the header statements) then it will only be initialised when the orchestra is first launched. The latter case is probably most useful.
</p>
<p>In the following example a simple synthesizer is created. Midi controller 1 controls the output volume of this instrument but the initc7 <span style="font-style: italic;"></span>statement near the top of the orchestra ensures that this control does not default to its minimum setting. The arguments that initc7 takes are for midi channel, controller number and initial value. Initial value is defined within the range 0-1, therefore a value of 1 will set this controller to its maximum value (midi value 127), and a value of 0.5 will set it to its halfway value (midi value 64), and so on.
</p>
<p>Additionally this example uses the <a href="http://www.csounds.com/manual/html/cpsmidi.html">cpsmidi</a> opcode to scan midi pitch (basically converting midi note numbers to cycles-per-second) and the <a href="http://www.csounds.com/manual/html/ampmidi.html">ampmidi</a> opcode to scan and rescale key velocity.
</p>
<p><strong><em><em>  EXAMPLE 07C03_cpsmidi_ampmidi.csd</em></em></strong>
</p>
<pre><CsoundSynthesizer>

<CsOptions>
-Ma -odac
; activate all midi inputs and real-time audio output
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine ftgen 0,0,2^12,10,1 ; a sine wave
initc7 1,1,1               ; initialize CC 1 on chan. 1 to its max level

  instr 1
iCps cpsmidi               ; read in midi pitch in cycles-per-second
iAmp ampmidi 1             ; read in key velocity. Rescale to be from 0 to 1
kVol ctrl7   1,1,0,1       ; read in CC 1, chan 1. Rescale to be from 0 to 1
aSig poscil  iAmp*kVol, iCps, giSine ; an audio oscillator
     out     aSig          ; send audio to output
  endin

</CsInstruments>

<CsScore>
f 0 3600
e
</CsScore>

<CsoundSynthesizer>
</pre>
<p>You will maybe hear that this instrument produces 'clicks' as notes begin and end. To find out how to prevent this see the section on envelopes with release sensing in the chapter <a href="http://en.flossmanuals.net/csound/ch031_a-envelopes/">Sound Modification: Envelopes</a>.
  <br />
</p>
<h2>Smoothing 7-bit Quantisation in MIDI Controllers
</h2>
<p> A problem we encounter with 7 bit midi controllers is the poor resolution that they offer us. 7 bit means that we have 2 to the power of 7 possible values; therefore 128 possible values, which is rather inadequate for defining, for example, the frequency of an oscillator over a number of octaves, the cutoff frequency of a filter or a quickly moving volume control. We soon become aware of the parameter that is being changed moving in steps - so not really a 'continuous' controller. We may also experience clicking artefacts, sometimes called 'zipper noise', as the value changes. The extent of this will depend upon the parameter being controlled. There are some things we can do to address this problem. We can filter the controller signal within Csound so that the sudden changes that occur between steps along the controller's travel are smoothed using additional interpolating values - we must be careful not to smooth excessively otherwise the response of the controller will become sluggish. Any k-rate compatible lowpass filter can be used for this task but the <a href="http://www.csounds.com/manual/html/portk.html">portk</a> opcode is particularly useful as it allows us to define the amount of smoothing as a time taken to glide to half the required value rather than having to specify a cutoff frequency. Additionally this 'half time' value can be varied at k-rate which provides an advantage availed of in the following example.
</p>
<p>This example takes the simple synthesizer of the previous example as its starting point. The volume control, which is controlled by midi controller 1 on channel 1, is passed through a 'portk' filter. The 'half time' for 'portk'<em></em> ramps quickly up to its required value of 0.01 through the use of a <a href="http://www.csounds.com/manual/html/linseg.html">linseg</a> statement in the previous line. This ensures that when a new note begins the volume control immediately jumps to its required value rather than gliding up from zero as would otherwise be affected by the 'portk'<em></em> filter. Try this example with the 'portk'<em></em> half time defined as a constant to hear the difference. To further smooth the volume control, it is converted to an a-rate variable through the use of the <a href="http://www.csounds.com/manual/html/interp.html">interp</a> opcode which, as well as performing this conversion, interpolates values in the gaps between k-cycles.
</p>
<p><strong><em><em>  EXAMPLE 07C04_smoothing.csd</em></em></strong>
</p>
<pre><CsoundSynthesizer>
<CsOptions>
-Ma -odac
</CsOptions>
<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen    0,0,2^12,10,1
         initc7   1,1,1          ; initialize CC 1 to its max. level

  instr 1
iCps      cpsmidi                ; read in midi pitch in cycles-per-second
iAmp      ampmidi 1              ; read in note velocity - re-range 0 to 1
kVol      ctrl7   1,1,0,1        ; read in CC 1, chan. 1. Re-range from 0 to 1
kPortTime linseg  0,0.001,0.01   ; create a value that quickly ramps up to 0.01
kVol      portk   kVol,kPortTime ; create a filtered version of kVol
aVol      interp  kVol           ; create an a-rate version of kVol
aSig      poscil  iAmp*aVol,iCps,giSine
          out     aSig
  endin

</CsInstruments>
<CsScore>
f 0 300
e
</CsScore>
<CsoundSynthesizer>
</pre>
<p>All of the techniques introduced in this section are combined in the final example which includes a 2-semitone pitch bend and tone control which is controlled by aftertouch. For tone generation this example uses the <a href="http://www.csounds.com/manual/html/gbuzz.html">gbuzz</a> opcode.
</p>
<p><strong><em><em>  EXAMPLE 07C05_MidiControlComplex.csd</em></em></strong>
</p>
<pre><CsoundSynthesizer>

<CsOptions>
-Ma -odac
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giCos   ftgen    0,0,2^12,11,1 ; a cosine wave
         initc7   1,1,1        ; initialize controller to its maximum level

  instr 1
iNum      notnum                   ; read in midi note number
iAmp      ampmidi 0.1              ; read in note velocity - range 0 to 0.2
kVol      ctrl7   1,1,0,1          ; read in CC 1, chan. 1. Re-range from 0 to 1
kPortTime linseg  0,0.001,0.01     ; create a value that quickly ramps up to 0.01
kVol      portk   kVol, kPortTime  ; create filtered version of kVol
aVol      interp  kVol             ; create an a-rate version of kVol.
iRange    =       2                ; pitch bend range in semitones
iMin      =       0                ; equilibrium position
kPchBnd	  pchbend iMin, 2*iRange   ; pitch bend in semitones (range -2 to 2)
kPchBnd   portk   kPchBnd,kPortTime; create a filtered version of kPchBnd
aEnv      linsegr 0,0.005,1,0.1,0  ; amplitude envelope with release stage
kMul      aftouch 0.4,0.85         ; read in aftertouch
kMul      portk   kMul,kPortTime   ; create a filtered version of kMul
; create an audio signal using the 'gbuzz' additive synthesis opcode
aSig      gbuzz   iAmp*aVol*aEnv,cpsmidinn(iNum+kPchBnd),70,0,kMul,giCos
          out     aSig             ; audio to output
  endin

</CsInstruments>

<CsScore>
f 0 300
e
</CsScore>

<CsoundSynthesizer>
</pre>
<h2> RECORDING CONTROLLER DATA
</h2>
<p>Data performed on a controller or controllers can be recorded into GEN tables or arrays so that a real-time interaction with a Csound instrument can be replayed at a later time. This can be preferable to recording the audio output, as this will allow the controller data to be modified. The simplest approach is to simply store each controller value every k-cycle into sequential locations in a function table but this is rather wasteful as controllers will frequently remain unchanged from k-cycle to k-cycle.
  <br />A more efficient approach is to store values only when they change and to time stamp those events to that they can be replayed later on in the right order and at the right speed. In this case data will be written to a function table in pairs: time-stamp followed by a value for each new event ('event' refers to when a controller changes). This method does not store durations of each event, merely when they happen, therefore it will not record how long the final event lasts until recording stopped. This may or may not be critical depending on how the recorded controller data is used later on but in order to get around this, the following example stores the duration of the complete recording at index location 0 so that we can derive the duration of the last event. Additionally the first event stored at index location 1 is simply a value: the initial value of the controller (the time stamp for this would always be zero anyway). Thereafter events are stored as time-stamped pairs of data: index 2=time stamp, index 3=associated value and so on.
  <br />To use the following example, activate 'Record', move the slider around and then deactivate 'Record'. This gesture can now be replayed using the 'Play' button. As well as moving the GUI slider, a tone is produced, the pitch of which is controlled by the slider.
  <br />Recorded data in the GEN table can also be backed up onto the hard drive using ftsave and recalled in a later session using ftload. Note that ftsave also has the capability of storing multiple function tables in a single file.
</p>
<p><strong><em><em> EXAMPLE 07C06_RecordingController.csd</em></em></strong>
</p>
<pre><CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -dm0
</CsOptions>

<CsInstruments>

sr     = 44100
ksmps  = 8
nchnls = 1
0dbfs  = 1

FLpanel "Record Gesture",500,90,0,0
gkRecord,gihRecord FLbutton "Rec/Stop",1,0,22,100,25,  5, 5,-1
gkPlay,gihPlay  FLbutton "Play",    1,0,22,100,25,110, 5,-1
gksave,ihsave  FLbutton "Save to HD", 1,0,21,100,25,290,5,0,4,0,0
gkload,ihload  FLbutton "Load from HD", 1,0,21,100,25,395,5,0,5,0,0
gkval, gihval  FLslider "Control", 0,1, 0,23, -1,490,25, 5,35
FLpanel_end
FLrun

gidata ftgen 1,0,1048576,-2,0 ; Table for controller data.

opcode RecordController,0,Ki
 kval,ifn        xin
 i_      ftgen   1,0,ftlen(ifn),-2,0             ; erase table
 tableiw i(kval),1,ifn           ; write initial value at index 1.
         ;(Index 0 will be used be storing the complete gesture duration.)
 kndx    init    2         ; Initialise index
 kTime   timeinsts         ; time since this instrument started in seconds
; Write a data event only when the input value changes
if changed(kval)==1 && kndx<=(ftlen(ifn)-2) && kTime>0 then
; Write timestamp to table location defined by current index.
  tablew kTime, kndx, ifn
; Write slider value to table location defined by current index.
  tablew kval, kndx + 1, ifn
; Increment index 2 steps (one for time, one for value).
  kndx   =       kndx + 2
 endif
; sense note release
 krel    release
; if we are in the final k-cycle before the note ends
 if(krel==1) then
; write total gesture duration into the table at index 0
  tablew kTime,0,ifn
 endif
endop

opcode PlaybackController,k,i
 ifn     xin
 ; read first value
; initial controller value read from index 1
 ival    table   1,ifn
; initial value for k-rate output
 kval    init    ival
; Initialise index to first non-zero timestamp
 kndx    init    2
; time in seconds since this note started
 kTime   timeinsts
; first non-zero timestamp
 iTimeStamp      tablei  2,ifn
; initialise k-variable for first non-zero timestamp
 kTimeStamp      init    iTimeStamp
; if we have reached the timestamp value...
 if kTime>=kTimeStamp && kTimeStamp>0 then
; ...Read value from table defined by current index.
  kval   table   kndx+1,ifn
  kTimeStamp     table   kndx+2,ifn              ; Read next timestamp
; Increment index. (Always 2 steps: timestamp and value.)
  kndx   limit   kndx+2, 0, ftlen(ifn)-2
 endif
         xout    kval
endop

; cleaner way to start instruments than using FLbutton built-in mechanism
instr   1
; trigger when button value goes from off to on
 kOnTrig trigger gkRecord,0.5,0
; start instrument with a held note when trigger received
 schedkwhen      kOnTrig,0,0,2,0,-1
; trigger when button value goes from off to on
 kOnTrig trigger gkPlay,0.5,0
; start instrument with a held note when trigger received
 schedkwhen      kOnTrig,0,0,3,0,-1
endin

instr   2       ; Record gesture
 if gkRecord==0 then            ; If record button is deactivated...
  turnoff                       ; ...turn this instrument off.
 endif
; call UDO
         RecordController        gkval,gidata
; Generate a sound.
 kporttime       linseg  0,0.001,0.02
 kval    portk   gkval,kporttime
 asig    poscil  0.2,cpsoct((kval*2)+7)
         out     asig

endin

instr   3       ; Playback recorded gesture
 if gkPlay==0 then                 ; if play button is deactivated...
  turnoff                          ; ...turn this instrument off.
 endif
 kval    PlaybackController      gidata
; send initial value to controller
         FLsetVal_i      i(kval),gihval
; Send values to slider when needed.
         FLsetVal        changed(kval),kval,gihval
 ; Generate a sound.
 kporttime       linseg  0,0.001,0.02
 kval    portk   gkval,kporttime
 asig    poscil  0.2,cpsoct((kval*2)+7)
         out     asig
 ; stop note when end of table reached
 kTime   timeinsts              ; time in seconds since this note began
; read complete gesture duration from index zero
 iRecTime        tablei  0,gidata
; if we have reach complete duration of gesture...
 if kTime>=iRecTime then
; deactivate play button (which will in turn, turn off this note.)
  FLsetVal       1,0,gihPlay
 endif
endin

instr   4       ; save table
 ftsave "ControllerData.txt", 0, gidata
endin


instr   5       ; load table
 ftload "ControllerData.txt", 0, gidata
endin

</CsInstruments>

<CsScore>
i 1 0 3600
</CsScore>

</CsoundSynthesizer>
