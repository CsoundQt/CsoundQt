# Demonstarion of Qt integration with csound over CsoundQt python API

# read cuurent RGB values from Qt color dialog as control values for sound 
# csound code in "rgb-widgets.csd" must be in the same directory as the python script
# Tarmo Johannes tarmo@otsakool.edu.ee

from PythonQt.Qt import *

def getColors(currentColor): # write the current RGB values as floats 0..1 to according channels of "rgb-widgets.csd"
    q.setChannelValue("red",currentColor.redF(),csd) 
    q.setChannelValue("green",currentColor.greenF(),csd)
    q.setChannelValue("blue",currentColor.blueF(),csd)

# main-----------
cdia = QColorDialog() #create QColorDiaog object
csd=q.loadDocument("rgb-widgets.csd") # get the index of csd. Returns the index if already open. 
if ( csd == -1): # report error, if opening failed
    print "Could not find rgb-widgets.csd. Exiting"
    exit(-1)
q.setDocument(csd)# set focus to the csd
cdia.connect(SIGNAL("currentColorChanged(QColor)"),getColors) # create connection between  color changes in the dialog window and function getColors
cdia.show() # show the dialog window,
q.play(csd) # and play the csd




