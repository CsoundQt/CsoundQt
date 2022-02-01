<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;example for CsoundQt
;by karin daum 


sr      =  44100
ksmps   =  32
nchnls  =  6
0dbfs	  = 1

giorder	init	3
gkMethod	init	1
gkMovement	init	1
gkgain	init	0
gaL 		init	0
gaR 		init	0
gaC 		init	0
gaLFE		init	0
gaSL		init	0
gaSR		init	0
gkx		init	0.5
gky		init	0.5
gkSpread	init	nchnls
gkfirst	init 1
gkVBAPSpread	init 0
gkposX	init 2
gkposY	init 2


opcode	getkx, k,0
kx		line	0,25,20
kxx		= 	(-1)^int(kx/20)
kx		=	kx % 20 - 10
kx		=kx*kxx
	xout kx
endop
opcode	getRphi, 0,kk
kx,ky		xin
gkdist	=	sqrt (kx^2+ky^2+0.000001)
gkaz		taninv2 ky,-kx
gkaz		= gkaz*57.296
endop


;
;	ambisonics part
;

opcode	ambi2D_encode_dist_n, 0, aikkk		
asnd,iorder,kaz,kdist,kHOmod	xin
;
;	in contrast to the exaple in the FLOSS manual 
;	an additional parameter kHOmod is introduced
;	this allows the damping of the HO modes to be altered
;
kaz = $M_PI*kaz/180
if(kdist >=0)then
kdist   =	abs(kdist)+0.0001
kgainW  =	taninv(kdist*1.5707963) / (kdist*1.5708)		;pi/2
	      kgainHO =	(1 - exp(-kdist*kHOmod)) *kgainW
else
kgainW  =  1.
kgainHO =  1.
endif

kk =	iorder
c1:
   	zawm	cos(kk*kaz)*asnd*kgainHO,2*kk-1
   	zawm	sin(kk*kaz)*asnd*kgainHO,2*kk
kk =		kk-1

if	kk > 0 goto c1
k0	=0
	zawm	asnd*kgainW,0	
endop

;in-phase-decoding
opcode	ambi2D_dec_inph, a, ii	
; weights and norms up to 12th order
iNorm2D[] array 1,0.75,0.625,0.546875,0.492188,0.451172,0.418945,
					0.392761,0.370941,0.352394,0.336376,0.322360
iWeight2D[][] init   12,12
iWeight2D     array  0.5,0,0,0,0,0,0,0,0,0,0,0,
	0.666667,0.166667,0,0,0,0,0,0,0,0,0,0,
	0.75,0.3,0.05,0,0,0,0,0,0,0,0,0,
	0.8,0.4,0.114286,0.0142857,0,0,0,0,0,0,0,0,
	0.833333,0.47619,0.178571,0.0396825,0.00396825,0,0,0,0,0,0,0,
	0.857143,0.535714,0.238095,0.0714286,0.012987,0.00108225,0,0,0,0,0,0,
	0.875,0.583333,0.291667,0.1060601,0.0265152,0.00407925,0.000291375,0,0,0,0,0,
	0.888889,0.622222,0.339394,0.141414,0.043512,0.009324,0.0012432,
	0.0000777,0,0,0,0,
	0.9,0.654545,0.381818,0.176224,0.0629371,0.0167832,0.00314685,
	0.000370218,0.0000205677,0,0,0,
	0.909091,0.681818,0.41958,0.20979,0.0839161,0.0262238,0.0061703,
	0.00102838,0.000108251,0.00000541254,0,0,
	0.916667,0.705128,0.453297,0.241758,0.105769,0.0373303,0.0103695,
	0.00218306,0.000327459,0.0000311866,0.00000141757,0,
	0.923077,0.725275,0.483516,0.271978,0.12799,0.0497738,0.015718,
	0.00392951,0.000748478,0.000102065,0.00000887523,0.000000369801

iorder,iaz1	 xin
iaz1 = $M_PI*iaz1/180
kk =	iorder
a1	=	.5*zar(0)
c1:
a1 +=	cos(kk*iaz1)*iWeight2D[iorder-1][kk-1]*zar(2*kk-1)
a1 +=	sin(kk*iaz1)*iWeight2D[iorder-1][kk-1]*zar(2*kk)
kk =		kk-1
if	kk > 0 goto c1
		xout			iNorm2D[iorder-1]*a1
endop

;
; Ambisonics Equivalent Panning this is for four speakers only
;
;
opcode	AEP1, a, akiiiikkkkkk ; soundin, order, ixs, iys, izs, idsmax, kx, ky, kz
ain,korder,ixs,iys,izs,idsmax,kx,ky,kz,kdist,kfade,kgain	xin
idists =		sqrt(ixs*ixs+iys*iys+izs*izs)
kpan =			kgain*((1-kfade+kfade*(kx*ixs+ky*iys+kz*izs)/(kdist*idists))^korder)
		xout	ain*kpan*idists/idsmax
