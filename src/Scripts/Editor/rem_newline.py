# removes newline markers in the selected section
# joachim heintz 2012

# -*- coding: utf-8 -*-

import PythonQt.QtGui as pqt
      
def remNewline():
    selection = q.getSelectedText()
    lines = selection.splitlines()
    selNew = ""
    for line in lines:
        selNew = "%s %s" % (selNew, line.rstrip('\n'))
    q.insertText(selNew.lstrip())
    

#info and render window
w = pqt.QWidget() 
w.setGeometry(200,50, 200,100)
l = pqt.QGridLayout(w) 
w.setLayout(l)
w.setWindowTitle("Remove Newlines")

renderButton = pqt.QPushButton("Remove!",w)
text = pqt.QTextBrowser(w)
l.addWidget(renderButton, 2, 0)
l.addWidget(text, 1, 0)
renderButton.connect("clicked()", remNewline)

info = """Removes all newlines in the selected text."""
text.setText(info)

w.show()












