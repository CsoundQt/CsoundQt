import PythonQt.QtGui as pqt
import PythonQt.QtCore as pqtc
import os
import sys

from time import sleep
from xml.dom.minidom import parseString

sys.path.append(os.getcwd()) # trick to allow importing python files from the current directory
try:
    import OSC
except:
    pqt.QMessageBox.critical(0, "Error", "Could not load OSC.py")

d = q.loadDocument("GoOSC.csd")

widgets = parseString(q.getSelectedWidgetsText())
widgetList = widgets.getElementsByTagName("bsbObject")

def getText(nodelist):
    rc = []
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)


address = pqt.QInputDialog.getText(0, "IP Address",
                 	                         'IP address', pqt.QLineEdit.Normal,
                        	                  '192.168.0.5:9001')
send_address = (address[:address.index(':')],  int(address[address.index(':')+1:]))

scale = 2

goosc_widgets = []
channel_list = []
offset_x = 15
offset_y = 15

min_x = 9999
min_y = 9999
for widget in widgetList:
    x = int(getText(widget.getElementsByTagName("x")[0].childNodes)) * scale
    y = int(getText(widget.getElementsByTagName("y")[0].childNodes)) * scale
    if (x < min_x): min_x = x
    if (y < min_y): min_y = y

offset_x -= min_x
offset_y -= min_y

for widget in widgetList:
    widget_text = ''
    widget_type = widget.getAttribute('type')
    if (widget_type == 'BSBVSlider' or widget_type == 'BSBHSlider' ):
        widget_text += "OSCSlider {"
        widget_text += "min: " + getText(widget.getElementsByTagName("minimum")[0].childNodes) + ";"
        widget_text += "max: " + getText(widget.getElementsByTagName("maximum")[0].childNodes) + ";"
    elif (widget_type == 'BSBButton'  ):
        widget_text += "OSCButton {"
        widget_text += "max: " + getText(widget.getElementsByTagName("pressedValue")[0].childNodes) + ";"
    else:
        continue
    x = offset_x + int(getText(widget.getElementsByTagName("x")[0].childNodes)) * scale
    y = offset_y + int(getText(widget.getElementsByTagName("y")[0].childNodes)) * scale
    width = int(getText(widget.getElementsByTagName("width")[0].childNodes)) * scale
    height = int(getText(widget.getElementsByTagName("height")[0].childNodes)) * scale
    widget_text += "x:" + str(x)  + ";"
    widget_text += "y:" + str(y) + ";"
    widget_text += "width:" + str(width) + ";"
    widget_text += "height:" + str(height) + ";"
    channel = getText(widget.getElementsByTagName("objectName")[0].childNodes)
    if channel != '':
        widget_text += 'channel:"/' + channel  + '" ;'
        if (channel_list.count(channel) == 0):
            channel_list.append(channel)
    widget_text += "}"
    print widget_text
    
    goosc_widgets.append(widget_text)
    
   
# OSC basic client
c = OSC.OSCClient()
c.connect( send_address ) # set the address for all following messages

basepath = "/goosc"
for widget_text in goosc_widgets:
    msg = OSC.OSCMessage()
    msg.setAddress(basepath + "/create") # set OSC address
    msg.append(widget_text)
    c.send(msg)

#def osc_callback(path, tags, args, source):
#    # which user will be determined by path:
#    # we just throw away all slashes and join together what's left
#    user = ''.join(path.split("/"))
#    # tags will contain 'fff'
#    # args is a OSCMessage with data
#    # source is where the message came from (in case you need to reply)
#    print ("Now do something with", user,args[2],args[0],1-args[1]) 
#
#def quit_callback(path, tags, args, source):
#    global run
#    run = False
#
#server = OSC.OSCServer(('192.168.0.2', 9002))
#
#for chan in channel_list:
#    server.addMsgHandler( "/" + channel, osc_callback ) 
# 
#
#server.timeout = 0
#run = True
#
## Must leave some way for the server to quit!
#button = pqt.QPushButton("Stop")
#button.setCheckable(True)
#button.show()
#
#while run:
#    pqtc.QCoreApplication.instance().processEvents() # Needed to avoid blocking the application
#    if button.isChecked():
#        run = False
#    sleep(1)
#
#server.close()
#
#del run
#del button
#del server
#del c

sys.path.remove(os.getcwd()) # remove this path!
print "finished OK."





