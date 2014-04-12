<CsoundSynthesizer>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  1
0dbfs 	 = 1

zakinit 81, 1 ; zak space for up to 81 channels of the 8th order B-format

; the opcodes used below are safed in "ambisonics_udos.txt"
#include "ambisonics_udos.txt"

; in-phase decoding up to third order for one speaker
opcode	ambi_dec1_inph3, a, iii		
; weights up to 8th order
iWeight3D[][] init   8,8
iWeight3D     array  0.333333,0,0,0,0,0,0,0,
	0.5,0.1,0,0,0,0,0,0,
	0.6,0.2,0.0285714,0,0,0,0,0,
	0.666667,0.285714,0.0714286,0.0079365,0,0,0,0,
	0.714286,0.357143,0.119048,0.0238095,0.0021645,0,0,0,
	0.75,0.416667,0.166667,0.0454545,0.00757576,0.00058275,0,0,
	0.777778,0.466667,0.212121,0.0707071,0.016317,0.002331,0.0001554,0,
  	0.8,0.509091,0.254545,0.0979021,0.027972,0.0055944,0.0006993,0.00004114

iorder,iaz,iel	xin
iaz = $M_PI*iaz/180
iel = $M_PI*iel/180
a0=zar(0)
	if	iorder > 0 goto c0
aout = a0
	goto	end
c0:
a1=iWeight3D[iorder-1][0]*zar(1)
a2=iWeight3D[iorder-1][0]*zar(2)
a3=iWeight3D[iorder-1][0]*zar(3)
icos_el = cos(iel)
isin_el = sin(iel)
icos_az = cos(iaz)
isin_az = sin(iaz)
i1	=	icos_el*isin_az			; Y	 = Y(1,-1)
i2	=	isin_el					; Z	 = Y(1,0)
i3	=	icos_el*icos_az			; X	 = Y(1,1)
	if iorder > 1 goto c1
aout	=	(3/4)*(a0 + i1*a1 + i2*a2 + i3*a3)
	goto end
c1: 
a4=iWeight3D[iorder-1][1]*zar(4)
a5=iWeight3D[iorder-1][1]*zar(5)
a6=iWeight3D[iorder-1][1]*zar(6)
a7=iWeight3D[iorder-1][1]*zar(7)
a8=iWeight3D[iorder-1][1]*zar(8)

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
aout	=	(1/3)*(a0 + 3*i1*a1 + 3*i2*a2 + 3*i3*a3 + 5*i4*a4 + 5*i5*a5 + 5*i6*a6 + 5*i7*a7 + 5*i8*a8)

end:
		xout			aout
endop

; overloaded opcode for decoding for 1 or 2 speakers 
; speaker positions in function table ifn
opcode	ambi_dec2_inph,	a,ii
iorder,ifn xin
		xout		ambi_dec1_inph(iorder,table(1,ifn),table(2,ifn))
endop
opcode	ambi_dec2_inph,	aa,ii
iorder,ifn xin
		xout		ambi_dec1_inph(iorder,table(1,ifn),table(2,ifn)),
		ambi_dec1_inph(iorder,table(3,ifn),table(4,ifn))
endop
opcode	ambi_dec2_inph,	aaa,ii
iorder,ifn xin
		xout		ambi_dec1_inph(iorder,table(1,ifn),table(2,ifn)),
		ambi_dec1_inph(iorder,table(3,ifn),table(4,ifn)),
		ambi_dec1_inph(iorder,table(5,ifn),table(6,ifn))
endop

instr 1
asnd    init       1
kdist   init       1
kaz     invalue    "az"
kel     invalue    "el"

k0      ambi_encode asnd,8,kaz,kel
ao1,ao2,ao3 ambi_dec_inph 8,17
        outvalue   "sp1", downsamp(ao1)
        outvalue   "sp2", downsamp(ao2)
        outvalue   "sp3", downsamp(ao3)
        zacl       0,80
endin

</CsInstruments>
<CsScore>
f1 0 1024 10 1
f17 0 64 -2 0  0 0   90 0   0 90  0 0  0 0  0 0  0 0  0 0 
i1 0 100
</CsScore>
</CsoundSynthesizer>
;example by martin neukom
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>41</x>
 <y>26</y>
 <width>230</width>
 <height>357</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>234</r>
  <g>255</g>
  <b>246</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sp1</objectName>
  <x>38</x>
  <y>190</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0c3f6178-d1bd-41dc-9f51-57c883f6f8c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.004</label>
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
  <x>38</x>
  <y>222</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dd2be361-4337-46cd-973f-53c4608caddb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.004</label>
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
  <x>39</x>
  <y>256</y>
  <width>80</width>
  <height>25</height>
  <uuid>{fde91979-2a53-4cbc-a522-aad0371b14d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>60</y>
  <width>59</width>
  <height>40</height>
  <uuid>{ca1f8ec9-e2bc-4fce-ba9f-5888198ae7c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>azimuth
(degrees)
</label>
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
  <x>69</x>
  <y>60</y>
  <width>66</width>
  <height>39</height>
  <uuid>{00aa4ac1-ca24-4116-92fe-e6874ed00a1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>eleveation
(degrees)</label>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>el</objectName>
  <x>72</x>
  <y>29</y>
  <width>55</width>
  <height>25</height>
  <uuid>{182d2782-037b-4554-9b6e-fad3e78d9206}</uuid>
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
  <value>90.00000000</value>
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
  <objectName>az</objectName>
  <x>7</x>
  <y>29</y>
  <width>58</width>
  <height>25</height>
  <uuid>{8498bd06-e16c-4c75-a493-4a1c3fc7dad0}</uuid>
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
  <value>90.00000000</value>
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
  <x>147</x>
  <y>189</y>
  <width>43</width>
  <height>26</height>
  <uuid>{890f3a9f-08e0-4788-a9ef-d282a9147880}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0    0
</label>
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
  <x>148</x>
  <y>222</y>
  <width>42</width>
  <height>24</height>
  <uuid>{9ec34ef9-e3b7-4c77-8cf2-da2d74654317}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>90    0
</label>
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
  <x>149</x>
  <y>257</y>
  <width>42</width>
  <height>24</height>
  <uuid>{e62e2575-3cff-4d4b-976b-d11f52ef3859}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0    90
</label>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="420" y="293" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
