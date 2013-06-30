#!/usr/bin/python
# -*- coding: utf-8 -*-

# opens QtDesigner to creae a UI, converts it to python code, makes necessary changes to the code to be ready to use in CsoundQt
# you need to have QtDesigner (part of Qt devel tools) ann pyuic4 (part of python-qt4-devel or similar) to use this srcipy

# by Tarmo Johannes, tarmo@otsakool.edu.ee 2013

import string,os
from subprocess import call


designerCommand = "designer"
pyuic4Command = "pyuic4"


def makeReplacements(pyQt4File, addPyrun = False):
    pycode = ""
    pyfile=open(pyQt4File,"r")
    for line in pyfile.readlines():
	if ( string.find(line,"import sys")==-1 and  string.find(line,"sys.argv")==-1  and string.find(line,"sys.exit")==-1 and string.find(line,"QtCore.QMetaObject")==-1): # leave out unwanted lines
		if ( string.find(line,"def setupUi(self, ")!=-1 ): # find out the name of the main widget
			mainWidget = line[string.find(line,'self,')+6 :string.find(line,')')] # hopefully gets the name from line like 'def setupUi(self, TabWidget):'
		if (string.find(line,"QtCore.QObject.connect") != -1):
			line = string.replace(line, mainWidget+'.','self.')
		pycode += line
      
    pycode = string.replace(pycode,"from PyQt4","from PythonQt")
    #print pycode
    pyfile.close()
    if (addPyrun):
		pycode = "pyinit\npyruni {{\n\n" + pycode + "\n}}"
    return pycode

#--- uus

# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file '/home/tarmo/tarmo/csound/scripts/qtd_import.ui'
#
# Created by: PyQt4 UI code generator 4.9.6
#
# WARNING! All changes made in this file will be lost!

