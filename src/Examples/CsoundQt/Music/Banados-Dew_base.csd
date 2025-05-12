<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2 // currently supports 2, 4 and 5 channel setups, but can easily be adaptaed for more
//you can also set nchnls to 9 to output second order b-format signals directly
0dbfs = 1
//////////////////////////////////
// Dew - Tom Bañados Russell   //
// GNU General Public Liscence //
////////////////////////////////

//////////////////////
///// PARAMETERS///// 
/////////////////////

///////////////////////////////
////////// IMPORTANT//////////
/////////////////////////////
giRenderPrintout = 0 //amount of (rendered) seconds between each printout when rendering to file. Set to less than 1 to ignore printout (this will optimize the performance)

// Here is the central idea of the piece, an ever increasing accelerando
// When offline rendering, these values can be freely chosen, but when running live, having the "gimpulseMaxFreq" too high will overload the CPU. Use with care!
gimpulseStartFreq = 1 // starting frequency of impulses
gimpulseMaxFreq = 1200 // maximum frequency of impulses
// note that this is not the actual frequency that will be reached, this is calculated later
giEndingDuration = 14.6 // amount of time the last section is maintained
///////////////////////////////
/////////////////////////////			


giDuration = 350 //Minimum duration of the piece (total duration will add the ending duration)
					   //Duration of at least 30 is recommended
		
gimpulsePitchMultiplier = 4 // maintain as an integer for harmonic reasons (but feel free to experiment!)

// Frequencies of each chain. Only change giF2-5 for experimentation. 
giF1 = 75  
giF2 = giF1 * 3/2
giF3 = giF1 * 2
giF4 = giF1 * 2/3
giF5 = giF1 * 3/4

giAmplitudeMod = 0.4 //signals are multiplied by this before being output

//without a more complex speaker setup these values don't affect the music so much, but can be played around with
giPositionAmount = 13 //how many positions there are (where the impulses will originate)
giRotationSpeed = 27 //how many seconds it takes for positions to rotate 360 degrees


//Relative Values for each element of a gen05 function table. These will be processed later. 
// The Q durations are relative to each other, the Q values are absolute.
// Both tables must be the same length! the final values are added after
giQTableValues[] 		fillarray	0.9,		1,		2,		0.7,		1.8,		9,		3,		0.16,		17,		4,		9,		3,		5,		0.6, 		3.1, 		1, 	28
giQTableDurations[] 	fillarray 	10, 		11,	3,		0.1,		12,		6,		8,		0.3,		11,		9,		6,		16,	8,		7,			4, 		2,		1				

//////////////
// Globals // don't change manually
////////////
gkImpulseFreqMultiplier init 1 
gkQFactor init 1
gkRotation init 0
giTargetFreq = giF1 * 3.75
while giTargetFreq < gimpulseMaxFreq do 
	giTargetFreq *= 2
od

//ambisonics setup
if nchnls == 2 then
	giSetup = 1
elseif nchnls == 4 then
	giSetup = 2
elseif nchnls == 5 then
	giSetup = 3
elseif nchnls == 9 then
	giSetup = -1
endif

//Processing of QFunction Table!
giQTableDurations *= giDuration  

iSize sumarray giQTableDurations //aprox 1 sample per second
iQnterleaved[] interleave giQTableValues, giQTableDurations
iLen lenarray iQnterleaved
trim_i iQnterleaved, iLen + 1
iQnterleaved[iLen] = 0.01
giQTable ftgen 0, 0, iSize, -5, iQnterleaved


//////////////////////
// Utility Opcodes // 
////////////////////
//Randint and ArrayChoice are not used in this version, but can be implemented to randomize frequencies of each impulse
opcode Randint, i, ii
	iStart, iEnd xin
 	iRandom random iStart, iEnd + .99999
 	iRndInt = int(iRandom)
 	xout iRndInt
endop

opcode Randint, k, ii
	iStart, iEnd xin
 	kRandom random iStart, iEnd + .99999
 	kRndInt = int(kRandom)
 	xout kRndInt
endop

