<CsoundSynthesizer>
<CsInstruments>
instr 1
endin
</CsInstruments>
<CsScore bin="python3">
from sys import argv
print("File to read = '%s'" % argv[0])
print("File to write = '%s'" % argv[1])
</CsScore>
</CsoundSynthesizer>