endop

; opcode AEP calculates ambisonics equivalent panning for n speaker
; the number n of output channels defines the number of speakers (overloaded function)
; inputs: sound ain, order korder (any real number >= 1)
; ifn = number of the function containing the speaker positions
; position and distance of the sound source kaz,kel,kdist in degrees

opcode AEP, aaaa, akikkk
ain,korder,ifn,kaz,kel,kdist	xin
kaz = $M_PI*kaz/180
kel = $M_PI*kel/180
kx = kdist*cos(kel)*cos(kaz)
ky = kdist*cos(kel)*sin(kaz)
kz = kdist*sin(kel)
ispeaker[] array 0,
  table(3,ifn)*cos(($M_PI/180)*table(2,ifn))*cos(($M_PI/180)*table(1,ifn)),
  table(3,ifn)*cos(($M_PI/180)*table(2,ifn))*sin(($M_PI/180)*table(1,ifn)),
  table(3,ifn)*sin(($M_PI/180)*table(2,ifn)),
  table(6,ifn)*cos(($M_PI/180)*table(5,ifn))*cos(($M_PI/180)*table(4,ifn)),
  table(6,ifn)*cos(($M_PI/180)*table(5,ifn))*sin(($M_PI/180)*table(4,ifn)),
  table(6,ifn)*sin(($M_PI/180)*table(5,ifn)),
  table(9,ifn)*cos(($M_PI/180)*table(8,ifn))*cos(($M_PI/180)*table(7,ifn)),
  table(9,ifn)*cos(($M_PI/180)*table(8,ifn))*sin(($M_PI/180)*table(7,ifn)),
  table(9,ifn)*sin(($M_PI/180)*table(8,ifn)),
  table(12,ifn)*cos(($M_PI/180)*table(11,ifn))*cos(($M_PI/180)*table(10,ifn)),
  table(12,ifn)*cos(($M_PI/180)*table(11,ifn))*sin(($M_PI/180)*table(10,ifn)),
  table(12,ifn)*sin(($M_PI/180)*table(11,ifn))

idsmax   table   0,ifn
kdist    =       kdist+0.000001
kfade    =       .5*(1 - exp(-abs(kdist)))
kgain    =       taninv(kdist*1.5708)/(kdist*1.5708)

a1       AEP1    ain,korder,ispeaker[1],ispeaker[2],ispeaker[3],
                   idsmax,kx,ky,kz,kdist,kfade,kgain
a2       AEP1    ain,korder,ispeaker[4],ispeaker[5],ispeaker[6],
                   idsmax,kx,ky,kz,kdist,kfade,kgain
a3       AEP1    ain,korder,ispeaker[7],ispeaker[8],ispeaker[9],
                   idsmax,kx,ky,kz,kdist,kfade,kgain
a4       AEP1    ain,korder,ispeaker[10],ispeaker[11],ispeaker[12],
                   idsmax,kx,ky,kz,kdist,kfade,kgain	
         xout    a1,a2,a3,a4
endop

;
;	bilinear panning
;
opcode 	pan2d, aaaaaa, akkk
asnd,kaz,kdist,kmode xin
;
; this method needs the size of the room to be defined
; hard coded speaker setup: 45,135,225 and 315 degrees 
; in case of 5 channels: centre at 0 degree on the line connecting left and right
; this implies that the centre speaker is closer to the origin by sqrt(2) which 
; has to be corrected for  
;
;
ksizeX	= 20.001
ksizeY	= 20.001
  
asnd 	=	asnd*taninv(kdist*1.5707963) / (kdist*1.5708)
ky	= kdist*cos(kaz/180*$M_PI)/ksizeY*2
kx	= kdist*sin(kaz/180*$M_PI)/ksizeX*2

;	x=tan(phi)/tan(phi_max)=(g1-g2)/(g1+g2) with the condition g1^2+g2^2=1 this leeads to (similar for y)

krx	=	 (1+kx)/(1-kx)

kg2x	=	sqrt(max(1./(1+krx*krx),0))
kg1x	=	sqrt(1-kg2x*kg2x)
kry	=	 (1+ky)/(1-ky)
kg2y	=	sqrt(max(1./(1+kry*kry),0))
kg1y	=	sqrt(1-kg2y*kg2y)


;	SL, SR

kgainSR =	kg1x*kg2y
kgainSL =	kg2x*kg2y

;	L, R simple for quad

kgainR =	kg1x*kg1y
kgainL =	kg2x*kg1y
kgainC =	0

kgainf =	kgainL+kgainR+0.00001

if kmode!=0 then

;	5.1 including centre speaker either L+C or C+R

if	kx <0 then
kxx	=	(-kx*ksizeX/2-ksizeX/4)/ksizeX*4
krxx	=	(1+kxx)/(1-kxx)
kg1x 	=	sqrt(max(1./(1.+krxx*krxx),0))
kg2x 	=	sqrt(1-kg1x*kg1x)

