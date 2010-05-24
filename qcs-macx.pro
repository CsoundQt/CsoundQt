
!macx: error(This project file is only for Macintosh OS X systems.)
!no_messages {
    message()
    message(Building QuteCsound for Macintosh OS X.)
}
!build32: !build64: CONFIG += build32
build32: build64: CONFIG -= build32
# DEFINES += MACOSX_PRE_SNOW # Use this if you are building for OS X < 10.6
# QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.5
# QMAKE_MAC_SDK=/Developer/SDKs/MacOSX10.5.sdk
CONFIG *= x86 # for precompiled Csound on Snow Leopard
build32: MAC_LIB = CsoundLib
build64: MAC_LIB = CsoundLib64
CSOUND_FRAMEWORK_DIR = /Library/Frameworks/$${MAC_LIB}.framework/Versions/Current
DEFAULT_CSOUND_INCLUDE_DIRS = $${CSOUND_FRAMEWORK_DIR}/Headers \
    ~/$${CSOUND_FRAMEWORK_DIR}/Headers
DEFAULT_CSOUND_LIBRARY_DIRS = $${CSOUND_FRAMEWORK_DIR} \
    ~/$${CSOUND_FRAMEWORK_DIR}
DEFAULT_LIBSNDFILE_INCLUDE_DIRS = /usr/local/include \
    /usr/include
DEFAULT_LIBSNDFILE_LIBRARY_DIRS = /usr/local/lib \
    /usr/lib
DEFAULT_CSOUND_LIBS = CsoundLib
CSND_LIB = lib_csnd.dylib
LIBSNDFILE_LIB = libsndfile.dylib
include(config.pri)
INCLUDEPATH += $${CSOUND_INCLUDE_DIR} $${LIBSNDFILE_INCLUDE_DIR}
LIBS += -L$${CSOUND_LIBRARY_DIR} -L$${LIBSNDFILE_LIBRARY_DIR}
LIBS += -framework QtCore -framework QtGui -framework QtXml
LCSOUND = -framework $${MAC_LIB}
LCSND = -l_csnd
LSNDFILE = -lsndfile

QMAKE_INFO_PLIST = $${PWD}/src/MyInfo.plist
ICON = $${PWD}/images/qtcs.icns
#OTHER_FILES += $${QMAKE_INFO_PLIST}
