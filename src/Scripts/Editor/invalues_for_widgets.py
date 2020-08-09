import os
import sys

from xml.dom.minidom import parseString
import PythonQt.QtGui as pqt

# This script creates all the necessary lines to connect widgets to Csound code
# Just go to the file you want, select the widgets and run this script from the menu

widgets_text = q.getSelectedWidgetsText()
# parse xml widgets text for current tab
widgets = []

widgets = parseString(widgets_text)

# Find widget elements
widgetList = widgets.getElementsByTagName("bsbObject")

if len(widgetList) == 0:
    pqt.QMessageBox.information(0, "Script", "Please select widgets")

# Create empty set for used channel names. This avoids duplicates.
channel_list = set()

# Go through all the widget list and find the objectName tag which contains the channel
for widget in widgetList:
    ch = widget.getElementsByTagName("objectName")
    channel_list.add(" ".join(t.nodeValue for t in ch[0].childNodes if t.nodeType == t.TEXT_NODE))

# Remove empty channels
if "" in channel_list:
    channel_list.remove("")
out_text = ''

# Now make the text to be inserted
for channel in channel_list:
    print(channel)
    out_text += 'k%s invalue "%s"\n'%(channel, channel)

# and insert it
q.insertText(out_text)

    