from PythonQt import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_Dialog(object):
    def setupUi(self, Dialog):
        Dialog.setObjectName(_fromUtf8("Create UI with QtDesigner"))
        Dialog.setMinimumSize(QtCore.QSize(300, 200))
        self.frame = QtGui.QFrame(Dialog)
        self.frame.setGeometry(QtCore.QRect(4, 4, 268, 63))
        self.frame.setObjectName(_fromUtf8("frame"))
        self.keepPyBox = QtGui.QCheckBox(Dialog)
        self.keepPyBox.setGeometry(QtCore.QRect(166, 98, 117, 21))
        self.keepPyBox.setObjectName(_fromUtf8("keepPyBox"))
        self.addPyrunBox = QtGui.QCheckBox(Dialog)
        self.addPyrunBox.setGeometry(QtCore.QRect(21, 98, 141, 21))
        self.addPyrunBox.setObjectName(_fromUtf8("addPyrunBox"))
        self.convertButton = QtGui.QCommandLinkButton(Dialog)
        self.convertButton.setGeometry(QtCore.QRect(70, 130, 168, 41))
        self.convertButton.setObjectName(_fromUtf8("convertButton"))
        self.line = QtGui.QFrame(Dialog)
        self.line.setGeometry(QtCore.QRect(21, 80, 262, 16))
        self.line.setFrameShape(QtGui.QFrame.HLine)
        self.line.setFrameShadow(QtGui.QFrame.Sunken)
        self.line.setObjectName(_fromUtf8("line"))
        self.layoutWidget = QtGui.QWidget(Dialog)
        self.layoutWidget.setGeometry(QtCore.QRect(20, 20, 260, 53))
        self.layoutWidget.setObjectName(_fromUtf8("layoutWidget"))
        self.gridLayout = QtGui.QGridLayout(self.layoutWidget)
        self.gridLayout.setMargin(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.label = QtGui.QLabel(self.layoutWidget)
        self.label.setObjectName(_fromUtf8("label"))
        self.gridLayout.addWidget(self.label, 0, 0, 1, 1)
        self.uiNameEdit = QtGui.QLineEdit(self.layoutWidget)
        self.uiNameEdit.setObjectName(_fromUtf8("uiNameEdit"))
        self.gridLayout.addWidget(self.uiNameEdit, 0, 1, 1, 3)
        self.newButton = QtGui.QPushButton(self.layoutWidget)
        icon = QtGui.QIcon.fromTheme(_fromUtf8("document-new"))
        self.newButton.setIcon(icon)
        self.newButton.setObjectName(_fromUtf8("newButton"))
        self.gridLayout.addWidget(self.newButton, 1, 0, 1, 2)
        self.openButton = QtGui.QPushButton(self.layoutWidget)
        icon = QtGui.QIcon.fromTheme(_fromUtf8("document-open"))
        self.openButton.setIcon(icon)
        self.openButton.setObjectName(_fromUtf8("openButton"))
        self.gridLayout.addWidget(self.openButton, 1, 2, 1, 1)
        self.designButton = QtGui.QPushButton(self.layoutWidget)
        self.designButton.setToolTip(_fromUtf8(""))
        self.designButton.setWhatsThis(_fromUtf8(""))
        icon = QtGui.QIcon.fromTheme(_fromUtf8("applications-engineering"))
        self.designButton.setIcon(icon)
        self.designButton.setObjectName(_fromUtf8("designButton"))
        self.gridLayout.addWidget(self.designButton, 1, 3, 1, 1)
        self.layoutWidget1 = QtGui.QWidget(Dialog)
        self.layoutWidget1.setGeometry(QtCore.QRect(0, 0, 2, 2))
        self.layoutWidget1.setObjectName(_fromUtf8("layoutWidget1"))
        self.verticalLayout = QtGui.QVBoxLayout(self.layoutWidget1)
        self.verticalLayout.setMargin(0)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.splitter = QtGui.QSplitter(Dialog)
        self.splitter.setGeometry(QtCore.QRect(0, 0, 0, 0))
        self.splitter.setOrientation(QtCore.Qt.Horizontal)
        self.splitter.setObjectName(_fromUtf8("splitter"))

        self.retranslateUi(Dialog)
        QtCore.QObject.connect(self.designButton, QtCore.SIGNAL(_fromUtf8("clicked()")), self.runDesigner)
        QtCore.QObject.connect(self.convertButton, QtCore.SIGNAL(_fromUtf8("clicked()")), self.convert)
        QtCore.QObject.connect(self.openButton, QtCore.SIGNAL(_fromUtf8("clicked()")), self.openDialog)
        QtCore.QObject.connect(self.newButton, QtCore.SIGNAL(_fromUtf8("clicked()")), self.newDialog)

    def runDesigner(self):
		uiFile = "\""+self.uiNameEdit.text+"\""
    		if (len(uiFile)<3):
    			self.newDialog()
    		os.system("designer "+uiFile + "&")
    
    def openDialog(self):
        #fd = QtGui.QFileDialog()
        fileName = QtGui.QFileDialog.getOpenFileName()
        self.uiNameEdit.setText(fileName)    
    
    def newDialog(self):
        fileName = QtGui.QFileDialog.getSaveFileName(0,"New UI","*.ui")
        self.uiNameEdit.setText(fileName)
        
    def convert(self):
		uiFile = self.uiNameEdit.text 
		if (len(uiFile)<3): #nothing inserted
    			QtGui.QMessageBox.critical(0,"Error","ui file name is not inserted! I don't know, what to handle. Sorry.")
    			return
    			
		self.insertMessageBox=QtGui.QMessageBox(QtGui.QMessageBox.Information, "Insert", "Place cursor where you would like the code to be pasted")
		self.insertMessageBox.setStandardButtons(QtGui.QMessageBox.Ok | QtGui.QMessageBox.Cancel)
		self.insertMessageBox.setModal(False) # don't block
		QtCore.QObject.connect( self.insertMessageBox.button(self.insertMessageBox.Ok), QtCore.SIGNAL("clicked()"), self.insertText)
		self.insertMessageBox.setWindowFlags(self.insertMessageBox.windowFlags() | QtCore.Qt.WindowStaysOnTopHint) # on top until a buttin is pressed	
		self.insertMessageBox.show()
		
    
    def insertText(self):
		#uiFile = "\'"+self.uiNameEdit.text+"\'" 
		uiFile = self.uiNameEdit.text
		tmpPyfile = string.replace(uiFile,".ui","_tmp.py")
		
		cmd = pyuic4Command + " " + uiFile + " -x -o " + tmpPyfile #?? kui tühikud?
		print cmd
		ret = call([pyuic4Command,uiFile,"-x","-o",tmpPyfile])	# parem popen
		print ret
		
		if (ret == 0):
    			pythonQtCode = makeReplacements(tmpPyfile,self.addPyrunBox.checkState()) #, ui.addPyrunBox.checkState())
			q.insertText(pythonQtCode)
			if (ui.keepPyBox.checkState()== False):
    				os.remove(tmpPyfile)
    		else:
        		QtGui.QMessageBox.critical(0,"Error","Could not execute " + pyuic4Command +" with ui file" + uiFile)
    
    def retranslateUi(self, Dialog):
        Dialog.setWindowTitle(_translate("Dialog", "Create UI with QtDesigner", None))
        self.keepPyBox.setText(_translate("Dialog", "Keep PyQt4 file", None))
        self.addPyrunBox.setText(_translate("Dialog", "Add pyrun {{ ... }}", None))
        self.convertButton.setText(_translate("Dialog", "Convert and insert", None))
        self.label.setText(_translate("Dialog", "UI file:", None))
        self.newButton.setText(_translate("Dialog", "New", None))
        self.openButton.setText(_translate("Dialog", "Select", None))
        self.designButton.setText(_translate("Dialog", "Design", None))
	




if __name__ == "__main__":
    Dialog = QtGui.QDialog()
    ui = Ui_Dialog()
    ui.setupUi(Dialog)
    Dialog.show()



    
    
 
