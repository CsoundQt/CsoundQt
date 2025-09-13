<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

/*****INPUT TEST*****/
;example for CsoundQt
;written by joachim heintz
;jan 2009 / aug 2025

sr = 44100
ksmps = 128
nchnls = 24 ; change here if your input device has more channels
0dbfs = 1

//UDO for displaying an audio signal in widgets
opcode CsQtMeter, 0, SSak ;see https://github.com/csudo/csudo/blob/master/csqt/CsQtMeter.csd
 S_chan_sig, S_chan_over, aSig, kTrig	xin
 iDbRange = 60 ;shows 60 dB
 iHoldTim = 1 ;seconds to "hold the red light"
 kOn init 0
 kTim init 0
 kStart init 0
 kEnd init 0
 kMax max_k aSig, kTrig, 1
 if kTrig == 1 then
  chnset (iDbRange + dbfsamp(kMax)) / iDbRange, S_chan_sig
  if kOn == 0 && kMax > 1 then
   kTim = 0
   kEnd = iHoldTim
   chnset k(1), S_chan_over
   kOn = 1
  endif
  if kOn == 1 && kTim > kEnd then
   chnset k(0), S_chan_over
   kOn =	0
  endif
 endif
 kTim += ksmps/sr
endop

// declare channels and call one instr for each channel
indx = 0
while indx < nchnls do
  indx += 1
  chn_k sprintf("in%d",indx),2
  chn_k sprintf("in%dover",indx),2
  chn_k sprintf("db%d",indx),2
  schedule "Channel",0,99999,indx
od
chn_k "inchsel",1
chn_k "insel",2
chn_k "inselover",2
chn_k "dbsel",2

instr SelectedChannel
  kChan chnget "inchsel"
  aIn inch kChan
  gkTrigDisp metro 10
  CsQtMeter "insel", "inselover", aIn, gkTrigDisp
  kDb = dbamp(k(aIn))
  kDb limit kDb,-99,10
  kDb port kDb,1
  chnset kDb,"dbsel"
endin
schedule("SelectedChannel",0,-1)

instr Channel //displays the signals of one channel
  iChn = p4
  aIn inch iChn
  Sig sprintf "in%d",iChn
  Sigover sprintf "in%dover",iChn
  SdB sprintf "db%d",iChn
  CsQtMeter Sig, Sigover, aIn, gkTrigDisp
  kDb = dbamp(k(aIn))
  kDb limit kDb,-99,10
  kDb port kDb,1
  chnset kDb,SdB
endin

</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>


