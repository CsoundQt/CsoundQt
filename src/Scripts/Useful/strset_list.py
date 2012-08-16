#transfers the selected soundfiles to strset numbers
#and inserts the text at the cursor position

# -*- coding: utf-8 -*-

from os import listdir
import PythonQt.QtGui as pqt

#functions

def file_sel():
    global files 
    files = pqt.QFileDialog.getOpenFileNames(w, "Select files for strset list")

def paths():
    datlis = []
    for dat in files:
        datlis.append(dat)
    datlis.sort()
    strset = startnum.value
    insert = ""
    for dat in datlis:
        insert = '%sstrset %d, \"%s\"\n' % (insert, strset, dat)
        strset = strset+1
    q.insertText(insert)

def names():
    datlis = []
    for dat in files:
        datlis.append(dat)
    datlis.sort()
    strset = startnum.value
    insert = ""
    for dat in datlis:
        name = dat.split('/')[-1]
        insert = '%sstrset %d, \"%s\"\n' % (insert, strset, name)
        strset = strset+1
    q.insertText(insert)


#info and render window
w = pqt.QWidget()
w.setGeometry(50,50, 400,400)
l = pqt.QGridLayout(w)
w.setLayout(l)
w.setWindowTitle("strset list generator")
text = pqt.QTextBrowser(w)

startnum = pqt.QSpinBox(w)
startnum.setRange(0, 999999)
startnum.setValue(1)
l.addWidget(startnum, 2, 0)

renderButton0 = pqt.QPushButton("Select Files",w)
l.addWidget(renderButton0, 3, 0)
renderButton0.connect("clicked()", file_sel)

renderButton1 = pqt.QPushButton("Paths!",w)
l.addWidget(renderButton1, 4, 0)
renderButton1.connect("clicked()", paths)

renderButton2 = pqt.QPushButton("Names!",w)
l.addWidget(renderButton2, 5, 0)
renderButton2.connect("clicked()", names)

l.addWidget(text, 1, 0)
info = """A strset list will be inserted at the cursor position.

1. Set the starting number of the strset list in the number box below.

2. Push the "Select Files" button you want to see in the strset list.

3. Push the "Paths" button to get a list with full paths.
Or push the "Names" button to get a list with just file names.

Joachim Heintz 2012"""
text.setText(info)

w.show()















