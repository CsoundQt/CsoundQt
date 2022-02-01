<CsoundSynthesizer>
<CsInstruments>

sr = 44100
ksmps = 128
0dbfs = 1
nchnls = 2


seed 0
gkflag init 0
gainput init 0

chn_k "chorus_amt", 1
chn_k "chorus_delay", 1
chn_k "chorus_freq", 1
chn_k "chorus_type", 1
chn_k "chorus_width", 1
chn_k "delay_adt", 1
chn_k "delay_lauridsen", 1
chn_k "delay_schroeder", 1
chn_k "fftsize", 1
chn_k "flutter_amt", 1
chn_k "flutter_freq", 1
chn_k "flutter_type", 1
chn_k "level", 1
chn_k "mode_gerzon", 1
chn_k "mode_orban", 1
chn_k "type", 1
chn_k "width_gerzon", 1
chn_k "width_orban", 1
chn_k "wow_amt", 1
chn_k "wow_freq", 1
chn_k "wow_type", 1

opcode lauridsen, aa, ak
	ain, kdelay xin

	imaxdel = 30
	kdelay limit kdelay, 0.001, imaxdel
	kdelay portk kdelay, 0.02
	adelay1 vdelay3 ain, kdelay, imaxdel
	aleft = -ain + adelay1
	aright = ain + adelay1
	
	xout aleft*0.5, aright*0.5
endop

opcode schroeder, aa, ak
	ain, kdelay xin

	imaxdel = 30
	kdelay limit kdelay, 0.001, imaxdel
	kdelay portk kdelay, 0.02
	adelay1 vdelay3 ain, kdelay, imaxdel
	adelay2 vdelay3 adelay1, kdelay, imaxdel
	aleft = -ain + (2 * adelay1) - adelay2
	aright = ain + (2 * adelay1) + adelay2
	
	xout aleft*0.5, aright*0.5
endop

opcode AllPass, a, a
	ain xin
	; Generate stable poles
	irad exprand 0.1
	irad = 0.99 - irad
	irad limit irad, 0, 0.99
	;iang random -$M_PI, $M_PI
	iang random -$M_PI, $M_PI
	ireal = irad * cos(iang)
	iimag = irad * sin(iang)
	print irad, iang, ireal, iimag
	
	; Generate coefficients from poles
	ia2 = (ireal * ireal) + (iimag * iimag)
	ia1 = -2*ireal
	ia0 = 1

	ib0 = ia2
	ib1 = ia1
	ib2 = ia0

	printf_i "ia0 = %.8f ia1 = %.8f ia2= %.8f\n", 1, ia0, ia1, ia2
	aout biquad ain, ib0, ib1, ib2, ia0, ia1, ia2
	

	xout aout
endop

opcode Orban, aa, akkk
	ain, kwidth, kmode, kreset xin
	
start:
	; Cascade two filters to create a 4-pole all-pass
	a1 AllPass ain
	a1 AllPass a1

	a2 AllPass ain
	if kmode == 1 then
		a2 AllPass a2
	endif
	
	aout1 = a1*kwidth + a2
	aout2 = - a1*kwidth + a2
	
	xout aout1, aout2
rireturn	
if kreset == 1 then
	reinit start
endif
endop

opcode Gerzon, aa, akkk
	ain, kwidth,kmode, kreset xin
start:
	a1 AllPass ain
	a2 AllPass a1
	
	if kmode > 0 then
		a1 AllPass a1
		a2 AllPass a1
	endif	
	if kmode > 1 then
		a1 AllPass a1
		a2 AllPass a1
	endif
	if kmode > 2 then
		a1 AllPass a1
		a2 AllPass a1
	endif
	if kmode > 3 then
		a1 AllPass a1
		a2 AllPass a1
	endif
	if kmode > 4 then
		a1 AllPass a1
		a2 AllPass a1
	endif
	if kmode > 5 then
		a1 AllPass a1
		a2 AllPass a1
	endif
	if kmode > 6 then
		a1 AllPass a1
		a2 AllPass a1
	endif

	aout1 = ain*kwidth + a1
	aout2 = -a2*kwidth + a1
	
	xout aout1, aout2
