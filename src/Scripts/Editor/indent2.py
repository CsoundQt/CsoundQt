# indents the opcode at n spaces from the left
# and the first argument at m spaces, if possible:
# output    opcode    arg1, arg2
# joachim heintz 2012
# using code by andrés cabrera

# -*- coding: utf-8 -*-

import PythonQt.QtGui as pqt

# tell here which keywords (at first position) leave a line unchanged
excpList = ('instr', 'endin', 'if', 'elseif', 'endif', 'opcode', 'endop', 'sr', 'ksmps', 'kr', 'nchnls', '0dbfs')

def exceptions(line, excptlis):
    """returns t if line starts with a word from excptlis"""
    firstWord = line.split()[0]
    if firstWord in excptlis:
        return True
    else:
        return False
        
def long_comment(line, prevState):
    """returns 1 if a '/* ...*/' comment is active, 0 otherwise"""
    if line.rstrip()[-2:] == '*/':
        return 0
    elif line.lstrip()[0:2] == '/*':
        return 1
    else:
        return prevState
        
def comment(line, longComment):
    """returns t if line is a comment"""
    if longComment == 1 or line.lstrip()[0] == ';' or line.rstrip()[-2:] == '*/':
        return True
    else:
        return False

def listUdos(orcText):
    """list all udo names in orcText"""
    res = []
    prev = 0
    for line in orcText.splitlines():
        long = long_comment(line, prev)
        if line.strip() and not comment(line, long):
            #stop if orc header has ended
            if line.split()[0] == "instr":
                break
            #otherwise append all udo names
            elif line.split()[0] == "opcode":
                udonam = line.split()[1].rstrip(',')
                res.append(udonam)
        prev = long
    return res

        
def indent():
    selection = q.getSelectedText()  # Get current selection
    udoList = listUdos(q.getOrc())
    if selection == "": # If no selection
        orcText = q.getOrc() # use complete orc section
    else:
        orcText = selection

    newOrcText = ""
    prev = 0 #initial value for long comment
    for line in orcText.splitlines():
        #do nothing if empty line, comment or exception
        longComment = long_comment(line, prev)
        if line.strip() == "" or comment(line, longComment) or exceptions(line, excpList):
            newline = line
        else:
            words = line.split()
            pos = 0
            opcdpos = 0
            firstarg = 0
            opcd = 0 #opcode has not already been in this line
            newline = ""
            for word in words:
                #word is the opcode
                if q.opcodeExists(word) or word in udoList:
                    #opcode position is more left than desired
                    if opcdpos < space_left.value:
                        format = '%%-%ds%%s ' % space_left.value
                        newline = format % (newline, word)
                        opcdpos = space_left.value #new position of the opcode
                    #opcode position stays at pos
                    else:
                        newline = '%s%s ' % (newline, word)
                    pos = opcdpos + len(word) + 1
                    firstarg = 1 #next word is the first argument
                    opcd = 1 #opcode has been already
                #word is the first argument
                elif firstarg == 1:
                    if pos - opcdpos < space_left.value and pos < space_right.value:
                        format = '%%-%ds%%s ' % space_right.value 
                        newline = format % (newline, word)
                        pos = space_right.value + len(word) + 1
                    else:
                        newline = '%s%s ' % (newline, word)
                        pos = pos + len(word) + 1
                    firstarg = 0 #reset 
                #all other cases
                else:
                    newline = '%s%s ' % (newline, word)
                    pos = pos + len(word) + 1
                    if opcd == 0:
                        opcdpos = pos
        newOrcText = "%s\n%s" % (newOrcText, newline.rstrip())
        prev = longComment #reset prev for analysing long comments

    #remove starting newline
    newOrcText = newOrcText[1:]

    if (selection == ""):
        q.setOrc(newOrcText)  # Write all the orchestra section
    else:
        q.insertText(newOrcText)  # Peplaces the current selection


#info and render window
w = pqt.QWidget() # Create main widget
w.setGeometry(50,50, 400,450)
l = pqt.QGridLayout(w) # Layout to organize widgets
w.setLayout(l)
w.setWindowTitle("Csound Code Indentation")

space_left = pqt.QSpinBox(w)
space_left.setValue(11)
l.addWidget(space_left, 2, 0)

space_right = pqt.QSpinBox(w)
space_right.setValue(22)
l.addWidget(space_right, 3, 0)

renderButton = pqt.QPushButton("Indent!",w)
text = pqt.QTextBrowser(w)
l.addWidget(renderButton, 4, 0)
l.addWidget(text, 1, 0)
renderButton.connect("clicked()", indent) #execute at click

info = """Indents the opcode name at 11 spaces from the left
and the first argument at 22 spaces, if possible:
output1   opcode1   arg1, arg2
output2   opcode2   arg3
(Instead of 11 / 22, you can choose other values in the spin boxes below.)

Lines starting with instr / endin, opcode / endop, if / elseif / endif will be left untouched. The same for comment lines or the statements in the orchestra header.

Select any part of your orchestra code and click on the button above. If you do not select anything, the whole orchestra code will be cleaned up.

Joachim Heintz 2012, using code by Andres Cabrera"""
text.setText(info)

w.show()