opcode ArrayChoice, i[], i[]i
	// Select a certain number of elements from an array
	iInArr[], iSize xin
	iLen = lenarray(iInArr)
	iOutArr[] init iSize
	iIndx = 0
	iEnd = iLen-1
	while iIndx < iSize do
		//get one random element and put it in iOutArr
		iRndIndx Randint 0, iEnd
		iOutArr[iIndx] = iInArr[iRndIndx]
		//shift the elements after this one to the left
		while iRndIndx < iEnd do
			iInArr[iRndIndx] = iInArr[iRndIndx+1]
			iRndIndx += 1
		od
	//reset end and increase counter
	iIndx += 1
	iEnd -= 1
	od
	xout iOutArr
; Based on the ArrayShuffle UDO by Joachim Heintz
endop

opcode PickPosition, ii, i
	// Choose Azim and Elev based on number from 1 to giPositionAmount
	iPos xin
	iAzim = iPos * 360 / giPositionAmount
	iAzim += i(gkRotation)
	iAzim = (iAzim % 360) - 180 
	iElev = iPos * 75 / giPositionAmount
	xout iAzim, iElev
endop

instr Main
	p3 = giDuration + giEndingDuration
	// starting frequencies for each Impulse Chain. Can be changed but not recommended
	isFreq1 = gimpulseStartFreq
	isFreq2 = gimpulseStartFreq * 0.3121
	isFreq3 = gimpulseStartFreq * 0.11
	isFreq4 = gimpulseStartFreq * 0.013
	isFreq5 = gimpulseStartFreq * 0.0019
	iStart = 1 / giTargetFreq
	
	// the relative frecueny of all repeaters changes slowly
	kImpulseVariation = randomi:k(14/15, 15/14, random:k(0.06, 0.23), 3) //random variation added for musicality
	gkImpulseFreqMultiplier = expseg:k(gimpulseStartFreq, p3 - giEndingDuration, giTargetFreq, giEndingDuration, giTargetFreq) * kImpulseVariation
	
	// change the Q value over time according to the generated table
	kidx = line:k(0, p3, 1)
	gkQFactor = table3:k(kidx, giQTable, 1)
	// rotate the out positions
	gkRotation = line:k(360, giRotationSpeed, 0) % 360
	
	//set the Repeaters running. 
	schedule "Repeater", 	0, p3    , 	isFreq1, 0.1,	 giF1, giF1 * 6/5, giF1 * 7/2, giF1 * 9/4
	schedule "Repeater", 	2, p3 - 2, 	isFreq2, 0.35, giF2, giF2 * 6/5, giF2 * 7/2, giF2 * 9/4
	schedule "Repeater", 	8, p3 - 8, 	isFreq3, 0.47, giF3, giF3 * 6/5, giF3 * 7/2, giF3 * 9/4
	schedule "reRepeater", p3 * 1/6, p3 * 5/6,	isFreq4, 0.74, giF4, giF4 * 6/5, giF4 * 7/4, giF4 * 9/4, giF4 * 3/2, giF4 * 27/16
	schedule "reRepeater", p3 * 1/3, p3 * 2/3,	isFreq5, 0.56, giF5, giF5 * 6/5, giF5 * 7/4, giF5 * 4/3, giF5 * 3/2, giF4 * 9/8
endin


//it is not recommended to change values from here on, as they serve specific functions found through trial and error
instr Repeater
	iBasePeriod = p4
	iOffset = p5
	iNotes[] fillarray p6, p7, p8, p9
	//metronome that changes speed over time
	kTrig = metro:k(iBasePeriod * gkImpulseFreqMultiplier, iOffset)
	kOut init 0 // what position the impulse will be played at
	kInt init 0 // current position of the frequency chain
	if kTrig == 1 then
		kAmp = pow:k(gkImpulseFreqMultiplier, -0.36) // as density increases, we reduce energy
		kDur = 1.5 * pow:k(gkQFactor, 1/10) * kAmp

		//pick the frequency
		kInt += 1
		if kInt >= lenarray:i(iNotes) then
			kInt = 0
		endif
		kFreq = iNotes[kInt] * gimpulsePitchMultiplier
		//pick the out position
		kOut += 1
		if kOut > giPositionAmount then
			kOut = 0
		endif
		schedulek "Pulse", 0, kDur, kAmp, kFreq, kOut, gkQFactor
	endif
