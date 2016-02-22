*Please help improving these instructions and report any issue to one of the developers or to https://github.com/CsoundQt/CsoundQt/issues. Thanks!*

## LINUX

## OSX

We describe here building with QtCreator, which is most easy. You can also use the commandline tools (see the nightly_build.py script as an example).

### Basic Version
1.   Download and install the latest QtCreator from http://www.qt.io/download.
2.   In QtCreator, choose New Project > Import Project > Git Clone. Insert https://github.com/CsoundQt/CsoundQt.git as Repository.
3.   Install Csound from the latest OSX installer (see http://csound.github.io/download.html). If you use your own build, you will have to adjust the paths in qcs-macx.pro.
4.   Open the Terminal and execute this line:  
  `sudo ln /usr/local/lib/libcsnd6.6.0.dylib /usr/local/lib/libcsnd6.dylib`  
5.   In QtCreator, disable "Shadow Build" in Projects > Build Settings > General.
6.   Select Build > Build Project. You should now build a basic version of CsoundQt which can be executed after building.
### With RtMidi
7.   Download the latest version of RtMidi at http://www.music.mcgill.ca/~gary/rtmidi in the same folder as your CsoundQt sources folder is.
8.   According to your version of RtMidi you might need to change the relevant line in "config.pri" , for instance:  
  `DEFAULT_RTMIDI_DIRNAME="rtmidi-2.1.1"`
9.   Now uncomment the line  
  `CONFIG+=rtmidi`  
in qcs.pro and build again. You should now get a working version of CsoundQt with RtMidi support (to check, go to Configure > Realtime MIDI, and see if you can select one of the input devices you have connected).
### With PythonQt
10.  jkl 

## WINDOWS
