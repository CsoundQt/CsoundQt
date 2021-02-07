# 02_Text.py

# You can query text from any open tab through the Python API
q.loadDocument("02_Text.py")
text = q.getFullText()

# This will print the number 4 on the Python Console,
# which is where you will see output from Python commands
index = text.index('_Text')
print('Position of "_T":', index)

# Now we will load a csd file and look at its orchestra and score
# Notice that paths are relative to the python file being executed
# or the currently open document if only executing sections
q.loadDocument("basic.csd")
text = q.getFullText()
orc = q.getOrc()
sco = q.getSco()

index1 = text.index('instr 1')
index2 = orc.index('instr 1')
print('"instr 1" in text and orc:', index1, index2)

print("Score is: ", sco)

# Make sure this is visible after running the script
q.loadDocument("02_Text.py") # This will switch back to this file

# You can also call these functions for other tabs:
doc = q.getDocument("basic.csd") # get document index without switching to it
sco = q.getSco(doc) # Will get the score, even though this file is currently selected!

print("Score from other file: ", sco)