rireturn	
if kreset == 1 then
	reinit start
endif
endop

;% ADT - Artificial Double Tracking
;% 
;% * Delay: the time the ADT signal is delayed, 10 - 50 ms. * Dra Level: the level of the original signal. * ADT Level: the level of the ADT signal. * ADT Pan: the pan position of the ADT signal, the original signal is positioned at the opposite side. * Wow: amount of low frequency playback speed variation, 0 - 0.2%. * WowFreq.: low frequency playback speed variation rate, 0 - 6Hz. * Waveform: waveform of Wow, Sine or Triangle. * Flutter: amount of high frequency playback speed variation, 0 - 0.2%. * FlutFreq.: high frequency playback speed variation rate, 4 - 60Hz. * Waveform: waveform of Flutter, Sine or Triangle. 

opcode modulate, a, akkkki
	ain, kfreq, kamp, ktype, kdelay, imaxtime xin
;	kreinit changed ktype
;	if kreinit == 1 then
;		reinit start
;	endif
start:
	if ktype == 0 then
		amod jspline kamp, kfreq, kfreq
	elseif ktype == 1 then
		amod poscil kamp, kfreq, 1
	elseif ktype == 2 then
		amod poscil kamp, kfreq, 2
	endif
		
	aout vdelay3 ain, kdelay *(1.00001 + amod), imaxtime
	xout aout
endop

opcode ADT, aa, akkkkkkkk
	ainput, kflutter_freq, kflutter_amt, kflutter_type, kdelay_adt, kwow_freq, kwow_amt, kwow_type, kdelay_adt xin
	aflutter modulate ainput, kflutter_freq, kflutter_amt, kflutter_type, kdelay_adt, 100
	awow modulate aflutter, kwow_freq, kwow_amt, kwow_type, kdelay_adt, 100
	aout1 = ainput
	aout2 = awow
	xout aout1, aout2
endop

opcode InvChorus, aa, akkkk
	ainput, kflutter_freq, kflutter_type, kdelay_adt, kwidth xin
	aflutter modulate ainput, kflutter_freq, 1, kflutter_type, kdelay_adt, 100

	aout1 = (ainput + (aflutter*kwidth) )
	aout2 = (ainput - (aflutter*kwidth) )
	xout aout1, aout2
endop

#define MAX_SIZE #4096#

gisize init 1024
gkchange init 0

pyinit
pyexeci "decorrelation.py"

giir1 ftgen 100, 0, $MAX_SIZE, 2, 0
giir2 ftgen 101, 0, $MAX_SIZE, 2, 0
giir3 ftgen 102, 0, $MAX_SIZE, 2, 0
giir4 ftgen 103, 0, $MAX_SIZE, 2, 0

gifftsizes ftgen 0, 0, 8, -2, 128, 256, 512, 1024, 2048, 4096, 0

	opcode getIr, 0, ii
ichan, ifn xin
index init 0
idummy init 0
isize pycall1i "get_ir_length", -1
isize = gisize
doit:
	ival pycall1i "get_ir_point", ichan, index
	tableiw ival, index, ifn

loop_lt index, 1, isize, doit

	endop
	
opcode Kendall, aaaa, ak
	ainput, kreset xin
dconvreinit:
	prints "Reinit ftconv\n"
	aout1 ftconv ainput, giir1, 1024, 0, gisize
	aout2 ftconv ainput, giir2, 1024, 0, gisize
	aout3 ftconv ainput, giir3, 1024, 0, gisize
	aout4 ftconv ainput, giir4, 1024, 0, gisize
	
	xout aout1, aout2, aout3, aout4
rireturn	
if kreset == 1 then
	reinit dconvreinit
endif
endop

instr 1  ; Inputs and control
	ainput inch 1
	
	gainput = gainput + ainput
;	gainput diskin2 "file.wav", 1
endin

instr 2 ; flag filter coefficients reinit
	gkflag = 1
	turnoff
endin

	instr 3  ; Generate new IR and load it to ftable giir
inew_seed = p4

ifftsize chnget "fftsize"
gisize table ifftsize, gifftsizes

