<CsoundSynthesizer>
<CsOptions>
-odac -d -m128
; Example by Tarmo Johannes
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 4096, 10, 1

instr getPeaks
	
	; generate signal to analyze
	kfrcoef jspline 60,0.1,1 ; change the signal in time a bit for better testing
	kharmcoef jspline 4,0.1,1
	kmodcoef jspline 1,0.1,1
	kenv linen 0.5,0.05,p3,0.05
	asig foscil kenv, 300+kfrcoef,1,1+kmodcoef, 10,giSine
	outs asig*0.05,asig*0.05 ; original sound in backround
	
	; FFT analyze
	ifftsize  = 1024
	ioverlap  = ifftsize / 4
	iwinsize  = ifftsize
	iwinshape = 1
	fsig pvsanal asig, ifftsize, ioverlap, iwinsize, iwinshape
	ithresh= 0.001 ; detect only peaks over this value	
	tFrames init iwinsize+2 ; declare array
	kframe pvs2tab tFrames, fsig ; FFT values to array - every even member - amp of one bin, odd - frequency

	; detect peaks
	kindex = 2 ; start checking from second bin, to be able to compare it to previous one
	kcounter = 0
	iMaxPeaks = 13 ; track up to iMaxPeaks peaks
	ktrigger metro 1/2 ; check after every 2 seconds
	if (kframe>0 && ktrigger==1 ) then
		label1:
		    	if (tFrames[kindex-2]<=tFrames[kindex] && tFrames[kindex]>tFrames[kindex+2] && tFrames[kindex]>ithresh && kcounter<iMaxPeaks) then  ; check with neigbouring amps - if higher or equal than previous amp and more than the coming one, must be peak.
			    	kamp = tFrames[kindex]
			    	kfreq = tFrames[kindex+1]			
			    	event "i", "sound", kcounter*0.1, 1, kamp, kfreq ; play sounds with the amplitude and frequency of the peak as in arpeggio
			    	kcounter=kcounter+1
		    	endif	    	
	    	loop_lt kindex,2,ifftsize,label1;
	endif	
endin

instr sound
	iamp= p4
	ifreq=p5
	kenv adsr 0.1,0.1,0.5,p3/2
	kndx line 5,p3,1
	asig foscil iamp*kenv, ifreq,1,0.75,kndx,giSine
	outs asig, asig
endin


</CsInstruments>
<CsScore>
i "getPeaks" 0 60
</CsScore>
</CsoundSynthesizer>
