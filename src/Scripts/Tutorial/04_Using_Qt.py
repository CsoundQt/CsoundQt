# 04_Using_Qt.py

import PythonQt.QtGui as pqt

pqt.QMessageBox.information(0, 'Python',
	'You have access to all of the Qt toolkit from the API!')

w = pqt.QWidget() # Create main widget
w.setGeometry(50,50, 250,400)
text = pqt.QTextBrowser(w) # and text output display
text.setOpenExternalLinks(True)
text.show()
text.setHtml('<h1>Welcome to the Python API!</h1>Although CsoundQt does not use PySide, most of the <a href="http://qt-project.org/wiki/PySide">PySide Docs</a> will apply!<br>You can use Qt to build interactive interfaces for CsoundQt scripts.')

but = pqt.QPushButton("Button", w)
but.move(5, 220) # This works but always try to use layouts instead!
sli = pqt.QSlider(w)
sli.move(100, 220)

w.show()
