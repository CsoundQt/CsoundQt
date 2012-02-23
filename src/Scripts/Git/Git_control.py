# By Andres Cabrera 2012

import PythonQt.QtGui as pqt
import PythonQt.QtCore as pqtc
import glob, os
from subprocess import call
import errno

git_bin = 'git'
git_dir = ''


w = pqt.QWidget() # Create main widget
text = pqt.QTextBrowser(w) # and text output display

def commit():
    os.chdir(q.getFilePath())
    comment = pqt.QInputDialog.getText(0, "Comment",
                                          "Enter comment", pqt.QLineEdit.Normal,
                                          "")
    if comment != '':
        full_out = ''
        f = file('git-log.txt', 'w')
        ret_text = call(["git", "add", q.getFileName()], stderr=f, stdout = f)
        f.close()
        f = file('git-log.txt', 'r')
        o = f.readlines()
        for line in o:
            full_out += line
        f = file('git-log.txt', 'w')
        ret_text = call(["git", "commit", '-m ' + comment], stderr=f, stdout = f)
        f.close()
        f = file('git-log.txt', 'r')
        o = f.readlines()
        for line in o:
            full_out += line
        text.setPlainText(full_out);
    
def initialize():
    os.chdir(q.getFilePath())
    f = file('git-log.txt', 'w')
    call(["git", "init"], stderr=f, stdout = f)
    f.close()
    f = file('git-log.txt', 'r')
    o = f.readlines()
    full_out = ''
    for line in o:
        full_out += line
    text.setPlainText(full_out);

def diff():
    os.chdir(q.getFilePath())
    f = file('git-log.txt', 'w')
    try:
        ret_text = call(["git", "diff"], stderr=f, stdout = f)
    except OSError, ose:
        if ose.errno != errno.EINTR:
          raise ose
    f.close()
    f = file('git-log.txt', 'r')
    o = f.readlines()
    full_out = ''
    for line in o:
        full_out += line
    print full_out
    text.setPlainText(full_out);

def gitk():
    os.chdir(q.getFilePath())
    f = file('git-log.txt', 'w')
    ret_text = call(["gitk"], stderr=f, stdout = f)
    f.close()
    f = file('git-log.txt', 'r')
    o = f.readlines()
    full_out = ''
    for line in o:
        full_out += line
    #text.setPlainText(full_out);

w.setGeometry(50,50, 250,200)
l = pqt.QGridLayout(w) # Layout to organize widgets
w.setLayout(l)
w.setWindowTitle("Git control")
w.setWindowFlags(w.windowFlags() |  pqtc.Qt.WindowStaysOnTopHint);

commitButton = pqt.QPushButton("Commit",w)
diffButton = pqt.QPushButton("Diff",w)
initializeButton = pqt.QPushButton("Initialize Git",w)
gitkButton = pqt.QPushButton("gitk",w)

l.addWidget(commitButton, 0, 0)
l.addWidget(diffButton, 0, 1)
l.addWidget(initializeButton, 0, 2)
l.addWidget(gitkButton, 0, 3)
l.addWidget(text, 1, 0, 1, 4)

commitButton.connect("clicked()", commit)
initializeButton.connect("clicked()", initialize)
diffButton.connect("clicked()", diff)
gitkButton.connect("clicked()", gitk)

w.show() # Show main widget



