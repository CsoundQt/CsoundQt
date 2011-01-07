# By Andres Cabrera 2011
# License: Same as QuteCsound
# This script simplifies the rendering of Marco Gasperini's
# realization of G. M. Koenig's Essay for Csound using
# QuteCsound's python scripting facilities
# You need a version of QuteCsound compiled with PythonQt support
# to run this. Check the About box for the text "Built with PythonQt support"
import PythonQt.QtGui as pqt
import PythonQt.QtCore as pqtc
import glob, os

running = 0
csdFiles = []
sectionBox = 0
partBox = 0
parts = ['A', 'B', 'C', 'D', 'E', 'F', 'G', "Complete"]
srBox = 0
renderDir = "Rendered" #Remember no slash at the end

def stop():
    global running
    print "Stopped."
    running = 0

def renderFile(csdFile):
    global srBox
    sr = srBox.currentText
    ret = os.system("csound " + csdFile + " -d -r" + sr + " -k" + sr )
    if ret != 0:
        print "File: " + csdFile + " returned: " + str(ret)
    return ret

def renderFiles():
    global running
    if not os.access(renderDir, os.F_OK):
        os.mkdir(renderDir)
    os.chdir(renderDir)
    counter = 0
    number = len(csdFiles)
    running = 1
    for csdFile in csdFiles:
        counter += 1
        #print "Rendering (" + str(counter) + "/" + str(number) + "):" + csdFile
        renderFile("../" + csdFile)
        pqtc.QCoreApplication.instance().processEvents() # Needed to avoid blocking the application
        if running == 0:
            break
    os.chdir("..") # Go back to original directory

def partChanged(index):
    global sectionBox, parts
    wavFiles = glob.glob(renderDir + "/*.wav") # Get list of csd files
    wavFiles.sort() # Sort the list alphabetically
    sectionBox.clear()
    initialIndex = len(renderDir) + 1
    initial = parts[index]
    if parts[index] == "Complete":
        initial = "X"
    for file in wavFiles:
        if file[9] == initial:
            sectionBox.addItem(file) # Fill ComboBox with file list
    

def edit():
    global sectionBox
    name = sectionBox.currentText
    if not os.access(name, os.F_OK):
        pqt.QMessageBox.warning(0, "Koenig-Essay", "Part has not been rendered!")
    else:
        ret = os.system("audacity " + name + "&")
        if ret != 0:
            print "Error opening audacity"

if q.getDocument("Koenig-Essay.py") == -1:
    pqt.QMessageBox.warning(0, "Koenig-Essay", "Please open this file in a tab and then run it.")
else:
    os.chdir(q.getFilePath())  # Move to the directory of this file (only works if the file is open in a tab)
    
    csdFiles = glob.glob("csds/*.csd") # Get list of csd files
    csdFiles.sort() # Sort the list alphabetically
    
    w = pqt.QWidget() # Create main widget
    w.setGeometry(50,50, 400,500)
    l = pqt.QGridLayout(w) # Layout to organize widgets
    w.setLayout(l)
    w.setWindowTitle("Koenig's Essay Renderer")
    
    partBox = pqt.QComboBox(w)
    srBox = pqt.QComboBox(w)
    srBox.addItem("44100")
    srBox.addItem("48000")
    srBox.addItem("96000")
    srBox.addItem("192000")
    sectionBox = pqt.QComboBox(w)
    renderButton = pqt.QPushButton("Render All",w)
    stopButton = pqt.QPushButton("Stop Render",w)
    editButton = pqt.QPushButton("Open in Audacity",w)
    text = pqt.QTextBrowser(w)
    l.addWidget(pqt.QLabel("Sample Rate"), 0, 0)
    l.addWidget(srBox, 0, 1)
    l.addWidget(renderButton, 1, 0)
    l.addWidget(stopButton, 1, 1)
    l.addWidget(pqt.QLabel("Select Part"), 2, 0)
    l.addWidget(partBox, 2, 1)
    l.addWidget(sectionBox, 3, 0)
    l.addWidget(editButton, 3, 1)
    l.addWidget(text, 4,0,1,2)
    stopButton.connect("clicked()", stop)
    renderButton.connect("clicked()", renderFiles)
    partBox.connect("currentIndexChanged(int)", partChanged)
    editButton.connect("clicked()", edit)
    
    f = open("readme.txt")
    text.setText(f.read())
    
    for part in parts:
        partBox.addItem(part)
    
    for file in csdFiles:
        sectionBox.addItem(file) # Fill ComboBox with file list
    
    #renderFiles(csdFiles)
    w.show() # Show main widget