; Clear tables
;vmult giir1, 0, $MAX_SIZE
;vmult giir2, 0, $MAX_SIZE
giir1 ftgen 100, 0, $MAX_SIZE, 2, 0
giir2 ftgen 101, 0, $MAX_SIZE, 2, 0
giir3 ftgen 102, 0, $MAX_SIZE, 2, 0
giir4 ftgen 103, 0, $MAX_SIZE, 2, 0

kmax_jump1 init -1
kmax_jump2 init -1

icur_seed pycall1i "new_seed", inew_seed ;-1 means use system time

;Chan 1
imax_jump = i(kmax_jump1)
ichan = 1
pycalli "new_ir_for_channel", gisize, ichan, imax_jump
getIr 1, giir1

;Chan 2
imax_jump = i(kmax_jump2)
ichan = 2
pycalli "new_ir_for_channel", gisize, ichan, imax_jump
getIr 2, giir2

	gkflag = 1
turnoff 
	endin

instr 5 ; Play file

Sname invalue "_Browse1"

koldsec init 0

idur filelen Sname
ichn filenchnls  Sname	;check number of channels
start:
    prints "init"
if (ichn == 1) then
;mono signal
a1 diskin2 Sname, 1

else
;stereo signal
a1, a2 diskin2 Sname, 1

a1 = (a1+a2)/2
endif
ksecs timeinsts
rireturn
if ksecs % idur < koldsec then
reinit start
endif
koldsec = ksecs
gainput = gainput + a1
endin

instr 11
	gktype chnget "type"
	gklevel chnget "level"
	
	gkdelay_lauridsen chnget "delay_lauridsen"
	
	gkdelay_schroeder chnget "delay_schroeder"
	
	gkwidth_orban chnget "width_orban"
	gkmode_orban chnget "mode_orban"
	
	gkwidth_gerzon chnget "width_gerzon"
	gkmode_gerzon chnget "mode_gerzon"

	kflutter_type chnget "flutter_type"
	kflutter_freq chnget "flutter_freq"
	kflutter_amt chnget "flutter_amt"
	kwow_type chnget "wow_type"
	kwow_freq chnget "wow_freq"
	kwow_amt chnget "wow_amt"
	kdelay_adt chnget "delay_adt"
	
	kchorus_type chnget "chorus_type"
	kchorus_freq chnget "chorus_freq"
	kchorus_amt chnget "chorus_amt"
	kchorus_delay chnget "chorus_delay"
	kchorus_width chnget "chorus_width"

if gktype == 1 then
	aout1, aout2 lauridsen gainput*gklevel, gkdelay_lauridsen
	aout3 = 0
	aout4 = 0
elseif gktype == 2 then
	aout1, aout2 schroeder gainput*gklevel, gkdelay_schroeder
	aout3 = 0
	aout4 = 0
elseif gktype == 3 then	
	aout1, aout2 Orban gainput*gklevel, gkwidth_orban, gkmode_orban, gkflag
	aout3 = 0
	aout4 = 0
elseif gktype == 4 then	
	aout1, aout2 Gerzon gainput*gklevel, gkwidth_gerzon, gkmode_gerzon, gkflag
	aout3 = 0
	aout4 = 0
elseif gktype == 5 then	
	aout1, aout2 ADT gainput*gklevel, kflutter_freq, kflutter_amt, kflutter_type, kdelay_adt, kwow_freq, kwow_amt, kwow_type, kdelay_adt
	aout3 = 0
	aout4 = 0
elseif gktype == 6 then	
	aout1, aout2 InvChorus gainput*gklevel, kchorus_freq, kchorus_type, kchorus_delay, kchorus_width
	aout3 = 0
	aout4 = 0
elseif gktype == 7 then	
	aout1, aout2, aout3, aout4 Kendall gainput*gklevel, gkflag
else
	aout1 = gainput
	aout2 = gainput
	aout3 = gainput
	aout4 = gainput
endif

	gkflag = 0
outch 1, aout1, 2, aout2, 3, aout3, 4, aout4
clear gainput
endin


</CsInstruments>
<CsScore>
f 1 0 4096 10 1 
f 2 0 4096 7 0 1024 1 2048 -1 1024 0  

