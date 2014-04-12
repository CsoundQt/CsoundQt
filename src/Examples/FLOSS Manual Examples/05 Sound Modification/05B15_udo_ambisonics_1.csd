<CsoundSynthesizer>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  1
0dbfs 	 = 1

zakinit 9, 1	; zak space with the 9 channel B-format second order

opcode	ambi_encode, k, aikk		
asnd,iorder,kaz,kel	xin
kaz = $M_PI*kaz/180
kel = $M_PI*kel/180
kcos_el = cos(kel)
ksin_el = sin(kel)
kcos_az = cos(kaz)
ksin_az = sin(kaz)

	zawm	asnd,0							; W
	zawm	kcos_el*ksin_az*asnd,1		; Y	 = Y(1,-1)
	zawm	ksin_el*asnd,2 				; Z	 = Y(1,0)
	zawm	kcos_el*kcos_az*asnd,3		; X	 = Y(1,1)

	if		iorder < 2 goto	end

i2	= sqrt(3)/2
kcos_el_p2 = kcos_el*kcos_el
ksin_el_p2 = ksin_el*ksin_el
kcos_2az = cos(2*kaz)
ksin_2az = sin(2*kaz)
kcos_2el = cos(2*kel)
ksin_2el = sin(2*kel)

	zawm i2*kcos_el_p2*ksin_2az*asnd,4	; V = Y(2,-2)
	zawm i2*ksin_2el*ksin_az*asnd,5		; S = Y(2,-1)
	zawm .5*(3*ksin_el_p2 - 1)*asnd,6		; R = Y(2,0)
	zawm i2*ksin_2el*kcos_az*asnd,7		; S = Y(2,1)
	zawm i2*kcos_el_p2*kcos_2az*asnd,8	; U = Y(2,2)
end:
		xout	0
endop

; decoding of order iorder for 1 speaker at position iaz,iel,idist
opcode	ambi_decode1, a, iii		
iorder,iaz,iel	xin
iaz = $M_PI*iaz/180
iel = $M_PI*iel/180
a0=zar(0)
	if	iorder > 0 goto c0
aout = a0
	goto	end
c0:
a1=zar(1)
a2=zar(2)
a3=zar(3)
icos_el = cos(iel)
isin_el = sin(iel)
icos_az = cos(iaz)
isin_az = sin(iaz)
i1	=	icos_el*isin_az			; Y	 = Y(1,-1)
i2	=	isin_el					; Z	 = Y(1,0)
i3	=	icos_el*icos_az			; X	 = Y(1,1)
	if iorder > 1 goto c1
aout	=	(1/2)*(a0 + i1*a1 + i2*a2 + i3*a3)
	goto end
c1: 
a4=zar(4)
a5=zar(5)
a6=zar(6)
a7=zar(7)
a8=zar(8)

ic2	= sqrt(3)/2

icos_el_p2 = icos_el*icos_el
isin_el_p2 = isin_el*isin_el
icos_2az = cos(2*iaz)
isin_2az = sin(2*iaz)
icos_2el = cos(2*iel)
isin_2el = sin(2*iel)


i4 = ic2*icos_el_p2*isin_2az	; V = Y(2,-2)
i5	= ic2*isin_2el*isin_az		; S = Y(2,-1)
i6 = .5*(3*isin_el_p2 - 1)		; R = Y(2,0)
i7 = ic2*isin_2el*icos_az		; S = Y(2,1)
i8 = ic2*icos_el_p2*icos_2az	; U = Y(2,2)
	
aout	=	(1/9)*(a0 + 3*i1*a1 + 3*i2*a2 + 3*i3*a3 + 5*i4*a4 + 5*i5*a5 + 5*i6*a6 + 5*i7*a7 + 5*i8*a8)

end:
		xout			aout
endop

; overloaded opcode for decoding of order iorder 
; speaker positions in function table ifn
opcode	ambi_decode,	a,ii
iorder,ifn xin
		xout		ambi_decode1(iorder,table(1,ifn),table(2,ifn))
endop
opcode	ambi_decode,	aa,ii
iorder,ifn xin
		xout				ambi_decode1(iorder,table(1,ifn),table(2,ifn)),
		ambi_decode1(iorder,table(3,ifn),table(4,ifn))
endop
opcode	ambi_decode,	aaa,ii
iorder,ifn xin
		xout		ambi_decode1(iorder,table(1,ifn),table(2,ifn)),
		ambi_decode1(iorder,table(3,ifn),table(4,ifn)),
		ambi_decode1(iorder,table(5,ifn),table(6,ifn))
endop

instr 1
asnd	init		1
;kdist	init		1
kaz		invalue	"az"
kel		invalue	"el"

k0	ambi_encode		asnd,2,kaz,kel

ao1,ao2,ao3 	ambi_decode	2,17
		outvalue "sp1", downsamp(ao1)
		outvalue "sp2", downsamp(ao2)	
		outvalue "sp3", downsamp(ao3)	
		zacl 	0,8
endin


</CsInstruments>
<CsScore>
;f1 0 1024 10 1
f17 0 64 -2 0  0 0   90 0   0 90   0 0  0 0  0 0
i1 0 100
</CsScore>
</CsoundSynthesizer>
;example by martin neukom
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>119</width>
 <height>281</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>234</r>
  <g>255</g>
  <b>246</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sp1</objectName>
  <x>27</x>
  <y>243</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0c3f6178-d1bd-41dc-9f51-57c883f6f8c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.629</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sp2</objectName>
  <x>27</x>
  <y>275</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dd2be361-4337-46cd-973f-53c4608caddb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.167</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sp3</objectName>
  <x>28</x>
  <y>309</y>
  <width>80</width>
  <height>25</height>
  <uuid>{fde91979-2a53-4cbc-a522-aad0371b14d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.337</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>az</objectName>
  <x>25</x>
  <y>90</y>
  <width>80</width>
  <height>25</height>
  <uuid>{efe9c15d-4029-4c51-8742-6b9f14f0fde9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <value>0.00800000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>el</objectName>
  <x>118</x>
  <y>90</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c92605ee-0206-406d-867c-0ad90b51d6ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <value>37.09300000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>25</x>
  <y>120</y>
  <width>80</width>
  <height>43</height>
  <uuid>{555646ac-cc8f-4c04-807b-c2a09a8ba576}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>azimuth
(degees)</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>121</y>
  <width>80</width>
  <height>43</height>
  <uuid>{edab774c-e53a-4802-86b9-b04560e214f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>elevation
(degees)</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>128</x>
  <y>243</y>
  <width>46</width>
  <height>25</height>
  <uuid>{ca7665cf-aef9-4c3d-abe7-0b6173d57b0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0     0</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>128</x>
  <y>276</y>
  <width>46</width>
  <height>25</height>
  <uuid>{2d8ebbb1-5ff2-4d4c-ba52-85a141407797}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>90   0</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>129</x>
  <y>309</y>
  <width>46</width>
  <height>25</height>
  <uuid>{eefdc856-efa6-4ac3-a741-483f6ce61ce7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0   90   </label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="420" y="293" width="596" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>
