<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -n -m0
</CsOptions>
<CsInstruments>
ksmps = 32

           seed       0

  opcode PrtArr1k, 0, k[]POVVO
kArr[], ktrig, kstart, kend, kprec, kppr xin
kprint     init       0
kndx       init       0
if ktrig > 0 then
kppr       =          (kppr == 0 ? 10 : kppr)
kend       =          (kend == -1 || kend == .5 ? lenarray(kArr) : kend)
kprec      =          (kprec == -1 || kprec == .5 ? 3 : kprec)
kndx       =          kstart
Sformat    sprintfk   "%%%d.%df, ", kprec+3, kprec
Sdump      sprintfk   "%s", "["
loop:
Snew       sprintfk   Sformat, kArr[kndx]
Sdump      strcatk    Sdump, Snew
kmod       =          (kndx+1-kstart) % kppr
 if kmod == 0 && kndx != kend-1 then
           printf     "%s\n", kprint+1, Sdump
Sdump      strcpyk    " "
 endif
kprint     =          kprint + 1
           loop_lt    kndx, 1, kend, loop
klen       strlenk    Sdump
Slast      strsubk    Sdump, 0, klen-2
           printf     "%s]\n", kprint+1, Slast
endif
  endop
  

  instr SimplePrinting
kArr[]     fillarray  1, 2, 3, 4, 5, 6, 7
kPrint     metro      1
           prints     "\nSimple Printing with defaults, once a second:\n"
           PrtArr1k   kArr, kPrint
  endin

  instr EatTheHead
kArr[]     fillarray  1, 2, 3, 4, 5, 6, 7
kPrint     metro      1
kStart     init       0
           prints     "\nChanging the start index:\n"
 if kPrint == 1 then
           PrtArr1k   kArr, 1, kStart
kStart     +=         1
 endif
  endin

  instr EatTheTail
kArr[]     fillarray  1, 2, 3, 4, 5, 6, 7
kPrint     metro      1
kEnd       init       7
           prints     "\nChanging the end index:\n"
 if kPrint == 1 then
           PrtArr1k   kArr, 1, 0, kEnd
kEnd       -=         1
 endif
  endin

  instr PrintFormatted
;create an array with 24 elements
kArr[] init 24

;fill with random values
kndx = 0
until kndx == lenarray(kArr) do
kArr[kndx] rnd31 10, 0
kndx += 1
od

;print
           prints     "\nPrinting with precision=5 and 4 elements per row:\n"
           PrtArr1k   kArr, 1, 0, -1, 5, 4
           printks    "\n", 0

;turnoff after first k-cycle
turnoff
  endin

</CsInstruments>
<CsScore>
i "SimplePrinting" 0 5
i "EatTheHead" 6 5
i "EatTheTail" 12 5
i "PrintFormatted" 18 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