kgainR = 	0
kgainL =	kg2x*kg1y


kgainC =	kg1x*kg1y
else
kxx	=	(kx*ksizeX/2-ksizeX/4)/ksizeX*4
krxx	=	(1+kxx)/(1-kxx)
kg1x 	=	sqrt(max(1./(1.+krxx*krxx),0))
kg2x 	=	sqrt(1-kg1x*kg1x)
kgainL = 	0
kgainR =	kg2x*kg1y
kgainC =	kg1x*kg1y
endif

kgr	=	(kgainL+kgainR+kgainC)/kgainf
kgainL =	kgainL/kgr
kgainR =	kgainR/kgr
kgainC =	kgainC/kgr

endif

aL	= asnd*kgainL
aR	= asnd*kgainR
;
;	correction for the central speaker's beeing positioned on the line connecting L and R 
;	rather than on a circle - its closer to the origion by a factor sqrt(2)
;
aC	= asnd*kgainC*.70711
aSL	= asnd*kgainSL
aSR	= asnd*kgainSR

a4	= 	aL + aR + aC + aSR + aSL
aLFE	butlp a4, 160

xout aL,aR,aC,aLFE,aSL,aSR
endop

  opcode FilePlay1, a, Skii
;gives mono output regardless your soundfile is mono or stereo
;(if stereo, the two channels will be summed )
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aout		diskin2	Sfil, kspeed, iskip, iloop
else
aout, a2	diskin2	Sfil, kspeed, iskip, iloop
aout	= aout+a2
endif
		xout		aout
  endop

; above is code from surroundUtilities.txt
  
;
;	plotting part
;
instr 1

ktrigin	metro		5

if gkfirst == 1 then
gkfirst	=	0



endif
if ktrigin == 1 then
gknoise	invalue "noise"
if gknoise == 0 then
Sfile		invalue	"_Browse1"
endif
gkgain	invalue "gain"
gkMethod	invalue "method"
gkMovement	invalue "path"
kloop		invalue "loop"
;giMovement	= i(gkMovement)
iMethod 	= i(gkMethod)
endif
giGain	= i(gkgain)

;
; select movement
;
if gkMovement==0 then				; circle with R=3
gkaz   	line		0,80,360		;turns around p7 times in p3 seconds
gkdist = 10.0
elseif gkMovement==1 then				; circle with R=3
gkaz   	line		0,40,360		;turns around p7 times in p3 seconds
gkdist = 5
elseif gkMovement==2 then			; circle with R=1
gkdist = 1
gkaz   	line		0,20,360		;turns around p7 times in p3 seconds
elseif gkMovement==3 then			; circle with R=0.5
gkdist = 0.5
gkaz   	line		0,10,360		;turns around p7 times in p3 seconds
elseif gkMovement==4 then			; spiral out R=0.3...3
gkdist 	line 	0.5,180, 5
gkdist	= 	gkdist % 5
gkaz   	line	0,25,360		;turns around p7 times in p3 seconds
elseif gkMovement==5 then			; spiral in R=3...0.3
gkdist 	line 	1,180, 10
gkdist	= 11	- gkdist % 10
gkaz   	line		0,25,360		;turns around p7 times in p3 seconds
elseif gkMovement==6 then			; dialgonal line R_max=10
kx		getkx
		getRphi	kx,kx
elseif gkMovement==7 then			; horizontal line R_max=10, y=-1
ky		getkx
		getRphi	1,ky
elseif gkMovement==8 then			; vertical line R_max=10, x=2
kx		getkx
		getRphi	kx,2
else
if ktrigin == 1 then
gkposX		invalue "posX"
gkposY		invalue "posY"
gkposY	= -gkposY
endif

;	rotated by 90 degrees

		getRphi	gkposY,gkposX
endif

;
; select panning scheme
;

if iMethod	== 0 then
	vbaplsinit 2,5, -45,0,45,135,225
	iInst1 = 12
	gkVBAPSpread = 0
	gkSpread = 5
elseif iMethod == 1 then
	vbaplsinit 2,5, -45,0,45,135,225
	iInst1 = 12
	gkVBAPSpread = 1
	gkSpread = 5
elseif iMethod == 2 then
	giorder = 1
	iInst1 = 11
	gkHOmod = 1
	gkSpread = 4
	zakinit 3, 1		
elseif iMethod == 3 then
	giorder = 3
	iInst1 = 11
	gkHOmod = 1
	gkSpread = 4
	zakinit giorder*2+1, 1		
elseif iMethod == 4 then
	giorder = 3
	gkHOmod = 0.33
	iInst1 = 11
	gkSpread = 4
	zakinit giorder*2+1, 1		
elseif iMethod	== 5 then
	giorder =3
	gkSpread = 4
	iInst1 = 10
elseif iMethod == 6 then
	giorder = 6
	gkSpread = 4
	iInst1 = 10
