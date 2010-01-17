/*Getting started.. Realtime Interaction: Open Sound Control

Open Sound Control (OSC) is a network protocol format for musical control data communication. A few of its advantages compared to MIDI are, that it's more accurate, quicker and much more flexible. With OSC you can easily send messages to other software like Max/Msp, Chuck or SuperCollider.

In this example, two instruments are built, which show OSC usage with Qutecsound. 

Instrument 1000 will send OSC messages to an IP-adress. You can generate values on two different channels, on the yellow side of the Widget-Panel.
Instrument 1001 will receive the OSC data from an this IP-adress. When Csound is running, you can see the reactions on the blue side of the Widget-Panel.

Macros are used, to define the send and receive ports, so you can change them at the top of the example-file.

1. open the widget panel
2. press run, to start csound and its OSC responders
3. change the left slider value 


*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

#define IPADDRESS	# "localhost" #
#define S_PORT 		# 47120 #
#define R_PORT 		# 47120 #

turnon 1000															; starts instrument 1000 immediately
turnon 1001															; starts instrument 1001 immediately
	

instr	1000
	kNumber 	invalue "sendNumber"										; receive data from the Widget
	kSlider		invalue "sendSlider"	
	Stext sprintf "%i", $S_PORT									
	outvalue "sndPortNum", Stext											; show the macro defined send-port-number on the Widget 
	OSCsend   kNumber+kSlider, $IPADDRESS, $S_PORT, "/QuteCsound", "ff", kNumber, kSlider			; send data to the IP-adress, and port, when slider or number change
endin


instr 1001	
	kNumRcv 	init 0
	kSldRcv	init 0
	Stext sprintf "%i", $R_PORT
	outvalue "rcvPortNum", Stext											; show the macro defined receive-port-number on the Widget 
	ihandle OSCinit $R_PORT ;												; start the listening process for OSC messages on the defined receive port
	kAction  OSClisten	ihandle, "/QuteCsound", "ff", kNumRcv, kSldRcv						; you must define the kind of data to receive, in this case (ff) both are floating point numbers
		if (kAction == 1) then												; if data is received, then...											
			outvalue "rcvNumber", kNumRcv									; send the value to the channel, to update the Widgets right side
			outvalue "rcvSlider", kSldRcv
		endif														; ends the "if" part
endin
	

</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 507 333 629 423
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioText {314, 1} {286, 407} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {24576, 56064, 65280} background noborder Instr 1001 receives OSC messages from port:
ioText {8, 0} {286, 407} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {62976, 65280, 4352} background noborder Instr 1000 send values via OSC to port:
ioText {10, 146} {80, 25} scroll 6.600000 0.100000 "sendNumber" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 6.6
ioSlider {16, 237} {20, 100} 0.000000 1.000000 0.660000 sendSlider
ioText {10, 120} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Send this value
ioText {323, 135} {80, 25} scroll 6.600000 0.001000 "rcvNumber" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 6.600
ioText {319, 105} {108, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Receive the value
ioText {11, 209} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Send this value
ioText {323, 217} {109, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Receive the value
ioText {196, 0} {80, 25} display 0.000000 0.00100 "sndPortNum" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 47120
ioText {527, 1} {69, 25} display 0.000000 0.00100 "rcvPortNum" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 47120
ioText {10, 24} {281, 70} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder You can set the send port in the orc, by changing the macro S_PORT. The messages can be received by other OSC software like Pd, Max/Msp or SuperCollider, if Csound is not receiving the same port.
ioText {315, 25} {281, 70} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder You can set the receive port in the orc by the macro R_PORT. Pay attention that no other software (like Pd or SuperCollider) is already bound to the same Port, otherwhise Csound will crash.
ioText {11, 342} {80, 25} display 0.000000 0.00100 "sendSlider" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.6600
ioText {319, 351} {80, 25} display 0.000000 0.00100 "rcvSlider" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.6600
ioSlider {326, 245} {22, 99} 0.000000 1.000000 0.656566 rcvSlider
ioText {89, 147} {151, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -> Channel "sendNumber"
ioText {86, 270} {151, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -> Channel "sendSlider"
ioText {407, 288} {151, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Channel "rcvSlider"
ioText {409, 136} {151, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Channel "rcvNumber"
</MacGUI>

<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="320" y="218" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>