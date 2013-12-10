<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>
nchnls = 2
sr = 44100
ksmps = 10
0dbfs = 1
#define SIZE #128#
instr 1
ipos ftgen 1, 0, $SIZE., 10, 1
irate = .005
ifnvel ftgen 6, 0, $SIZE., -7, 0, $SIZE., 0
ifnmass ftgen 2, 0, $SIZE., -7, 1, $SIZE., 1
ifnstif ftgen 3, 0, $SIZE.*$SIZE.,-23, "circularstring-$SIZE."
ifncentr ftgen 4, 0, $SIZE., -7, 0, $SIZE., 2
ifndamp ftgen 5, 0, $SIZE., -7, 1, $SIZE., 1
imass = 2
istif = 1.1
icentr = .1
idamp = -0.01
ileft = 0.
iright = .5
ipos = 0.
istrngth = 0.
ain = 0
idisp = 0
id = 8
	
scanu 1, irate, ifnvel, ifnmass, ifnstif, ifncentr, ifndamp, imass, istif, icentr, idamp, ileft, iright, ipos, istrngth, ain, idisp, id
scanu 1,.007,6,2,3,4,5, 2, 1.10 ,.10 ,0 ,.1 ,.5, 0, 0,ain,1,2;
iamp = .2
ifreq = 200
a1 scans iamp, ifreq, 7, id, 4
a1 dcblock a1
outs a1, a1
endin
</CsInstruments>
<CsScore>
#define SIZE #128#
f7 0 $SIZE. -7 0 $SIZE. $SIZE.
i 1 0 5
f7 5 $SIZE. -7 0 63 [$SIZE.-1] 63 0
i 1 5 5
f7 10 $SIZE. -7 [$SIZE.-1] 64 1 63 [$SIZE.-1]
i 1 10 5
</CsScore>
</CsoundSynthesizer>
;Example by Christopher Saunders
