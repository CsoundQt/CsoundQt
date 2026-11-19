
!macx: error(This project file is only for Macintosh OS X systems.)
!no_messages {
    message(" ")
	message(Building CsoundQt for Macintosh OS X.)
}


#CONFIG += x86_64
#QMAKE_CXXFLAGS += -arch x86_64

# QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64
QMAKE_APPLE_DEVICE_ARCHS = arm64

build32: MAC_LIB = CsoundLib
build64: MAC_LIB = CsoundLib64

#paths set up for using the csound from installed package
HOME_DIRECTORY =


# Set default paths. Put homebrew paths at the end
#Csound 7:
CSOUND_FRAMEWORK_DIR = /Applications/Csound/CsoundLib64.framework/Versions/Current
DEFAULT_CSOUND_API_INCLUDE_DIRS =  $${CSOUND_FRAMEWORK_DIR}/Headers \
        /$${CSOUND_FRAMEWORK_DIR}/Headers \
        $${CSOUND_FRAMEWORK_DIR}/Headers \
        $$(HOME)/Library/Frameworks/CsoundLib64.framework/Versions/Current/Headers \
        /usr/local/include/csound \
        /usr/local/opt/csound/Frameworks/CsoundLib64.framework/Headers \
        /opt/homebrew/opt/csound/Frameworks/CsoundLib64.framework/Versions/7.0/Headers \
        
        
DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS = $${DEFAULT_CSOUND_API_INCLUDE_DIRS}
DEFAULT_CSOUND_LIBRARY_DIRS = $${HOME_DIRECTORY}/$${CSOUND_FRAMEWORK_DIR} \
        /$${CSOUND_FRAMEWORK_DIR} \
        $$(HOME)/Library/Frameworks/CsoundLib64.framework/Versions/Current \
        /usr/local/lib \
        /usr/local/opt/csound/Frameworks/CsoundLib64.framework/Versions/Current \
        /opt/homebrew/opt/csound/Frameworks/CsoundLib64.framework/Versions/7.0

build32:DEFAULT_CSOUND_LIBS = CsoundLib
build64:DEFAULT_CSOUND_LIBS = CsoundLib64

# Do configuration step
include(config.pri)

# Use results from config step

LIBS *= -L$${CSOUND_LIBRARY_DIR}


exists ($${HOME_DIRECTORY}/Library/Frameworks/CsoundLib64.framework/CsoundLib64) {
	LIBS *= -L$${HOME_DIRECTORY}/Library/Frameworks/CsoundLib64.framework/CsoundLib64
}

rtmidi {
	DEFINES += __MACOSX_CORE__
	LIBS += -framework CoreFoundation
	LIBS += -framework CoreMidi -framework CoreAudio
}

# Link against the Csound library detected by config.pri.
# If CSOUND_LIBRARY_DIR points inside a .framework (e.g.
# ~/Library/Frameworks/CsoundLib64.framework/Versions/Current), link it as a
# framework; otherwise link a plain dylib (e.g. /usr/local/lib/libCsoundLib64).
# (dirname() takes a variable name, so this needs intermediate variables.)
_dir1 = $$dirname(CSOUND_LIBRARY_DIR)
_dir2 = $$dirname(_dir1)
CSOUND_FRAMEWORK_ROOT = $$dirname(_dir2)
exists($${CSOUND_FRAMEWORK_ROOT}/$${MAC_LIB}.framework) {
    LCSOUND = -F$${CSOUND_FRAMEWORK_ROOT} -framework $${MAC_LIB}
    # The framework's install name is @rpath/$${MAC_LIB}.framework/Versions/...,
    # so an un-bundled build (`make` without `make install`) needs an rpath
    # pointing at the framework root used at link time. Without it, running
    # bin/CsoundQt-d-cs7.app fails with "Library not loaded: @rpath/..."
    # unless Csound happens to live in one of the app's other rpath dirs.
    QMAKE_RPATHDIR *= $${CSOUND_FRAMEWORK_ROOT}
} else {
    LCSOUND = -L$${CSOUND_LIBRARY_DIR} -l$${MAC_LIB}
    QMAKE_RPATHDIR *= $${CSOUND_LIBRARY_DIR}
}


QMAKE_INFO_PLIST = $${PWD}/../src/MyInfo.plist
ICON = $${PWD}/../images/csoundqt.icns