<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 486 71 624 711
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {14, 359} {543, 58} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This file tests whether your inputs are working. Please adjust it at the following places to your needs:
ioText {147, -1} {299, 44} label 0.000000 0.00100 "" center "Lucida Grande" 26 {0, 0, 0} {65280, 65280, 65280} nobackground noborder INPUT TESTER
ioText {14, 417} {546, 56} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1. Change the nchnls (number of channels) parameter in the orchestra header to the value you wish and your output device can.
ioText {14, 474} {546, 59} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2. Make sure you are using the appropriate device by selecting it on the Configure dialog
ioMeter {13, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in1" 0.602177 fill 1 0 mouse
ioMeter {13, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in1over" 0.000000 fill 1 0 mouse
ioMeter {35, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in2" 0.602177 fill 1 0 mouse
ioMeter {35, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in2over" 0.000000 fill 1 0 mouse
ioMeter {57, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in3" -inf fill 1 0 mouse
ioMeter {57, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in3over" 0.000000 fill 1 0 mouse
ioMeter {79, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in4" -inf fill 1 0 mouse
ioMeter {79, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in4over" 0.000000 fill 1 0 mouse
ioMeter {101, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in5" -inf fill 1 0 mouse
ioMeter {101, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in5over" 0.000000 fill 1 0 mouse
ioMeter {123, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in6" -inf fill 1 0 mouse
ioMeter {123, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in6over" 0.000000 fill 1 0 mouse
ioMeter {145, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in7" -inf fill 1 0 mouse
ioMeter {145, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in7over" 0.000000 fill 1 0 mouse
ioMeter {167, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in8" -inf fill 1 0 mouse
ioMeter {167, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in8over" 0.000000 fill 1 0 mouse
ioMeter {200, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out9" 0.000000 fill 1 0 mouse
ioMeter {200, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out9over" 0.000000 fill 1 0 mouse
ioMeter {222, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out10" 0.000000 fill 1 0 mouse
ioMeter {222, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out10over" 0.000000 fill 1 0 mouse
ioMeter {244, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out11" 0.000000 fill 1 0 mouse
ioMeter {244, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out11over" 0.000000 fill 1 0 mouse
ioMeter {266, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out12" 0.000000 fill 1 0 mouse
ioMeter {266, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out12over" 0.000000 fill 1 0 mouse
ioMeter {288, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out13" 0.000000 fill 1 0 mouse
ioMeter {288, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out13over" 0.000000 fill 1 0 mouse
ioMeter {310, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out14" 0.000000 fill 1 0 mouse
ioMeter {310, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out14over" 0.000000 fill 1 0 mouse
ioMeter {332, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out15" 0.000000 fill 1 0 mouse
ioMeter {332, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out15over" 0.000000 fill 1 0 mouse
ioMeter {354, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out16" 0.000000 fill 1 0 mouse
ioMeter {354, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out16over" 0.000000 fill 1 0 mouse
ioMeter {388, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out17" 0.000000 fill 1 0 mouse
ioMeter {388, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out17over" 0.000000 fill 1 0 mouse
ioMeter {410, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out18" 0.000000 fill 1 0 mouse
ioMeter {410, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out18over" 0.000000 fill 1 0 mouse
ioMeter {432, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out19" 0.000000 fill 1 0 mouse
ioMeter {432, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out19over" 0.000000 fill 1 0 mouse
ioMeter {454, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out20" 0.000000 fill 1 0 mouse
ioMeter {454, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out20over" 0.000000 fill 1 0 mouse
ioMeter {476, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out21" 0.000000 fill 1 0 mouse
ioMeter {476, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out21over" 0.000000 fill 1 0 mouse
ioMeter {498, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out22" 0.000000 fill 1 0 mouse
ioMeter {498, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out22over" 0.000000 fill 1 0 mouse
ioMeter {520, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out23" 0.000000 fill 1 0 mouse
ioMeter {520, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out23over" 0.000000 fill 1 0 mouse
ioMeter {542, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out24" 0.000000 fill 1 0 mouse
ioMeter {542, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out24over" 0.000000 fill 1 0 mouse
ioText {9, 49} {25, 23} label 1.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {32, 49} {25, 23} label 2.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {55, 49} {25, 23} label 3.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3
ioText {77, 49} {25, 23} label 4.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4
ioText {99, 49} {25, 23} label 5.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5
ioText {121, 49} {25, 23} label 6.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6
ioText {143, 49} {25, 23} label 7.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7
ioText {165, 49} {25, 23} label 8.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8
ioText {194, 49} {29, 23} label 9.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9
ioText {217, 49} {29, 23} label 10.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10
ioText {240, 49} {29, 23} label 11.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11
ioText {263, 49} {29, 23} label 12.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12
ioText {285, 49} {29, 23} label 13.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 13
ioText {307, 49} {29, 23} label 14.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 14
ioText {329, 49} {29, 23} label 15.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15
ioText {351, 49} {29, 23} label 16.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 16
ioText {384, 49} {29, 23} label 17.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 17
ioText {406, 49} {29, 23} label 18.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 18
ioText {428, 49} {29, 23} label 19.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 19
ioText {450, 49} {29, 23} label 20.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 20
ioText {472, 49} {29, 23} label 21.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21
ioText {494, 49} {29, 23} label 22.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 22
ioText {516, 49} {29, 23} label 23.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 23
ioText {538, 49} {29, 23} label 24.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 24
ioText {183, 326} {62, 29} editnum 60.000000 0.100000 "dbrange" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 60.000000
ioText {85, 326} {93, 30} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB Range
ioText {425, 327} {51, 29} editnum 1.000000 1.000000 "peakhold" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {317, 327} {104, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Peak Hold time
ioText {2, 261} {39, 22} display -29.300000 0.00100 "db1" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -29.3
ioText {25, 285} {39, 22} display -29.300000 0.00100 "db2" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -29.3
ioText {48, 261} {39, 22} display -inf 0.00100 "db3" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {71, 285} {39, 22} display -inf 0.00100 "db4" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {93, 261} {39, 22} display -inf 0.00100 "db5" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {115, 285} {39, 22} display -inf 0.00100 "db6" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {137, 261} {39, 22} display -inf 0.00100 "db7" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {159, 285} {39, 22} display -inf 0.00100 "db8" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {191, 261} {39, 22} display -inf 0.00100 "db9" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {214, 285} {39, 22} display -inf 0.00100 "db10" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {237, 261} {39, 22} display -inf 0.00100 "db11" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {260, 285} {39, 22} display -inf 0.00100 "db12" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {282, 261} {39, 22} display -inf 0.00100 "db13" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {304, 285} {39, 22} display -inf 0.00100 "db14" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {326, 261} {39, 22} display -inf 0.00100 "db15" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {348, 285} {39, 22} display -inf 0.00100 "db16" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {379, 261} {39, 22} display -inf 0.00100 "db17" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {402, 285} {39, 22} display -inf 0.00100 "db18" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {425, 261} {39, 22} display -inf 0.00100 "db19" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {448, 285} {39, 22} display -inf 0.00100 "db20" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {470, 261} {39, 22} display -inf 0.00100 "db21" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {492, 285} {39, 22} display -inf 0.00100 "db22" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {514, 261} {39, 22} display -inf 0.00100 "db23" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {536, 285} {39, 22} display -inf 0.00100 "db24" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {14, 535} {546, 59} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The white boxes show smoothed RMS values in dB FS.
ioMeter {174, 337} {254, 30} {0, 59904, 0} "insel" 0.602177 "insel" 0.602177 fill 1 0 mouse
ioMeter {425, 337} {29, 30} {50176, 3584, 3072} "inselover" 0.000000 "inselover" 0.000000 fill 1 0 mouse
ioText {455, 337} {54, 28} display -29.900000 0.00100 "dbsel" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -29.9
ioText {16, 326} {125, 50} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder or selectÂ¬one channel
ioText {144, 336} {62, 29} editnum 1.000000 1.000000 "inchsel" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {350, 377} {206, 45} display 0.000000 0.00100 "msg" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="392" y="275" width="612" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>486</x>
 <y>71</y>
 <width>672</width>
 <height>424</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>40</y>
  <width>600</width>
  <height>40</height>
  <uuid>{e827ab0d-6f6b-416e-93a5-5671105847e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Adjust the nchnls in the header if you have less input channels!</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>95</x>
  <y>0</y>
  <width>400</width>
  <height>44</height>
  <uuid>{63b531ec-f575-4bc2-a2f7-7c84e640aae4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>24 CHANNEL INPUT TESTER</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>26</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>10</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{938ab04a-f691-44c4-b0d6-42fa15bcc945}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.39623350</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>10</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{df43a983-2047-4c7c-bedf-4ca691c4eed1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>33</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{4af2b75b-e36c-4d23-895b-5c0080282473}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.42517949</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>33</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{2e8c4e91-d8af-4e4d-9a56-2190e401f78b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in2over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>56</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{bb479c4e-0a9b-461c-b71a-92b2554238df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>56</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{03900327-5fcf-49db-8498-695ffdfbd398}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in3over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>79</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{874da1bd-5dff-42e3-8ea3-fbe785c45b0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>79</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{aabc58a6-ad28-4868-84e6-4b064b02ae7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in4over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>103</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{b37ece90-1af4-4be2-8c1d-0634ec21c8e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>103</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{56d95a8b-7fa5-499e-aeef-eaa7191f53e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in5over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>127</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{3b232963-4d08-472f-b0b3-039a8d41c06c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>127</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{590bfc8e-7f1f-4dfb-9602-d4a563c30374}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in6over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>151</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{213ef6f9-9ef2-4d41-a679-0b114b76eb95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>151</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{dc76973b-8a55-449e-b4be-347fdc6dc018}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in7over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>175</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{41874088-48c6-4d0f-b018-abaf4b506311}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>175</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5b9aef62-52b5-4027-89ef-6ca5652441cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>in8over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>210</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{a2fdf869-44c3-493f-97a4-f168653e109f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out9</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>210</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3966692e-ea15-4212-be40-99a19ef4beb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out9over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>233</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{3e6c7e02-d1db-4938-ba01-959b1a4f3e11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>233</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{ce3daf9e-38e8-41c7-8538-c07bc31d91d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out10over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>256</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{add43f3a-6e7a-4e93-a9d6-f2d4dac83ada}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out11</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>256</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{98ce6154-ab6c-490d-a616-d0e475e5a5bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out11over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>279</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{372b91e6-0afd-4d84-9382-3022b5f8d1bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>279</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{318dd67c-53f1-43c0-b27e-e874023e98ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out12over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>303</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{4dd522c3-d724-4136-8f5c-b99b7fad4b5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>303</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{86f6d139-00f9-43ba-8782-2a2818d0c4d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out13over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>327</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{68f5e23d-5bc5-43da-95af-cb10aa625270}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>327</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{eebca19f-1a12-432a-b1da-36b620358881}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out14over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>351</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{493ed577-dbb0-4af8-9512-bb003f17ad95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>351</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{010542a0-c5cd-4fb1-8fac-0bfb7d5ca01b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out15over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>375</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{0c611701-8190-46d1-b941-94c53756ee58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>375</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a4703e1d-b986-422c-8e53-6418d6bc1373}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out16over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>415</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{003a4329-b9c9-453d-95f3-8a4a7f0fc67c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out17</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>415</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9fffa10e-23d7-49b8-91a9-cc8a812d5e1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out17over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>437</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{978a4bef-60d8-4431-8a2b-10d56d4c0d10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out18</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>437</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{7ea8c868-5c0c-4976-aa9f-06b98a51486b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out18over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>460</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{a58689b0-d57d-4cb0-9462-b52c774fe511}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out19</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>460</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5a3d56c2-e210-44b2-93e1-2c411b1ee9ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out19over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>483</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{b5b5958f-3ba8-401b-b4c2-aea29553718b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out20</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>483</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{23cd866d-36bf-4855-9b7d-8a8fa2c86eb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out20over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>506</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{b5745bf5-b764-476e-92ee-81cf83dbc378}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out21</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>506</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{d521ae37-ca57-48a8-bbe7-23584a1636e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out21over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>529</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{3188bf86-de2a-4c98-aed5-9f5510295ae3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out22</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>529</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{6ce84026-4da8-45ea-98ba-df6586a8a81d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out22over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>552</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{289de6d1-1cc1-4ccf-9196-ede93c4e44b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out23</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>552</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a450211d-0498-4fb5-85aa-1f2f4d5cff8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out23over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>hor8</objectName>
  <x>575</x>
  <y>120</y>
  <width>20</width>
  <height>169</height>
  <uuid>{ce42b036-09b9-456e-8576-dbc22089f4d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out24</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>DelayMute</objectName>
  <x>575</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{77cb9363-6da0-488e-b15a-46ed65702380}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out24over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{ef0cd9d0-65e2-451a-8882-3f0c23208eda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>34</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{24dbc461-0c8f-46b6-8c61-50a5a9a4ed96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>58</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{a5bedd3d-120a-4f44-aa7b-bf3c4202513b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>82</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{28576e95-8f83-4934-bc07-20739020c38c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>4</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>106</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{2e4ee2b4-8fa5-44cc-85ce-60bbd84e390f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>5</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>129</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{1ab11fa8-2110-450a-b4e0-127200912fc0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>6</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>152</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{094114ed-f819-431d-a814-91ac88addd3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>7</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>175</x>
  <y>80</y>
  <width>25</width>
  <height>23</height>
  <uuid>{5498615d-e69a-423e-861f-7813cc0458c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>8</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>205</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{da3b9fe9-1fb0-40a9-a408-1e156f5c6168}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>9</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>229</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{2e765f56-3809-43f9-93cd-661c92cd00bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>10</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>253</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{0e4548c9-1901-47da-9c07-01252dcb0927}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>11</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>277</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{c3ca5e66-f297-49f1-89f1-6f1dba9a9d8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>12</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>301</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{c35e83f8-81b1-47b8-9dda-d5145fbb147d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>13</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>324</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{b4feb515-9232-44c8-8a64-ef1801fe0c30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>14</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>347</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{36d85d53-e889-4349-b510-6e04a5c3554f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>15</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>370</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{086f056d-db24-4875-92d1-b586ca7f6d61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>16</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>410</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{c392e613-cbf6-4fc1-a23c-67a2c9cbf871}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>17</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>433</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{14b58e85-ad8e-49ed-84c7-4f915b5b3072}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>18</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>455</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{272e1f26-6cfd-40db-992d-00d819a81c97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>19</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>477</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{3a725634-e1a1-4e06-8a35-dd4ad14565c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>20</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>499</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{beaac2a1-c4bd-48bf-930e-5fc8cc0b53c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>21</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{08d4a1e7-dd79-48a3-867e-b67b3deead79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>22</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>543</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{304b6c13-2ef2-4956-863a-d9bc431c1e45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>23</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>565</x>
  <y>80</y>
  <width>29</width>
  <height>23</height>
  <uuid>{4169fd2b-b291-4bf9-941b-0643bb4db99b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>24</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db1</objectName>
  <x>10</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{904a3a8b-37a4-46f8-bcbf-3ffda9e183e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-37</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>595</x>
  <y>290</y>
  <width>80</width>
  <height>30</height>
  <uuid>{e89c7c22-d239-4277-9711-933f89fea435}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>dB (rms)</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>insel</objectName>
  <x>174</x>
  <y>337</y>
  <width>254</width>
  <height>30</height>
  <uuid>{4d575819-9193-4488-b590-3cdac26c1db3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>insel</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.39623350</xValue>
  <yValue>0.39623350</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>inselover</objectName>
  <x>425</x>
  <y>337</y>
  <width>29</width>
  <height>30</height>
  <uuid>{77238555-aa61-40b1-8b36-ee6cee31f477}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>inselover</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>dbsel</objectName>
  <x>455</x>
  <y>337</y>
  <width>54</width>
  <height>28</height>
  <uuid>{6fabd7b4-dad6-4865-8a24-199f0a1e94c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-37</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>16</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>16</x>
  <y>329</y>
  <width>106</width>
  <height>44</height>
  <uuid>{558a2baf-3d2d-49ed-9a20-54681c72667e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>or select
one channel</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>inchsel</objectName>
  <x>122</x>
  <y>335</y>
  <width>51</width>
  <height>31</height>
  <uuid>{671956d9-d551-4e24-a32d-558aaad0499a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>16</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db2</objectName>
  <x>34</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{91b23ea6-7828-44ed-8b81-de8798a0157f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-37</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db3</objectName>
  <x>58</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{415c60c5-dbf5-4c58-ad40-e6e521695547}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db4</objectName>
  <x>82</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{1587f07c-ec6f-459e-b0f9-aef6f8b49eb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db5</objectName>
  <x>106</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{45c17497-237b-4da2-b7a0-bf83429857b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db6</objectName>
  <x>129</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{a7e31897-0084-4957-99cf-b63abbe07958}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db7</objectName>
  <x>152</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{f1762221-fcec-4d3f-8536-af70122c9382}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db8</objectName>
  <x>175</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{d2a9ddce-3caf-4478-9329-2871f6ef8bd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db9</objectName>
  <x>205</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{b7a79b52-38a7-4c98-8bfe-8e79ff7b2496}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db10</objectName>
  <x>230</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{4ca526bc-841b-4843-8a58-93041f1b0cba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db11</objectName>
  <x>255</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{8428035b-dcf8-444b-89da-db7821fc781e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db12</objectName>
  <x>279</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{3f159e75-2a29-405c-81f3-b2a88abdc827}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db13</objectName>
  <x>303</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{944d6b02-07d0-4196-b543-66a49bde196a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db14</objectName>
  <x>327</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{2227304a-6bf1-458c-9ffd-490039d0344e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db15</objectName>
  <x>351</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{f427d2d6-43aa-4e5d-9c8f-9f0b3394ecb3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db16</objectName>
  <x>375</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{ce9ea87d-8abe-41ab-ae0c-0af5b7253e4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db17</objectName>
  <x>410</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{3ca607a3-aae3-4aa6-a55b-78da4a674890}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db18</objectName>
  <x>433</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{569b12e0-bb6f-4707-8bf8-9da0d930492f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db19</objectName>
  <x>456</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{7a033461-6b5a-48b1-aa26-19df634b56fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db20</objectName>
  <x>479</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{9b946e68-a37a-447c-affc-07669f42b0a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db21</objectName>
  <x>502</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{3d349e23-ce7b-4778-8211-62b97451a952}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db22</objectName>
  <x>525</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{5af48394-5ef2-48e9-b65e-9429a0a54075}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db23</objectName>
  <x>548</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{cd2d94bf-83fb-4330-b01a-ac768d32f733}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>db24</objectName>
  <x>570</x>
  <y>295</y>
  <width>25</width>
  <height>22</height>
  <uuid>{49862daf-4f67-458d-902c-5b3853a283a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-75</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