elseif iMethod	== 7 then
	iInst1 = 13
	gkmode = 0
	gkSpread = 5
elseif iMethod == 8 then
	iInst1 = 13
	gkmode = 1
	gkSpread = 5
endif

;	sound selection

;
; random number generator
;
kGain		=	ampdb(gkgain)
if gknoise == 1 then

gasnd	rand		p4*kGain,1.1,1
else
;
;	sound from input file
;
iloop		=		i(kloop)

ifilvld	filevalid	Sfile
  if ifilvld == 1 then

	gasnd		FilePlay1	Sfile, 1, 0, iloop
	gasnd =	gasnd*kGain

  else
	outvalue "noise",1
  	gknoise = 1
   	printf_i	"Can't open '%s'! File ignored. - Random noise will be used instead \n", 1, Sfile

  	gasnd	rand		p4*kGain,1.1,1
  endif
endif

	event_i	"i", iInst1, 0, p3
	event_i	"i", 9, 0, p3

endin

instr	13

gaL,gaR,gaC,gaLFE,gaSL,gaSR pan2d gasnd,gkaz,gkdist,gkmode

endin
instr 12
if gkVBAPSpread==1 then
	kspread = 100*taninv(gkdist*1.5707963) / (gkdist*1.5708)
else
	kspread = 0
endif
asnd 	=	gasnd*taninv(gkdist*1.5707963) / (gkdist*1.5708)
gaL,gaC,gaR,gaSR,gaSL vbap asnd,gkaz,0,kspread

;	the volume of the centre speaker is corrected for the fact that 
;	it is placed on the line connecting L and R
  
gaC	=	gaC*0.711
ga4	= 	gaL + gaR + gaC + gaSR + gaSL

gaLFE	butlp ga4, 160

endin

instr 10
gaL,gaR,gaSR,gaSL AEP  gasnd,giorder,17,gkaz,0,gkdist
gaC	=	0
ga4	= 	gaL + gaR + gaC + gaSR + gaSL
gaLFE	butlp ga4, 160
endin

instr 11		
	ambi2D_encode_dist_n		gasnd,giorder,gkaz,gkdist,gkHOmod
aL 	ambi2D_dec_inph 	giorder,315
aR 	ambi2D_dec_inph 	giorder,45
aSR 	ambi2D_dec_inph 	giorder,135
aSL 	ambi2D_dec_inph 	giorder,225
aC	ambi2D_dec_inph 	giorder,0
gaL 	=aL
gaR 	=aR
gaC 	= 0;aC*0.70711
gaSL 	=aSL
gaSR 	=aSR
ga4	= 	gaL + gaR + gaC + gaSR + gaSL
gaLFE	butlp ga4, 160

;	outch	1,gaL,2,gaR,3,gaC,5,gaSL,6,gaSR,4,gaLFE
;	fout	"test.wav", 14, aL,aR,aC,aLFE,aSL,aSR
		
		zacl 	0,2*giorder		; clear the za variables
endin

instr 9; collect global audio signals and show them


	outch	1,gaL,2,gaR,3,gaC,5,gaSL,6,gaSR,4,gaLFE

ktrigdisp	metro		20
idboramp	=		1; 0=raw amps, 1=db
idbrange	=		100;48
if ktrigdisp == 1 then


arsum		=	gaR+gaSR+gaC*.5*1.414
absum		=	gaSL+gaSR
asum		=	gaL+gaR+gaSL+gaSR+gaC*1.414
krsum		rms	arsum, 50.
kbsum		rms	absum, 50.
ksum		rms	asum, 50
k1		rms	gaL, 50
k2		rms	gaR, 50
k3		rms	gaC, 50
k4		rms	gaLFE, 50
k5		rms	gaSL, 50
k6		rms	gaSR, 50
ksumi		=	k1^2+k2^2+(k3*1.41)^2+k5^2+k6^2

; estimator for the number of active speakers


if ksum !=0 then
if i(gkMethod)<7 && i(gkMethod)<2 then
if ksumi-ksum^2/4>0 then
gkSpread	=	ksum/sqrt(ksumi-ksum^2/4)
endif
kswitch	=	3
else
if ksumi-ksum^2/5>0 then
gkSpread	=	ksum/sqrt(ksumi-ksum^2/5)
endif
kswitch	=	4
endif

;corrections for almost equal amplitudes 

gkSpread1	=	-(1/gkSpread - 0.862)/0.166


gkSpread	= (gkSpread/(1+exp(gkSpread-kswitch))+gkSpread1/(1+exp(kswitch-gkSpread)))

gkx		=	krsum/ksum
gky		=	kbsum/ksum
else
gky 		= 0.5
gkx 		= 0.5
endif

Sdgen		sprintfk "%2.2f",int(gkdist*100+0.5)/100
		outvalue "dgen", Sdgen
