<CsoundSynthesizer>

<CsOptions>

</CsOptions>
;--opcode-lib=serialOpcodes.dylib -odac
<CsInstruments>

ksmps = 500 ; the default krate can be too fast for the arduino to handle
0dbfs = 1

instr 1
	iPort	serialBegin	"/COM4", 9600
	kVal	serialRead 	iPort
		printk2		kVal
endin


</CsInstruments>
<CsScore>
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>
