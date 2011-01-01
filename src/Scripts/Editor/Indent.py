# -*- coding: utf-8 -*-

selection = q.getSelectedText()  # Get current selection
# Careful, you must select a whole instrument block, or you will get strange indentation
if selection == "": # If no selection
    orcText = q.getOrc() # use complete orc section
else:
    orcText = selection

orcLines = orcText.splitlines()  # split lines

newOrcText = ""
level = 0 # indentation level for the current line
newlevel = 0 # indentation level for following lines

for line in orcLines:  # go through all the lines
    line = line.strip() # remove initial and trailing whitespace
    
    if line.find("instr") == 0:
        level = 0
        newlevel = 1
    elif line.find("endin") == 0:
        level = 0
    elif line.find("if ") == 0:
        newlevel = level + 1
    elif line.find("elseif ") == 0:
        level -= 1
        newlevel = level + 1
    elif line.find("endif") == 0:
        level -= 1
        newlevel = level
    newOrcText += "\t" * level # add necessary tabs
    newOrcText += line + "\n"
    level = newlevel

if (selection == ""):
    q.setOrc(newOrcText)  # Write all the orchestra section
else:
    if selection[-1] != "\n":  # If selection doesn't end with line ending
        newOrcText = newOrcText[0:-2] # Remove extra line ending
    q.insertText(newOrcText)  # Peplaces the current selection