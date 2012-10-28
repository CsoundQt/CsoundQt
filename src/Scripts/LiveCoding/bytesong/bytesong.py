
# First make sure you execute these lines first to have the 'bytesong'
#function available
import sys,os
import PythonQt.QtGui as pqt

sys.path.append(os.getcwd()) # trick to allow importing python files from the current directory

def bytesong(PAT):
    stopsong()
    q.loadDocument('bytesong.csd')
    options = '-m0 -odac --omacro:PAT=' + PAT
    q.setOptionsText(options)
    q.stop()
    q.play()
    index = q.getDocument('bytesongs.py')
    q.setDocument(index) # GO back to this document


def stopsong():
    index = q.getDocument('bytesong.csd')
    q.stop(index)

q.loadDocument('bytesongs.py')
q.setDocument(q.getDocument('bytesongs.py'))

pqt.QMessageBox.information(0, 'OK', 'Bytesong functions loaded.\n Now execute the bytesong lines.')

1/0 # To force stopping here!
