*Please help improving these instructions and report any issue to one of the developers or to https://github.com/CsoundQt/CsoundQt/issues. Thanks!*

## LINUX

## OSX

We describe here building with QtCreator, which is most easy. You can also use the commandline tools (see the nightly_build.py script as an example).

#### Basic Version
*   Download and install the latest QtCreator from http://www.qt.io/download.
*   In QtCreator, choose New Project > Import Project > Git Clone. Insert https://github.com/CsoundQt/CsoundQt.git as Repository.
*   Install Csound from the latest OSX installer (see http://csound.github.io/download.html). If you use your own build, you will have to adjust the paths in qcs-macx.pro.
*   Open the Terminal and execute this line:  
  `sudo ln /usr/local/lib/libcsnd6.6.0.dylib /usr/local/lib/libcsnd6.dylib`  
*   In QtCreator, disable "Shadow Build" in Projects > Build Settings > General.
*   Select Build > Build Project. You should now build a basic version of CsoundQt which can be executed after building.

#### With RtMidi
*   Download the latest version of RtMidi at http://www.music.mcgill.ca/~gary/rtmidi in the same folder as your CsoundQt sources folder is.
*   According to your version of RtMidi you might need to change the relevant line in "config.pri" , for instance:  
  `DEFAULT_RTMIDI_DIRNAME="rtmidi-2.1.1"`
*   Now uncomment the line  
  `CONFIG+=rtmidi`  
in qcs.pro and build again. You should now get a working version of CsoundQt with RtMidi support (to check, go to Configure > Realtime MIDI, and see if you can select one of the input devices you have connected).

#### With PythonQt
*  Download the latest version of PythonQt from https://sourceforge.net/projects/pythonqt/files/pythonqt and unpack it to the same folder where already your CsoundQt and RtMidi source folders are.
*  Build the PythonQt.pro project in QtCreator.
*  After success, look whether in your CsoundQt project src>python>python.prf matches the Python version on your computer. If not, change it, for instance:
  `unix:PYTHON_VERSION=2.7`  
*  Copy all dylibs from the lib folder in your PythonQt build directory to /usr/local/lib, for instance:
  `cd /Users/fmsbw/src/PythonQt3.0/lib` 
  `sudo cp libPythonQt* /usr/local/lib/`  
*  Now uncomment the line  
  `CONFIG+=pythonqt`  
in qcs.pro and build again. You should now get a working version of CsoundQt with PythonQt support (to check, see if the Python Scratchpad is there when you launch CsoundQt).
*  If the CsoundQt menu is without the Scripts item, set the Python Script directory in Configure > Environment to the src/Scripts dir of your CsoundQt sources. Close CsoundQt, and once you relaunch CsoundQt the Python scripts should be there.

## WINDOWS
