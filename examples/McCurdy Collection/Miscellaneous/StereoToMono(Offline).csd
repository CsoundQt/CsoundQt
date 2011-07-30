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
;OUTPUT FLAGS ARE FOR 24BIT WAV
-oStereoToMonoRender.wav -W  -3
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 1		;NUMBER OF CHANNELS (2=STEREO)

;REPLACE THIS FILE NAME WITH THE NAME OF YOUR DESIRED STEREO INPUT SOUND FILE
#define	FILE	#"StereoInputSoundfile.wav"#

instr	1
	ilen	filelen	$FILE					;DERIVE LENGTH OF INPUT SOUND FILE
		event_i	"i", 2, 0, ilen			;TRIGGER INSTRUMENT 2
endin
	
instr	2
	asigL, asigR	diskin2	$FILE, 1, 0, 1		;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE

	;LEFT CHANNEL------------------------------------------------------------------------
				out	asigL				;LEFT CHANNEL IS OUTPUT TO FILE
	;------------------------------------------------------------------------------------

	;RIGHT CHANNEL-----------------------------------------------------------------------
	;			out	asigR				;LEFT CHANNEL IS OUTPUT TO FILE
	;------------------------------------------------------------------------------------
	
	;MIX CHANNELS------------------------------------------------------------------------
	;			out	(asigL+asigR)*0.5		;MIX OF CHANNELS IS OUTPUT TO FILE
	;------------------------------------------------------------------------------------
endin
</CsInstruments>
<CsScore>
i 1 0 0.01	;SHORT SCORE EVENT - DURATION REQUIRED FOR OUTPUT FILE WILL BE DERIVED FROM DURATION OF INPUT FILE
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
 <bsbObject version="2" type="BSBVSlider">
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
