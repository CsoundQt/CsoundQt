# By Andres Cabrera 2012

import PythonQt.QtGui as pqt
import PythonQt.QtCore as pqtc

def changeToChnget(text):
    lines = text.split("\n")
    newText = ""
    channels = {}
    strchannels = {}
    for line in lines:
        if line.count("invalue") > 0 :
            line = line.replace("invalue", "chnget")
            arg1Index = line.find("chnget") + 7
            arg1EndIndex = line.find(";", arg1Index)
            if arg1EndIndex == -1:
                arg1EndIndex = None
            arg1 = line[arg1Index : arg1EndIndex].strip()
            if arg1.startswith('"_'): # reserved channels can only be currently used with invalue!
                line = line.replace("chnget", "invalue") # put it back
                newText += line + "\n"
                continue
            if line.strip().startswith('S'):
                if arg1[1:-1] in strchannels:
                    strchannels[arg1[1:-1]] |= 1
                else:
                    strchannels[arg1[1:-1]] = 1
            else:
                if arg1[1:-1] in channels:
                    channels[arg1[1:-1]] |= 1
                else:
                    channels[arg1[1:-1]] = 1
            # TODO accumulate channels
        elif line.count("outvalue") > 0:
            line = line.replace("outvalue", "chnset")
            arg1Index = line.find("chnset") + 7
            arg2Index = line.find(",", arg1Index) + 1
            arg2EndIndex = line.find(";", arg2Index)
            if arg2EndIndex == -1:
                arg2EndIndex = None
            comment = line[arg2EndIndex :]
            arg1 = line[arg1Index : arg2Index - 1].strip()
            arg2 = line[arg2Index : arg2EndIndex].strip()
            if arg1.startswith('"_'): # reserved channels can only be currently used with invalue!
                line = line.replace("chnset", "outvalue") # put it back
                newText += line + "\n"
                continue
            line = line[:arg1Index] + " " +  arg2 + ", " + arg1
            if (arg2EndIndex > 0):
                line += " " + comment
            if arg2.strip().startswith('S') or arg2.strip().startswith('"'):
                if arg1[1:-1] in channels:
                    strchannels[arg1[1:-1]] |= 2
                else:
                    strchannels[arg1[1:-1]] = 2
            else:
                if arg1[1:-1] in channels:
                    channels[arg1[1:-1]] |= 2
                else:
                    channels[arg1[1:-1]] = 2
        newText += line + "\n"
    chnText = ''
    index = 0
    if len(channels) > 0 : # there are channels
        index = newText.find('opcode') # TODO use regex here to find start of line!
        if index < 0:
            index = newText.find('instr') # TODO use regex here to find start of line!
        for chan in sorted(channels):
            chnText += 'chn_k "' + chan + '", ' + str(channels[chan]) + '\n'
    if len(strchannels) > 0 : # there are channels
        index = newText.find('instr') # TODO use regex here to find start of line!
        for chan in sorted(strchannels):
            chnText += 'chn_S "' + chan + '", ' + str(strchannels[chan]) + '\n'
    newText = newText[:index] + chnText + '\n' + newText[index:]
    q.setOrc(newText)

def changeToInvalue(text):
    lines = text.split("\n")
    newText = ""
    for line in lines:
        if line.count("chnget") > 0:
            line = line.replace("chnget", "invalue")
        elif line.count("chnset")  > 0:
            line = line.replace("chnset", "outvalue")
            arg1Index = line.find("outvalue") + 8
            arg2Index = line.find(",") + 1
            arg2EndIndex = line.find(";", arg2Index)
            if arg2EndIndex == -1:
                arg2EndIndex = None
            comment = line[arg2EndIndex :]
            arg1 = line[arg1Index : arg2Index - 1].strip()
            arg2 = line[arg2Index : arg2EndIndex].strip()
            line = line[:arg1Index] + " " +  arg2 + ", " + arg1
            if (arg2EndIndex > 0):
                line += " " + comment
        if not (line.strip().startswith('chn_k') or line.strip().startswith('chn_S')):
            newText += line + "\n" # skip lines with chn_k
    q.setOrc(newText)

def toInvalue():
    changeToInvalue(q.getOrc())
    
def toChnget():
    changeToChnget(q.getOrc())

# GUI interface
w = pqt.QWidget() # Create main widget

w.setGeometry(50,50, 250,40)
l = pqt.QGridLayout(w) # Layout to organize widgets
w.setLayout(l)
w.setWindowTitle("Switch invalue->chnget")
w.setWindowFlags(w.windowFlags() |  pqtc.Qt.WindowStaysOnTopHint);

t = pqt.QLabel("Press the buttons to switch invalue/outvalue for chnget/chnset", w)

toChngetButton = pqt.QPushButton("Invalue -> Chnget",w)
toInvalueButton = pqt.QPushButton("Chnget -> Invalue",w)

l.addWidget(toChngetButton, 0, 0)
l.addWidget(toInvalueButton, 0, 1)
l.addWidget(t, 1, 0, 1, 2)

toInvalueButton.connect("clicked()", toInvalue)
toChngetButton.connect("clicked()", toChnget)

w.show()






<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
