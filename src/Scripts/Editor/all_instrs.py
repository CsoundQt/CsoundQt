# lists all instruments in the current orc
# and inserts as a string at curser position
# joachim heintz mar 2012

orc = q.getOrc()
lines = orc.splitlines()
allinstrs = ""
for line in lines:
    line = line.lstrip()
    els = line.split()
    if els and els[0] == "instr":
       allinstrs = "%s %s" % (allinstrs, els[1])
print "instruments in this csd:"
print '"' + allinstrs[1:] + '"'
q.insertText('"' + allinstrs[1:] + '"')