endin

instr reRepeater
	//essentially the same as Repeater, but the increased length of the chain combined with other changes makes having two instruments clearer.
	iBasePeriod = p4
	iOffset = p5
	iNotes[] fillarray p6, p7, p8, p9, p10, p6, p7, p8, p9, p10, p11
	
	kTrig = metro:k(iBasePeriod * gkImpulseFreqMultiplier, iOffset)
	kOut init 0
	kInt init 0
	if kTrig == 1 then
		kAmp = pow:k(gkImpulseFreqMultiplier, -0.18) * iOffset
		kDur = 8 * pow:k(gkQFactor, 2/7) * pow(kAmp, 1/3)
		kInt += 1
		if kInt >= lenarray:i(iNotes) then
			kInt = 0
		endif
		kFreq = iNotes[kInt] * gimpulsePitchMultiplier
		kOut += 1
		if kOut > giPositionAmount then
			kOut = 0
		endif
		schedulek "Pulse", 0, kDur, kAmp * 2, kFreq, kOut, gkQFactor * 6
	endif
endin

instr Pulse
	iAmp = p4
	iFreq = p5
	iOut = p6
	iQ = p7 * 45 //hardcoded multiplier for Q
	kEnv = linen:k(giAmplitudeMod, 0, p3, 0.1) //no attack, as quasi-clicking is a part of the form in certain moments of the piece
	aImpulse = mpulse:a(iAmp, p3)
	aFiltered = mode:a(aImpulse, iFreq, iQ)
	aOut = aFiltered * kEnv
	
	iAzim, iElev PickPosition iOut
	
	aw, ax, ay, az, ar, as, at, au, av bformenc1 aOut, k(iAzim), k(iElev)
	if giSetup == 1 then
		aOut1, aOut2 bformdec1 giSetup, aw, ax, ay, az, ar, as, at, au, av	
		out aOut1, aOut2
	elseif giSetup == 2 then
		aOut1, aOut2, aOut3, aOut4 bformdec1 giSetup, aw, ax, ay, az, ar, as, at, au, av
		out aOut1, aOut2, aOut3, aOut4
	elseif giSetup == 3 then
		aOut1, aOut2, aOut3, aOut4, aOut5 bformdec1 giSetup, aw, ax, ay, az, ar, as, at, au, av
		out aOut1, aOut2, aOut3, aOut4, aOut5
	elseif giSetup == -1 then //very specific case where we want to output the b-format signals directly
		out aw, ax, ay, az, ar, as, at, au, av
	endif
	if kEnv < 0.0005 then
	   //this is to reduce redundant instruments	
		turnoff
	endif		
endin

if giRenderPrintout >= 1 then
	schedule "Renderer", 0, 1
endif

instr Renderer
	//This instrument is only useful when rendering offline as it provides an approximation of time left. 
	p3 = giDuration + giEndingDuration
	kSecond line 0, p3, p3 - 1
	kPercent = 100 * kSecond / p3
	kTrig metro 1 / giRenderPrintout
	if kTrig == 1 then
		printks "%d Seconds Rendered. %f Percent completed\n", 0, kSecond, kPercent
	endif
endin


</CsInstruments>
<CsScore>
i "Main"		0		1
</CsScore>
</CsoundSynthesizer>
























<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>750</x>
 <y>151</y>
 <width>490</width>
 <height>169</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>31</x>
  <y>8</y>
  <width>64</width>
  <height>34</height>
  <uuid>{569d07ea-3540-4242-9095-e9c06a553e52}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Dew</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
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
  <x>31</x>
  <y>42</y>
  <width>137</width>
  <height>25</height>
  <uuid>{eb9259fb-dff4-408b-a53e-06a98bce227c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tom Bañados Russell</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>30</x>
  <y>83</y>
  <width>201</width>
  <height>69</height>
  <uuid>{38190ade-1d18-4644-a81b-888441528757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The piece "Dew" is constantly evolving to different circumstances. This is the code used in all these evolutions.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>301</x>
  <y>50</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d9dbac87-a40e-4258-8e4b-e2c0fbde18f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>button3</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