Sdrec		sprintfk "%2.2f", int(sqrt((gky-0.5)^2+(gkx-0.5)^2)*20*100+0.5)/100
		outvalue "drec", Sdrec
		outvalue "xpos", gkx*20-10
		outvalue "ypos", 10-gky*20
	if gkMovement != 9 then
		ky	= gkdist*cos(gkaz/180*$M_PI)
		kx	= gkdist*sin(gkaz/180*$M_PI)
		outvalue "posX",kx
		outvalue "posY",ky

	endif
gkdbl		=	int(dbamp(k1+0.0000101)*10+0.5)/10
gkdbr		=	int(dbamp(k2+0.0000101)*10+0.5)/10
gkdbc		=	int(dbamp(k3+0.0000101)*10+0.5)/10
gkdbsl	=	int(dbamp(k5+0.0000101)*10+0.5)/10
gkdbsr	=	int(dbamp(k6+0.0000101)*10+0.5)/10
gkdblfe	=	int(dbamp(k4+0.0000101)*10+0.5)/10
Sdbl		sprintfk "%2.1f dB",gkdbl
Sdbr		sprintfk "%2.1f dB",gkdbr
Sdbc		sprintfk "%2.1f dB",gkdbc
Sdbsl		sprintfk "%2.1f dB",gkdbsl
Sdbsr		sprintfk "%2.1f dB",gkdbsr
		outvalue "left",(100+gkdbl-20)/100	
		outvalue "right",(100+gkdbr-20)/100
		outvalue "centre",(100+gkdbc-20)/100
		outvalue "lfe",(100+gkdblfe-20)/100	
		outvalue "sl",(100+gkdbsl-20)/100
		outvalue "sr",(100+gkdbsr-20)/100

		outvalue "dbl",Sdbl
		outvalue "dbr",Sdbr
		outvalue "dbc",Sdbc
		outvalue "dbsl",Sdbsl
		outvalue "dbsr",Sdbsr
Sspread	sprintfk "%2.1f",int(gkSpread*10+0.5)/10
		outvalue "Spread",Sspread
Sgain		sprintfk "%3.1f dB",gkgain
		outvalue "showGain",Sgain
		
endif
endin


