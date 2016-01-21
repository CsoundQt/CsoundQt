<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm128 ;no sound and reduced messages
</CsOptions>
<CsInstruments>
ksmps = 32

instr i_local
iArr[] array  1, 2, 3
       prints "   iArr[0] = %d   iArr[1] = %d   iArr[2] = %d\n",
              iArr[0], iArr[1], iArr[2]
endin

instr i_local_diff ;same name, different content
iArr[] array  4, 5, 6
       prints "   iArr[0] = %d   iArr[1] = %d   iArr[2] = %d\n",
              iArr[0], iArr[1], iArr[2]
endin

instr i_global
giArr[] array 11, 12, 13
endin

instr i_global_read ;understands giArr though not defined here
       prints "   giArr[0] = %d   giArr[1] = %d   giArr[2] = %d\n",
              giArr[0], giArr[1], giArr[2]
endin

instr k_local
kArr[] array  -1, -2, -3
       printks "   kArr[0] = %d   kArr[1] = %d   kArr[2] = %d\n",
               0, kArr[0], kArr[1], kArr[2]
       turnoff
endin

instr k_local_diff
kArr[] array  -4, -5, -6
       printks "   kArr[0] = %d   kArr[1] = %d   kArr[2] = %d\n",
               0, kArr[0], kArr[1], kArr[2]
       turnoff
endin

instr k_global
gkArr[] array -11, -12, -13
       turnoff
endin

instr k_global_read
       printks "   gkArr[0] = %d   gkArr[1] = %d   gkArr[2] = %d\n",
               0, gkArr[0], gkArr[1], gkArr[2]
       turnoff
endin
</CsInstruments>
<CsScore>
i "i_local" 0 0
i "i_local_diff" 0 0
i "i_global" 0 0
i "i_global_read" 0 0
i "k_local" 0 1
i "k_local_diff" 0 1
i "k_global" 0 1
i "k_global_read" 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
