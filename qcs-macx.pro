
!macx: error(This project file is only for Macintosh OS X systems.)
!no_messages {
	message()
	message(Building CsoundQt for Macintosh OS X.)
}

!ppc: !x86_64:  {
CONFIG += i386
QMAKE_CXXFLAGS += -arch i386
}
universal: {
QMAKE_CXXFLAGS += -arch i386
CONFIG += i386
CONFIG += ppc
}

build32: MAC_LIB = CsoundLib
build64: MAC_LIB = CsoundLib64

HOME_DIRECTORY = /Users/admin

# Set default paths
CSOUND_FRAMEWORK_DIR = /Library/Frameworks/$${MAC_LIB}.framework/Versions/Current
DEFAULT_CSOUND_API_INCLUDE_DIRS =  $${HOME_DIRECTORY}/$${CSOUND_FRAMEWORK_DIR}/Headers \
        $${CSOUND_FRAMEWORK_DIR}/Headers \
        /usr/local/include/csound
DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS = $${DEFAULT_CSOUND_API_INCLUDE_DIRS}
DEFAULT_CSOUND_LIBRARY_DIRS = $${HOME_DIRECTORY}/$${CSOUND_FRAMEWORK_DIR} \
        $${CSOUND_FRAMEWORK_DIR} \
        /usr/local/lib
build32:DEFAULT_CSOUND_LIBS = CsoundLib
build64:DEFAULT_CSOUND_LIBS = CsoundLib64

# For OS X, the PythonQt.1.0.0.dylib and the libPythonQt.1.dylib must be on /usr/local/lib or other lib path
DEFAULT_PYTHON_INCLUDE_DIR = /usr/local/include \
        /usr/include
DEFAULT_PYTHONQT_LIBRARY_DIRS = /usr/local/lib \
        /usr/lib
DEFAULT_PYTHONQT_SRC_DIRS = ../../../PythonQt2.0.1 \
        ../PythonQt2.0.1 \
        PythonQt2.0.1
#PYTHONQT_LIB = PythonQt_QtAll$${DEBUG_EXT}
PYTHONQT_LIB = PythonQt
# Do configuration step
include(config.pri)

# Use results from config step
LIBS *= -L$${CSOUND_LIBRARY_DIR}
rtmidi {
DEFINES += __MACOSX_CORE__
LIBS += -framework CoreFoundation
LIBS += -framework CoreMidi -framework CoreAudio
}
quteapp_f {
message(Bundling QuteApp_f)
RESOURCES += "src/quteapp_f_osx.qrc"
}
quteapp_d {
message(Bundling QuteApp_d)
RESOURCES += "src/quteapp_d_osx.qrc"
}
#LIBS += -framework QtCore -framework QtGui -framework QtXml
LCSOUND = -F$${HOME_DIRECTORY}/Library/Frameworks -F/Library/Frameworks -framework $${MAC_LIB}
csound6: LCSND = -L/usr/local/lib -lcsnd6
else: LCSND = -l_csnd

QMAKE_INFO_PLIST = $${PWD}/src/MyInfo.plist
ICON = $${PWD}/images/qtcs.icns