</CsInstruments>
<CsScore>
;		 amp	 cf 		bw		turns c
i 1 0 3600    .2 
;
f 17 0 32 -2 1   -45 0 1   45 0 1   135 0 1  225 0 1
e
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>547</width>
 <height>668</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>201</r>
  <g>215</g>
  <b>218</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>8</y>
  <width>730</width>
  <height>680</height>
  <uuid>{0d10a263-fa09-4f63-a598-bb3391682823}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Surround Panning Examples</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>9</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>xpos</objectName>
  <x>82</x>
  <y>350</y>
  <width>300</width>
  <height>300</height>
  <uuid>{72ad4b47-b984-4145-93a9-811473b16047}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>ypos</objectName2>
  <xMin>-10.00000000</xMin>
  <xMax>10.00000000</xMax>
  <yMin>-10.00000000</yMin>
  <yMax>10.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.01088346</yValue>
  <type>point</type>
  <pointsize>6</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>69</x>
  <y>350</y>
  <width>35</width>
  <height>25</height>
  <uuid>{e40a09c6-c582-4ebb-b8a0-1d426b347eda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>L</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>75</x>
  <y>625</y>
  <width>35</width>
  <height>27</height>
  <uuid>{70dac3a7-956d-4a55-b2bf-764c25468728}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SL</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>359</x>
  <y>350</y>
  <width>30</width>
  <height>25</height>
  <uuid>{51bb34fd-94bb-4144-9a80-a48720d39aa1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>R</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>349</x>
  <y>624</y>
  <width>50</width>
  <height>25</height>
  <uuid>{dab201e1-0dfe-452c-8486-d5e4daedaeb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SR</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>219</x>
  <y>350</y>
  <width>80</width>
  <height>25</height>
  <uuid>{db4a035a-fbf7-424e-bb23-09ddecebcbd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>ypos</objectName>
  <x>606</x>
  <y>320</y>
  <width>50</width>
  <height>25</height>
  <uuid>{b9533773-42a8-481f-a67c-8244baaa6573}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.011</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>xpos</objectName>
  <x>463</x>
  <y>320</y>
  <width>50</width>
  <height>25</height>
  <uuid>{6fef2a1f-61bd-422e-874e-32a4fcf2c0e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>16</r>
   <g>255</g>
   <b>0</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Spread</objectName>
  <x>335</x>
  <y>299</y>
  <width>50</width>
  <height>25</height>
  <uuid>{1d23948e-7052-4821-b4e4-b9a8e2b3541c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.1</label>
  <alignment>right</alignment>
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
  <x>421</x>
  <y>320</y>
  <width>30</width>
  <height>25</height>
  <uuid>{da5060e5-5bbd-42ae-9cda-aa1f8b3c6e46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>x = </label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>display11</objectName>
  <x>561</x>
  <y>320</y>
  <width>30</width>
  <height>25</height>
  <uuid>{b1cb09d7-a2e3-4c2b-a5c4-b10dca0d2b7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>y =</label>
  <alignment>left</alignment>
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
  <x>76</x>
  <y>299</y>
  <width>280</width>
  <height>25</height>
  <uuid>{cd7b1098-9388-41a4-a27f-534759cb4358}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RMS Weighted Estimate on # of Active Speakers:</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBController">
  <objectName>left</objectName>
  <x>80</x>
  <y>167</y>
  <width>30</width>
  <height>100</height>
  <uuid>{c5f435d0-ec1f-42a2-b9fc-b1d9baaac824}</uuid>
  <visible>true</visible>
  <midichan>3</midichan>
  <midicc>0</midicc>
  <objectName2>left</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.48500000</xValue>
  <yValue>0.48500000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
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
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>right</objectName>
  <x>120</x>
  <y>167</y>
  <width>30</width>
  <height>100</height>
  <uuid>{2cbbc115-336e-41f5-b6fe-5bd1a7522804}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>right</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.48500000</xValue>
  <yValue>0.48500000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
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
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>centre</objectName>
  <x>160</x>
  <y>167</y>
  <width>30</width>
  <height>100</height>
  <uuid>{106cbf5a-ea37-42eb-b5c5-1214a56e4fd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>centre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-0.19800000</xValue>
  <yValue>-0.19800000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
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
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>lfe</objectName>
  <x>200</x>
  <y>167</y>
  <width>30</width>
  <height>100</height>
  <uuid>{eb284123-e957-4ea2-9093-4937b702595a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>lfe</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.58600000</xValue>
  <yValue>0.58600000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>118</r>
   <g>117</g>
   <b>116</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>sl</objectName>
  <x>240</x>
  <y>167</y>
  <width>30</width>
  <height>100</height>
  <uuid>{f15734d6-3078-4e69-8277-4386c44c4ba9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>sl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.48500000</xValue>
  <yValue>0.48500000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
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
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>sr</objectName>
  <x>280</x>
  <y>167</y>
  <width>30</width>
  <height>100</height>
  <uuid>{d74c20c9-63e1-40be-9a17-5c64465ec678}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>sr</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.48500000</xValue>
  <yValue>0.48500000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>88</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{47b8994a-9c8b-4319-95fe-4d93e52cd709}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>L</label>
  <alignment>left</alignment>
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
  <x>128</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{f412e5f3-90c3-4e46-b5aa-d486de31ed91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>R</label>
  <alignment>left</alignment>
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
  <x>166</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{8fd04493-1f4d-4ab5-8432-667e975db766}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>left</alignment>
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
  <x>199</x>
  <y>275</y>
  <width>35</width>
  <height>25</height>
  <uuid>{85a9847c-a9f7-461d-8976-b286c12c0549}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LFE</label>
  <alignment>left</alignment>
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
  <x>245</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{e811cbea-8a1d-4750-a129-88de8b595260}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SL</label>
  <alignment>left</alignment>
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
  <x>280</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{63f90c8b-718d-4ec8-bd24-1da6ee77e739}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SR</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>method</objectName>
  <x>260</x>
  <y>55</y>
  <width>350</width>
  <height>30</height>
  <uuid>{9a15a2c6-15e8-4e8b-a5f6-091b002e1591}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>VBAP</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>VBAP + Dist. Dependent Spread</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1st Order Ambisonics in Phase</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3rd Order Ambisonics in Phase</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3rd Order Ambisonics in Phase kHOmod=0.33</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3rd Order AEP</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6th order AEP</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Biliniear Panning 4 Channels+LFE</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Bilinear Panning 5.1</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>path</objectName>
  <x>260</x>
  <y>90</y>
  <width>350</width>
  <height>30</height>
  <uuid>{00e1fdcc-d308-4859-8815-697e020e0555}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>circle r=10</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>circle r=5</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>circle r=1</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>circle r=0.5</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>spiral out from 0.5 to 5</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>spiral in from 10 to 1</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>diogonal line  </name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> horizontal line y=-1</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> vertical line x=2</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>select position with the controller on the right</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>9</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>80</x>
  <y>55</y>
  <width>160</width>
  <height>30</height>
  <uuid>{a074308b-bcf8-4286-919f-e964ba598889}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Panning Method</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <x>80</x>
  <y>90</y>
  <width>160</width>
  <height>25</height>
  <uuid>{8c48ea70-dbab-45b2-8f31-f2e97dcb4c52}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Movement</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <x>70</x>
  <y>187</y>
  <width>240</width>
  <height>2</height>
  <uuid>{ab7931e8-5875-4320-8bdd-258f3811e28f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>207</y>
  <width>240</width>
  <height>2</height>
  <uuid>{6798fc6c-8f9a-421b-81a6-01459c35af3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>label30</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>227</y>
  <width>240</width>
  <height>2</height>
  <uuid>{899c7dee-1490-4910-b9df-c14e0af7a91c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>247</y>
  <width>240</width>
  <height>2</height>
  <uuid>{36d286d9-d8b5-420b-8b22-dc63f5969e2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>gain</objectName>
  <x>330</x>
  <y>167</y>
  <width>20</width>
  <height>100</height>
  <uuid>{386b9630-1125-4a99-b2f9-d9416fdba5b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-20.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>-0.40000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>321</x>
  <y>275</y>
  <width>80</width>
  <height>25</height>
  <uuid>{160bd81b-8810-4ce7-af4a-eab83a93c250}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>left</alignment>
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
  <x>76</x>
  <y>499</y>
  <width>310</width>
  <height>2</height>
  <uuid>{7af1e286-1194-46ba-90e0-2d81c77d7735}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>231</x>
  <y>346</y>
  <width>2</width>
  <height>310</height>
  <uuid>{5830f755-3801-48ce-9c40-df88c162b91a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>82</x>
  <y>352</y>
  <width>300</width>
  <height>300</height>
  <uuid>{1d5b9dab-225b-410c-bf90-697ea7d77e3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>150</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>157</x>
  <y>424</y>
  <width>150</width>
  <height>150</height>
  <uuid>{e13e844c-7894-4b4e-8506-7d24e14b3139}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>75</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>38</x>
  <y>238</y>
  <width>30</width>
  <height>25</height>
  <uuid>{beaebb72-ed92-4b5e-b251-759d69675597}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-60</label>
  <alignment>right</alignment>
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
  <x>38</x>
  <y>217</y>
  <width>30</width>
  <height>25</height>
  <uuid>{80666728-859b-49fe-b13b-4c988ebce72f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-40</label>
  <alignment>right</alignment>
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
  <x>38</x>
  <y>196</y>
  <width>30</width>
  <height>25</height>
  <uuid>{8f312f33-0384-436a-ae53-51dde751cee6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-20</label>
  <alignment>right</alignment>
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
  <x>38</x>
  <y>175</y>
  <width>30</width>
  <height>25</height>
  <uuid>{d03e1f22-e9d2-4597-9582-47d9eba84dcf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0</label>
  <alignment>right</alignment>
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
  <x>39</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{ed8ee57e-2081-4227-8023-95a4156dc87e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>dB</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>showGain</objectName>
  <x>350</x>
  <y>207</y>
  <width>60</width>
  <height>25</height>
  <uuid>{6f89d811-7af1-44c4-97e2-5db532be0670}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.4 dB</label>
  <alignment>left</alignment>
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
  <x>31</x>
  <y>151</y>
  <width>36</width>
  <height>25</height>
  <uuid>{04441900-35da-4bc2-a895-4a9e33170454}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RMS</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>posX</objectName>
  <x>466</x>
  <y>275</y>
  <width>80</width>
  <height>25</height>
  <uuid>{703cc38d-65d2-4386-a3e7-657fc8ea8e7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>21</g>
   <b>3</b>
  </bgcolor>
  <resolution>0.50000000</resolution>
  <minimum>-10</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>posY</objectName>
  <x>605</x>
  <y>275</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7492030e-d24b-45d2-82b8-9b8822f874fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>9</g>
   <b>0</b>
  </bgcolor>
  <resolution>0.50000000</resolution>
  <minimum>-10</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>421</x>
  <y>275</y>
  <width>30</width>
  <height>26</height>
  <uuid>{139b2b44-d1b9-4c54-b15a-95e1fd9e3846}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>x :</label>
  <alignment>left</alignment>
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
  <x>566</x>
  <y>275</y>
  <width>30</width>
  <height>25</height>
  <uuid>{bab7ef2e-8b5e-4ba5-90e3-2d60e7a681e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>y :</label>
  <alignment>left</alignment>
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
  <x>400</x>
  <y>651</y>
  <width>150</width>
  <height>25</height>
  <uuid>{f8233149-664d-4c1f-af8e-c201aa8072f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Distance from Origin</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>dgen</objectName>
  <x>579</x>
  <y>651</y>
  <width>50</width>
  <height>25</height>
  <uuid>{f4b5a0ad-9173-4fd3-8f8c-2defb75f83bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.00</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>21</g>
   <b>12</b>
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
  <x>531</x>
  <y>651</y>
  <width>63</width>
  <height>25</height>
  <uuid>{6b8fe310-9fb1-4c05-8c22-63391668f1ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>generated</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>5</g>
   <b>2</b>
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
  <objectName>drec</objectName>
  <x>682</x>
  <y>651</y>
  <width>50</width>
  <height>25</height>
  <uuid>{b660168a-70fb-4836-af11-1ad7b5e671ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.01</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>5</r>
   <g>139</g>
   <b>13</b>
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
  <x>637</x>
  <y>651</y>
  <width>60</width>
  <height>25</height>
  <uuid>{ef0b6415-718d-40f4-acbc-e2b69e980377}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>observed</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>157</g>
   <b>13</b>
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
  <objectName>dbl</objectName>
  <x>63</x>
  <y>320</y>
  <width>59</width>
  <height>25</height>
  <uuid>{b1c6c68f-8e06-4cdf-8772-fcf1ac452ee8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-31.5 dB</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>dbr</objectName>
  <x>345</x>
  <y>320</y>
  <width>59</width>
  <height>25</height>
  <uuid>{aabd0668-c1af-4da2-a6e0-579d719afc2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-31.5 dB</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>dbsr</objectName>
  <x>345</x>
  <y>650</y>
  <width>59</width>
  <height>25</height>
  <uuid>{6a977ca6-e009-485e-bb12-4898df5e99aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-31.5 dB</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>dbsl</objectName>
  <x>63</x>
  <y>650</y>
  <width>59</width>
  <height>27</height>
  <uuid>{77c4e582-18df-42ff-8db1-401d5bd72979}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-31.5 dB</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>dbc</objectName>
  <x>205</x>
  <y>320</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2e960892-fef9-4f0a-bddc-2f8316643804}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-99.8 dB</label>
  <alignment>left</alignment>
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
  <x>80</x>
  <y>125</y>
  <width>80</width>
  <height>25</height>
  <uuid>{706d71a2-101a-439f-98bb-d7123750cb4d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sound</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>noise</objectName>
  <x>150</x>
  <y>129</y>
  <width>20</width>
  <height>20</height>
  <uuid>{fe579139-be80-4c03-9a0c-8944a178422b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>125</y>
  <width>180</width>
  <height>25</height>
  <uuid>{683b65cc-873a-4001-95d5-512c7b6184fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Noise - or sound file:</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <x>330</x>
  <y>125</y>
  <width>100</width>
  <height>32</height>
  <uuid>{0b84c0cb-d917-4820-8e08-5afd02eab013}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/jh/Desktop/SpracheStereo.aiff</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop</objectName>
  <x>440</x>
  <y>129</y>
  <width>20</width>
  <height>20</height>
  <uuid>{45f7773e-5db1-4123-96e8-1fd3d8e6fc81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>461</x>
  <y>125</y>
  <width>80</width>
  <height>30</height>
  <uuid>{93b2564d-3cce-4d20-9787-63575a8396a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
 <bsbObject version="2" type="BSBController">
  <objectName>posX</objectName>
  <x>420</x>
  <y>349</y>
  <width>300</width>
  <height>300</height>
  <uuid>{450f25fd-b38a-47e0-92fe-122c39e9f934}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>posY</objectName2>
  <xMin>-10.00000000</xMin>
  <xMax>10.00000000</xMax>
  <yMin>-10.00000000</yMin>
  <yMax>10.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>6</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>234</r>
   <g>6</g>
   <b>4</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>410</x>
  <y>350</y>
  <width>35</width>
  <height>25</height>
  <uuid>{09a95d6d-0a56-4f06-ad52-d6b5492a15f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>L</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>415</x>
  <y>625</y>
  <width>35</width>
  <height>27</height>
  <uuid>{659de5f7-8d91-4da2-a292-aaaf3aeb52b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SL</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>695</x>
  <y>350</y>
  <width>30</width>
  <height>25</height>
  <uuid>{43c5e377-55b4-4e6f-8647-1f46cedea5ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>R</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>685</x>
  <y>625</y>
  <width>32</width>
  <height>25</height>
  <uuid>{e11f0d15-71a0-44c6-860b-e68a5c95b34b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SR</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>560</x>
  <y>350</y>
  <width>30</width>
  <height>25</height>
  <uuid>{8083da41-b809-4d09-bebb-6687e8c2b4f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>420</x>
  <y>248</y>
  <width>300</width>
  <height>29</height>
  <uuid>{a4ddf02e-06cf-4b3a-bd71-f431172092d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Selected / Generated Position</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>237</r>
   <g>20</g>
   <b>4</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>420</x>
  <y>300</y>
  <width>300</width>
  <height>25</height>
  <uuid>{43b48692-c213-4e3c-adcd-3874e4e27000}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reconstructed Position</label>
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
  <x>560</x>
  <y>499</y>
  <width>20</width>
  <height>2</height>
  <uuid>{6b896c7c-e7f0-4887-b642-647295727c64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>570</x>
  <y>489</y>
  <width>2</width>
  <height>20</height>
  <uuid>{65c95c8b-ba04-4553-a488-32e98862a687}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>405</x>
  <y>150</y>
  <width>332</width>
  <height>100</height>
  <uuid>{c2913ab1-ca0d-412e-aaf3-ad2781217c89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>For "select position.." from the menu "Movement" the right controller below allows selecting a position by clicking onto the controller field. The panning follows any mouse movement as long as the mouse will be kept pressed. For other selections from the menue "Movement" the red dot in this field reflects the generated postion used for the panning while the green dot in the left field shows the position reconstructed from the amplitudes.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>11</fontsize>
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