i 3 0 0.1 ; Initialize Kendall IR
i 11 0 60000
 </CsScore>
<CsFileB filename="decorrelation.py">
IyEgL3Vzci9iaW4vZW52IHB5dGhvbgoKaW1wb3J0IHN5cwoKZnJvbSBudW1weSBpbXBvcnQg
Kgpmcm9tIG51bXB5LmZmdCBpbXBvcnQgaWZmdAppbXBvcnQgbnVtcHkucmFuZG9tIGFzIHJh
bmRvbQoKIyMgZ2xvYmFsIGNvbmZpZ3VyYXRpb24gYW5kIHZhcmlhYmxlcwoKbWF4X2Nobmxz
ID0gMTYKWG4gPSBbXQp5biA9IFtdCgpmb3IgaSBpbiByYW5nZShtYXhfY2hubHMpOgogICAg
WG4uYXBwZW5kKGFycmF5KFtdKSkKICAgIHluLmFwcGVuZChhcnJheShbXSkpCgojIyBDc291
bmQgZnVuY3Rpb25zCmRlZiBuZXdfc2VlZChzZWVkX2luID0gLTEpOgojICAgIHByaW50ICJO
ZXcgc2VlZDogIiwgaW50KHNlZWRfaW4pCiAgICBpZiBzZWVkX2luID09IC0xOgogICAgICAg
IHJhbmRvbS5zZWVkKCkgICNjYW4gcHV0IHNlZWQgaGVyZSwgbGVhdmluZyBibGFuayB1c2Vz
IHN5c3RlbSB0aW1lCiAgICBlbHNlOgogICAgICAgIHJhbmRvbS5zZWVkKGxvbmdsb25nKHNl
ZWRfaW4pKSAgI2NhbiBwdXQgc2VlZCBoZXJlLCBsZWF2aW5nIGJsYW5rIHVzZXMgc3lzdGVt
IHRpbWUKICAgIHJldHVybiBmbG9hdChzZWVkX2luKTsKCmRlZiBnZXRfaXJfbGVuZ3RoKGNo
YW5uZWwgPSAtMSk6CiAgICBpbmRleCA9IGludChjaGFubmVsKSBpZiBjaGFubmVsICE9IC0x
IGVsc2UgMQogICAgcmV0dXJuIGZsb2F0KGxlbihYbltpbmRleF0pKQoKZGVmIGdldF9pcl9w
b2ludChjaGFubmVsLCBpbmRleCk6CiAgICBnbG9iYWwgeW4KICAgIHJldHVybiBmbG9hdCh5
bltpbnQoY2hhbm5lbCAtIDEpXVtpbnQoaW5kZXgpXS5yZWFsKQoKZGVmIG5ld19pcl9mb3Jf
Y2hhbm5lbChOLCBjaGFubmVsID0gMSwgbWF4X2p1bXA9LTEpOgogICAgZ2xvYmFsIFhuLCB5
bgogICAgW1hmaW5hbCwgeV0gPSBuZXdfaXIoTiwgbWF4X2p1bXApCiAgICBYbltpbnQoY2hh
bm5lbCkgLSAxXSA9IFhmaW5hbAogICAgeW5baW50KGNoYW5uZWwpIC0gMV0gPSB5CgpkZWYg
bmV3X2lyKE4sIG1heF9qdW1wPS0xKToKIyAgICAnJycgICBuZXdfaXIoTikKIyAgICBOIC0g
aXMgdGhlIG51bWJlciBvZiBwb2ludHMgZm9yIHRoZSBJUiwKIyAgICBtYXhfanVtcCAtICBp
cyB0aGUgbWF4aW11bSBwaGFzZSBkaWZmZXJlbmNlIChpbiByYWRpYW5zKSBiZXR3ZWVuIGJp
bnMKIyAgICAgICAgICAgICBpZiAtMSwgdGhlIHJhbmRvbSBudW1iZXJzIGFyZSB1c2VkIGRp
cmVjdGx5IChubyBqdW1waW5nKS4KIyAgICcnJwogICAgaWYgTiA8IDE2OgogICAgICAgIHBy
aW50ICJXYXJuaW5nOiBOIGlzIHRvbyBzbWFsbC4iCiAgICBwcmludCAiR2VuZXJhdGUgbmV3
IElSIHNpemU9IiwgTgogICAgbiA9IE4vLzIgIyBiZWZvcmUgbWlycm9yaW5nCiAgICBBbSA9
IG9uZXMoKG4pKQogICAgUGggPSBhcnJheShbXSkKICAgIGxpbWl0ID0gcGkKCiAgICBQaCA9
IGFwcGVuZChQaCwgMCkKICAgIG9sZF9waGFzZSA9IDAKICAgIGZvciBpIGluIHJhbmdlKDEs
bik6CiAgICAgICAgaWYgbWF4X2p1bXAgPT0gLTE6CiAgICAgICAgICAgIFBoID0gYXBwZW5k
KFBoLCAocmFuZG9tLnJhbmRvbSgpKiBsaW1pdCkgLSAobGltaXQvMi4wKSkKICAgICAgICBl
bHNlOgogICAgICAgICMgbWFrZSBwaGFzZSBvbmx5IG1vdmUgKy0gbGltaXQKICAgICAgICAg
ICAgZGVsdGEgPSAocmFuZG9tLnJhbmRvbSgpICogbWF4X2p1bXAgKiAyKiBwaSkgLSAobWF4
X2p1bXAgKiBwaSkKICAgICAgICAgICAgbmV3X3BoYXNlID0gb2xkX3BoYXNlICsgZGVsdGEK
ICAgICAgICAgICAgUGggPSBhcHBlbmQoUGgsIG5ld19waGFzZSkKICAgICAgICAgICAgb2xk
X3BoYXNlID0gbmV3X3BoYXNlCiAgICAjcGFkIERDIHRvIDAgYW5kIGRvdWJsZSBsYXN0IGJp
bgogICAgQW1bMF0gPSAwCiAgICBYcmVhbCA9IG11bHRpcGx5KEFtLCBjb3MoUGgpKQogICAg
WGltYWcgPSBtdWx0aXBseShBbSwgc2luKFBoKSkKICAgIFggPSBYcmVhbCArICgxaipYaW1h
ZykKCiAgICBYc3ltID0gY29uaihYWzE6bl0pWzo6LTFdICMgcmV2ZXJzZSB0aGUgY29uanVn
YXRlCiAgICBYID0gYXBwZW5kKFgsIFhbMF0pCiAgICBYZmluYWwgPSBhcHBlbmQoWCxYc3lt
KQogICAgeSA9IGlmZnQoWGZpbmFsKQogICAgcmV0dXJuIFtYZmluYWwsIHkucmVhbF0KCg
</CsFileB>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>44</x>
 <y>46</y>
 <width>702</width>
 <height>642</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>27</y>
  <width>300</width>
  <height>94</height>
  <uuid>{4c919985-3409-41f4-8fbb-43e8dfb20801}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Lauridsen method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>189</x>
  <y>92</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8c1b791e-f52f-4e26-ad46-b2efdb190286}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>109</x>
  <y>52</y>
  <width>80</width>
  <height>25</height>
  <uuid>{248a562b-78f5-4645-ba0b-17cbbd43c077}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Delay time</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>delay_lauridsen</objectName>
  <x>14</x>
  <y>71</y>
  <width>278</width>
  <height>23</height>
  <uuid>{14814ddc-76ed-4069-a177-c2c1ee4a0e12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>18.00000000</maximum>
  <value>4.15647482</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>level</objectName>
  <x>310</x>
  <y>28</y>
  <width>74</width>
  <height>72</height>
  <uuid>{9a962245-1ac4-41bc-ac0e-2b08a18b5224}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>307</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c207900d-6fa8-426d-bd4f-1217f25145e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>delay_lauridsen</objectName>
  <x>110</x>
  <y>92</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6caa1418-616a-4041-93ae-fc464bfba6fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4.156</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>129</y>
  <width>302</width>
  <height>92</height>
  <uuid>{7593e073-a741-4d94-afcb-68c4654624ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Schroeder method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>192</x>
  <y>193</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1034c59b-36d2-4dea-8f0a-9f8030dc3257}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>112</x>
  <y>153</y>
  <width>80</width>
  <height>25</height>
  <uuid>{02d84091-5df7-4159-9188-a866a1710117}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Delay time</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>delay_schroeder</objectName>
  <x>17</x>
  <y>172</y>
  <width>278</width>
  <height>23</height>
  <uuid>{ce7f181f-61ed-4c95-a51f-423223cd2542}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>10.00000000</maximum>
  <value>3.48309353</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>delay_schroeder</objectName>
  <x>113</x>
  <y>193</y>
  <width>80</width>
  <height>30</height>
  <uuid>{7a288f13-7d03-4a46-b11b-9b0a82551c43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3.483</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>type</objectName>
  <x>389</x>
  <y>63</y>
  <width>124</width>
  <height>26</height>
  <uuid>{e6141577-8e38-4562-b711-d0e71ce7c358}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Bypass</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Lauridsen</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Schroeder</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Orban</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Gerzon</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>ADT</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Inv. Chorus</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Kendall</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>7</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>230</y>
  <width>302</width>
  <height>140</height>
  <uuid>{349e7fd9-91a2-431b-bbd5-3fbaec286384}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Orban method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>113</x>
  <y>256</y>
  <width>80</width>
  <height>25</height>
  <uuid>{40d1d89e-0c66-47d9-aa84-c7d27b30934c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Width gain</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>width_orban</objectName>
  <x>16</x>
  <y>273</y>
  <width>278</width>
  <height>23</height>
  <uuid>{7a672d9a-84a9-4f98-8456-4306b060e420}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80575540</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>mode_orban</objectName>
  <x>193</x>
  <y>300</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c41c4950-c05f-4174-9a55-9731f0a5796f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>2-pole</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4-pole</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>58</x>
  <y>299</y>
  <width>140</width>
  <height>24</height>
  <uuid>{414e0875-d51e-4164-8d4e-8142c2cd09d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Second filter mode</label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>64</x>
  <y>331</y>
  <width>184</width>
  <height>27</height>
  <uuid>{0be35d2e-6bbd-4c48-b99e-5c61520dfe62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>New Filter coefficients</text>
  <image>/</image>
  <eventLine>i 2 0 1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>375</y>
  <width>303</width>
  <height>134</height>
  <uuid>{51510ced-1acc-4e3e-8a52-2735582a467e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Gerzon method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>109</x>
  <y>399</y>
  <width>80</width>
  <height>25</height>
  <uuid>{15fb73ba-c77a-473d-b854-20114445b2cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Width</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>width_gerzon</objectName>
  <x>11</x>
  <y>419</y>
  <width>278</width>
  <height>23</height>
  <uuid>{e70b2442-9358-4d80-87af-87c8732ed3d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.82014388</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>61</x>
  <y>475</y>
  <width>166</width>
  <height>24</height>
  <uuid>{40c3116b-aa0e-4f42-af4a-1e6451c04642}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>New Filter coefficients</text>
  <image>/</image>
  <eventLine>i 2 0 1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>516</x>
  <y>26</y>
  <width>184</width>
  <height>163</height>
  <uuid>{797f859d-d72b-4dbd-9608-86005905acf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>lissajou</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>2.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>mode_gerzon</objectName>
  <x>175</x>
  <y>444</y>
  <width>89</width>
  <height>30</height>
  <uuid>{8b26c526-b7fa-4e97-9787-4ad034be25c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>2-pole</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4-pole</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6-pole</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8-pole</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10-pole</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12-pole</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14-pole</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>5</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>39</x>
  <y>442</y>
  <width>140</width>
  <height>24</height>
  <uuid>{47059c6f-7832-41e6-8b95-b7c7feb8713c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Second filter mode</label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>317</x>
  <y>250</y>
  <width>384</width>
  <height>198</height>
  <uuid>{c579cfee-068f-4699-8f30-0a0373c7dbc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ADT method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>457</x>
  <y>398</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4054fc8a-b32d-4e31-a664-84927344a973}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>403</x>
  <y>352</y>
  <width>80</width>
  <height>25</height>
  <uuid>{362db286-5b5a-4aba-98ab-82c85b59a241}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Delay time</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>delay_adt</objectName>
  <x>329</x>
  <y>378</y>
  <width>215</width>
  <height>22</height>
  <uuid>{f3d67c5d-762e-47c6-9dfb-31df54f51f07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>10.00000000</maximum>
  <value>4.38232558</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>delay_adt</objectName>
  <x>379</x>
  <y>399</y>
  <width>80</width>
  <height>30</height>
  <uuid>{b6ffc104-45ac-47a1-b64f-b9471af49def}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4.382</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>flutter_type</objectName>
  <x>433</x>
  <y>284</y>
  <width>118</width>
  <height>27</height>
  <uuid>{3a00cc5d-806e-41d1-b4f2-0f55622e6036}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Jitter</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>339</x>
  <y>285</y>
  <width>94</width>
  <height>26</height>
  <uuid>{f2a74696-1abd-4b36-94b8-b5df3d9b785b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Flutter type</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>wow_type</objectName>
  <x>434</x>
  <y>318</y>
  <width>118</width>
  <height>27</height>
  <uuid>{5cf9b440-f1e2-4a5e-baaf-eaadcd04ef95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Jitter</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>339</x>
  <y>319</y>
  <width>94</width>
  <height>26</height>
  <uuid>{cf9b274e-ff1f-4df5-8944-9a4652632c8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wow type</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>flutter_freq</objectName>
  <x>556</x>
  <y>273</y>
  <width>54</width>
  <height>54</height>
  <uuid>{b85bd444-14a6-459a-b44b-e2fe2f5425dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>4.00000000</minimum>
  <maximum>60.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>wow_freq</objectName>
  <x>557</x>
  <y>355</y>
  <width>54</width>
  <height>54</height>
  <uuid>{d83789cd-bcad-4eb2-81e8-e8541a90d5f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.10000000</minimum>
  <maximum>6.00000000</maximum>
  <value>4.87900000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>flutter_freq</objectName>
  <x>541</x>
  <y>326</y>
  <width>80</width>
  <height>25</height>
  <uuid>{72b3b8e0-1bb4-435b-85e0-2a44620a8d3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.100</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>flutter_amt</objectName>
  <x>625</x>
  <y>273</y>
  <width>54</width>
  <height>54</height>
  <uuid>{62c20684-1a6a-4347-a4fb-8f7331087aa9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.05200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>flutter_amt</objectName>
  <x>610</x>
  <y>326</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ead56c9a-8159-4ac6-9b5d-8203ffc7c5b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.052</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>wow_freq</objectName>
  <x>540</x>
  <y>408</y>
  <width>80</width>
  <height>25</height>
  <uuid>{685d9659-b647-41c0-8309-4e0b95379e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4.879</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>wow_amt</objectName>
  <x>625</x>
  <y>356</y>
  <width>54</width>
  <height>54</height>
  <uuid>{ca22697f-a9dd-47b0-b6ca-0592e42b54ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.09000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>wow_amt</objectName>
  <x>610</x>
  <y>409</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7aa81584-00b4-4f44-9c23-d1901ef27b4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.090</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <x>541</x>
  <y>337</y>
  <width>80</width>
  <height>25</height>
  <uuid>{482f57b8-b7ac-42a8-b0ac-b7b1507f4be0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
  <alignment>center</alignment>
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
  <x>612</x>
  <y>337</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7f331bb6-2f3c-4be6-961e-59976fdbd7ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amt</label>
  <alignment>center</alignment>
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
  <x>539</x>
  <y>419</y>
  <width>80</width>
  <height>25</height>
  <uuid>{19f26e7a-fd92-44fc-afc7-2df2bebf8fd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
  <alignment>center</alignment>
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
  <x>610</x>
  <y>420</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1385c428-e349-4a22-a420-d7f065c4c547}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amt</label>
  <alignment>center</alignment>
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
  <x>319</x>
  <y>453</y>
  <width>383</width>
  <height>186</height>
  <uuid>{7ec3a6fd-2a2f-4847-971c-76d17745c811}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Inverted Chorus method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>509</x>
  <y>610</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3168c459-83ab-4c83-8226-3a3ce0856c6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>458</x>
  <y>568</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0d5c9493-7e42-4156-b4d4-83035f48e7c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Delay time</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>chorus_delay</objectName>
  <x>355</x>
  <y>592</y>
  <width>278</width>
  <height>23</height>
  <uuid>{e9dd1c67-b581-48f8-8e78-9fbb76fc1f2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>15.00000000</maximum>
  <value>3.90539568</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>chorus_delay</objectName>
  <x>431</x>
  <y>612</y>
  <width>80</width>
  <height>30</height>
  <uuid>{0ee1ddfe-cbc6-439e-b0c8-aa734dc0a536}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.905</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>chorus_type</objectName>
  <x>426</x>
  <y>486</y>
  <width>118</width>
  <height>27</height>
  <uuid>{b9839066-8d41-4b38-bace-ecd5e61fcd30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Jitter</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>332</x>
  <y>487</y>
  <width>94</width>
  <height>26</height>
  <uuid>{94382c5d-8d2d-4ebc-add5-673c52070bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Flutter type</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>543</x>
  <y>546</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4d5e7924-f7a6-47d0-9493-cd6f3b84b0da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>chorus_freq</objectName>
  <x>543</x>
  <y>534</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e3b44958-e137-4ba4-b6ae-0ddc715ccbb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.793</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>chorus_freq</objectName>
  <x>558</x>
  <y>481</y>
  <width>54</width>
  <height>54</height>
  <uuid>{1aa3d96a-1da8-4ae7-8279-6db322b3d4c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.79300000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>chorus_width</objectName>
  <x>346</x>
  <y>523</y>
  <width>54</width>
  <height>54</height>
  <uuid>{7906270e-937d-4604-9be3-d652c982700d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.48000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>333</x>
  <y>573</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d591950e-a60e-4f4f-b9e5-7717f5cc305f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Width</label>
  <alignment>center</alignment>
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
  <x>5</x>
  <y>517</y>
  <width>301</width>
  <height>123</height>
  <uuid>{12786a3a-4cae-4263-a236-a4df0c903483}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Kendall method</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>129</r>
   <g>149</g>
   <b>91</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>fftsize</objectName>
  <x>139</x>
  <y>546</y>
  <width>72</width>
  <height>30</height>
  <uuid>{6bc6ec6e-1b7f-4fe1-b9d2-db3ee0d91f15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>128</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>256</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>512</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1024</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2048</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>5</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>58</x>
  <y>577</y>
  <width>178</width>
  <height>30</height>
  <uuid>{836065f9-5dd9-4755-b071-7d25c84d7c14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>New Coefficients</text>
  <image>/</image>
  <eventLine>i3 0 1 -1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>50</x>
  <y>542</y>
  <width>90</width>
  <height>31</height>
  <uuid>{a51ee335-0ed7-40a7-88a6-576f7de39900}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FIlter length</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <x>391</x>
  <y>38</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5a4254f8-843a-4da7-9d31-0bf4fda6388c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Method</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>315</x>
  <y>130</y>
  <width>101</width>
  <height>27</height>
  <uuid>{ac27bd5e-285c-4149-ab92-0eb679b3e7c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/andres/Music/The Tallis Scholars/Missa Et ecce terrae motus/05-Agnus Dei.flac</stringvalue>
  <text>Select File...</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>316</x>
  <y>160</y>
  <width>193</width>
  <height>27</height>
  <uuid>{3a9b179f-4dad-4f83-890d-3f713a8b2a5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/andres/Music/The Tallis Scholars/Missa Et ecce terrae motus/05-Agnus Dei.flac</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Live in</objectName>
  <x>520</x>
  <y>203</y>
  <width>181</width>
  <height>32</height>
  <uuid>{d8a5ff67-7c25-4ab4-88ce-ae5fdfd86c87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Live input</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>316</x>
  <y>194</y>
  <width>181</width>
  <height>32</height>
  <uuid>{321e2fcc-4a8d-47b0-98af-192b1d26280b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play File</text>
  <image>/</image>
  <eventLine>i5 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
