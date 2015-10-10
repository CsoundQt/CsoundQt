<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -d -odac
</CsOptions>
<CsInstruments>

sr  = 44100
ksmps = 500 ; the default krate can be too fast for the arduino to handle
nchnls = 2
0dbfs  = 1

giSaw  ftgen 0, 0, 4096, 10, 1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8

instr 1

; Initialize the three variables to read
kPot 	init 0
kLight 	init 0
kButton init 0

iPort	serialBegin "/COM5", 9600 ;connect to the arduino with baudrate = 9600
	serialWrite iPort, 1	;Triggering the Arduino (k-rate)

kValue 	= 0
kType 	serialRead iPort	; Read type of data (pot, light, button)

if (kType >= 128) then

	kIndex = 0
	kSize  serialRead iPort
	
	loopStart:
	    kValue 	= kValue << 7
	    kByte	serialRead iPort
	    kValue 	= kValue + kByte
	    loop_lt kIndex, 1, kSize, loopStart
endif

if (kValue < 0) kgoto continue

if (kType == 128) then		; This is the potmeter
	kPot 	= kValue
elseif (kType == 129) then	; This is the light	
	kLight 	= kValue
elseif (kType == 130) then	; This is the button (on/off)
	kButton = kValue
endif

continue:

; Here you can do something with the variables kPot, kLight and kButton
; printks "Pot %f\n", 1, kPot
; printks "Light %f\n", 1, kLight
; printks "Button %d\n", 1, kButton

; Example: A simple oscillater controlled by the three parameters
kAmp	port	kPot/1024, 0.1
kFreq	port	(kLight > 100 ? kLight : 100), 0.1
aOut 	oscil 	kAmp, kFreq, giSaw

if (kButton == 0) then	
	out 	aOut	
endif
	
endin

</CsInstruments>
<CsScore>
i 1 0 60	; Duration one minute
e
</CsScore>
</CsoundSynthesizer>