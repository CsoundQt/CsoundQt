<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

instr 1	
itabc = p7                      ;table with the 25 critical band frequency edges
iscal = 1                       ;reson filter scaling factor		
iamp = p4                       ;amplitude scaler
iband = p5                      ;energy band required
if1     table   iband-1, itabc  ;lower edge
if2     table   iband, itabc    ;upper edge
idif    = if2-if1		
icf     = if1 + idif*.5         ;center frequency value
ibw     = icf*p6                ;bandwidth
iatsfile = p8                   ;ats file name

idur    ATSinfo iatsfile, 7     ;get duration

ktime   line    0, p3, idur     ;time pointer

ken     ATSreadnz ktime, iatsfile, iband        ;get frequency and amplitude values
anoise  gauss 1
aout    reson anoise*sqrt(ken), icf, ibw, iscal ;synthesize with amp and freq scaling

        out aout*iamp
endin

</CsInstruments>
<CsScore>
; sine wave table
f1 0 16384 10 1
;the 25 critical bands edge's frequencies
f2 0 32 -2 0 100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 \
           2700 3150 3700 4400 5300 6400 7700 9500 12000 15500 20000

;an ats file name
#define atsfile #"../ats-files/female-speech.ats"#

;a macro that synthesize the noise data along all the 25 critical bands
#define all_bands(start'dur'amp'bw'file)
#
i1 	$start 	$dur 	$amp	1	$bw	2	$file	
i1 	. 	. 	.	2	.	.	$file
i1 	. 	. 	.	3	.	.	.
i1 	. 	. 	.	4	.	.	.
i1 	. 	. 	.	5	.	.	.
i1 	. 	. 	.	6	.	.	.
i1 	. 	. 	.	7	.	.	.
i1 	. 	. 	.	8	.	.	.
i1 	. 	. 	.	9	.	.	.
i1 	. 	. 	.	10	.	.	.
i1 	. 	. 	.	11	.	.	.
i1 	. 	. 	.	12	.	.	.
i1 	. 	. 	.	13	.	.	.
i1 	. 	. 	.	14	.	.	.
i1 	. 	. 	.	15	.	.	.
i1 	. 	. 	.	16	.	.	.
i1 	. 	. 	.	17	.	.	.
i1 	. 	. 	.	18	.	.	.
i1 	. 	. 	.	19	.	.	.
i1 	. 	. 	.	20	.	.	.
i1 	. 	. 	.	21	.	.	.
i1 	. 	. 	.	22	.	.	.
i1 	. 	. 	.	23	.	.	.
i1 	. 	. 	.	24	.	.	.
i1 	. 	. 	.	25	.	.	.
#

;ditto...original sound duration is 3.633 secs.
;stretched 300%
$all_bands(0'10.899'1'.05'$atsfile)

e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia