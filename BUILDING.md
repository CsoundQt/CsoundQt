Build instructions for CsoundQt
===============================

-       [Getting the Sources](#sources)     
-       [Building](#building)        
-       [RtMidi support](#rtmidi)        
-       [Building with PythonQt support](#pythonqt)     
-       [Notes for OSX](#osx)
-       [Notes for Linux](#linux)
-       [Notes for Windows](#windows)


<a name="sources">

*Please help improving these instructions and report any issue to one of the developers or to https://github.com/CsoundQt/CsoundQt/issues. Thanks!*


Getting the sources <a name="sources">
--------

The source files for CsoundQt can be browsed and downloaded from Github:
[https://github.com/CsoundQt/CsoundQt](https://github.com/CsoundQt/CsoundQt)

You can also find source releases in the Files section of [SourceForge](http://sourceforge.net/projects/qutecsound/files/CsoundQt/).    


<a name="building"> 
   
Building 
-----

To build **CsoundQt**, you must have installed [**Csound**](csound.github.io) first. On OSX and Windows you can use the prebuilt installers, for Linux it is mostly preferable to build it yourself.  See <https://github.com/csound/csound/blob/develop/BUILD.md> for instructions.

To build **CsoundQt** you need [**Qt**](http://qt-project.org/) (version 4.8 or 5.0+). The [**libsndfile**](http://www.mega-nerd.com/libsndfile/) library will allow recording the realtime output of Csound to a file. From version 0.7 onwards, CsoundQt can be built with [PythonQt](http://pythonqt.sourceforge.net/) support. Global MIDI I/O and control of the CsoundQt widgets can also be enabled through the [RtMidi](http://www.music.mcgill.ca/~gary/rtmidi/) library.

The easiest way to build CsoundQt is to open its qcs.pro file in **QtCreator** and build it there. You can download and install Qt development kit (including QtCreator and all necessary libraries) from [QT page](http://www.qt.io/download-open-source/). It is recommended to use **Qt 5.3 or newer**, to be able to use CsoundQt's **Virtual Midi Keyboard**.

CsoundQt uses qmake to build, so you can build on the **command line** with:

	$ qmake qcs.pro
	$ make
	
On UNIX systems you can install CsoundQt system wide, including desktop file, icon and mimetypes for Csound files (from version 0.9.2 on) with the command

    $ sudo make install
     
The qmake project file will attempt to find the dependencies in standard locations. You can specify the locations manually and give additional options for building. Consult the qcs.pro file.

  
<a name="rtmidi">  

###Building with RtMidi

It is highly recommended to build with [RtMidi](http://www.music.mcgill.ca/~gary/rtmidi/) support, as it will in most cases make MIDI I/O more stable than relying on Csound's MIDI modules. With RtMidi support you can also associate widgets with MIDI controllers. RtMidi version 2.0.1 or greater is required. To enable it run qmake with this argument:

	$ qmake CONFIG+=rtmidi

The RtMidi library can be best put in the same base directory as the CsoundQt sources, where it will be found and used. It should not be necessary to build the RtMidi library to use it, although some users have reported that they have had to do that before building CsoundQt.

<a name="pythonqt">

###Building with PythonQt support 

You can build optional support for **PythonQt**:

	$ qmake CONFIG+=pythonqt

PythonQt support gives you many extended possibilities to interact with CsoundQt and running Csound instances from the python console, from scripts or from python code in your csound code. Read more in chapter [12C](http://floss.booktype.pro/csound/c-python-in-csoundqt/) in the [Csound FLOSS Manual](http://floss.booktype.pro/csound/).
 
The [PythonQt sources](http://sourceforge.net/projects/pythonqt/files/) should be put in the same base directory as the CsoundQt sources, where they will be found and used. You must build and install the PythonQt libraries before using them. CsoundQt currently requires PythonQt >= 2.0.1; to build against **Qt5**, it requires **PythonQt >= 3.0**

To build PythonQt you need to edit first file *build/python.prf* in the PythonQt source directory (in QtCreator project tree  *src->python->python.prf*). Change it to the python version you have, for instance:

    unix:PYTHON_VERSION=2.7
  
In QtCreator **disable _"Shadow Build"_** in *Projects > Build Settings > General.* and build. When building on command line:

    $ qmake PythonQt.pro
    $ make

For making the libraries available, see platform specific notes below.

<a name="osx">

Notes for OSX build (see also [here](https://github.com/CsoundQt/CsoundQt/wiki/Building-CsoundQt-for-OSX-with-QtCreator))
---------------------

The paths in *qcs-macx.pro* are set up for using **Csound from the OSX installer** (not Homebrew).

If you use Csound from the OSX installer and *libcsnd6* is not found, you need to create a link in floder */usr/local/lib* pointing to the existing csnd6 library,  i.e: 

    $ cd /usr/local/lib
    $ sudo ln libcsnd6.6.0.dylib libcsnd6.dylib


If PythonQt build was successful, copy or link all *dylibs* from the *lib* folder in your build directory to */usr/local/lib*, for instance: 

    $ cd /Users/fmsbw/src/PythonQt3.0/lib
    $ sudo cp libPythonQt* /usr/local/lib/

When you start CsoundQt first time and  if the menu is without the **Scripts** item, set the *Python Script directory* in *Configure > Environment* to the *src/Scripts* dir of your CsoundQt sources. Close CsoundQt, and reopen.

_NB! There is a bug in Qt 5.5 that does not allow to resize floating panel on OSX (i.e Widgets panel). As a workaround you can check **Configuration->Widgets->Widgets are an independent window**  or use Qt 5.4._ 

<a name="linux">

Notes for Linux Builds 
----------------------

It is recommended to use the qt version installed mostly already in your system (i.e not to install it to some local folder from Qt site).

You need to have qt development libraries (usually with ending `-dev` or `-devel` for building CsoundQt. Install them using your system pacakge manager or software manager, for example:

    $ sudo apt-get install qt5-qmake
    $ sudo apt-get install qt5-default
 
    
You may need to install also other qt5 libraries. (In case you get an error message like "Unknown module(s) in QT: ...", go to your package manager and install libqt5...) 

Instead of command `qmake` you might need to use `qmake-qt4` or `qmake-qt5` depending on the system and qt version. It is recommended to use qt5.


Instead of copying or linking PythonQt libraries to /usr/local/lib you can add the path of your build to system wide libraries search path:

    $ cd /etc/ld.so.conf.d/ 
    $ sudo nano # (or use gedit) 

Then simply type or copy the path of your PythonQt/lib folder, e.g. 
    
    /home/jh/src/PythonQt3.0/lib/ 
    
and save the file as *pythonqt.conf*. Then run: 

    $ sudo /sbin/ldconfig


<a name="windows">

Notes for Windows Builds 
----------------

To be added.



