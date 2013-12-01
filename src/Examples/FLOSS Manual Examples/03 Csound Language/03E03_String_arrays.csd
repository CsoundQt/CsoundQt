<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm128 ;no sound and reduced messages
</CsOptions>
<CsInstruments>

instr 1
String   =       "onetwothree"
S_Arr[]  init    3
S_Arr[0] strsub  String, 0, 3
S_Arr[1] strsub  String, 3, 6
S_Arr[2] strsub  String, 6
         printf_i "S_Arr[0] = '%s'\nS_Arr[1] = '%s'\nS_Arr[2] = '%s'\n", 1,
                  S_Arr[0], S_Arr[1], S_Arr[2]
endin

</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
