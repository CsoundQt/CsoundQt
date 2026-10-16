STEREO TO MONO CONVERSION (OFFLINE)
Written by Iain McCurdy, 2010

This example takes a stereo file input and writes a mono file to disk.
Three methods of conversion are available by uncommenting the relevant section of code:
1) Left channel
2) Right channel
3) Mix both channels
Left channel is output by default.

Because this task is performed offline without realtime performance it is suitable for quick conversion of long sound files.
The disadvantage is that the process must be repeated for each channel.

This example could easily be adapted to convert a mono file to stereo

<CsoundSynthesizer>
<CsOptions>
; Output flags are for 24bit wav
-oStereoToMonoRender.wav -W -3
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 1      ; Number of channels (2=stereo)

; Replace this file name with the name of your desired stereo input sound file
#define FILE # "StereoInputSoundfile.wav" #

instr 1
  ilen filelen $FILE       ; Derive length of input sound file
  event_i "i", 2, 0, ilen  ; Trigger instrument 2
endin

instr 2
  asigL, asigR diskin2 $FILE, 1, 0, 1  ; Generate 2 audio signals from a stereo sound file

  ; Left channel------------------------------------------------------------------------
  out asigL  ; Left channel is output to file
  ; ------------------------------------------------------------------------------------

  ; Right channel-----------------------------------------------------------------------
  ; Out asigr    ;left channel is output to file
  ; ------------------------------------------------------------------------------------

  ; Mix channels------------------------------------------------------------------------
  ; Out (asigl+asigr)*0.5  ;mix of channels is output to file
  ; ------------------------------------------------------------------------------------
endin
</CsInstruments>
<CsScore>
; Short score event - duration required for output file will be derived from duration of
; input file
i 1 0 0.01
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>2</x>
 <y>74</y>
 <width>30</width>
 <height>110</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>slider1</objectName>
  <x>5</x>
  <y>5</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c7e34204-b813-4f7f-a4f3-1e54e3bd8c4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
