# ##############################################################################
# The following variables can be set in the qmake argument list if they are not
# found in the default locations.  Don't forget to use quotes.  For example ...
# qmake qutecsound.pro "CSOUND_INCLUDE_DIR = <path to csound.h>"
# CSOUND_INCLUDE_DIR
# CSOUND_LIBRARY_DIR
# RTMIDI_DIR
# PYTHONQT_SRC_DIR
# If the Csound headers and libraries you are using were built from source but
# not installed, set CSOUND_SOURCE_TREE to the directory containing the Csound
# source tree.  In this case, the CSOUND_INCLUDE_DIR and CSOUND_LIBRARY_DIR
# variables do not need to be set explicitly.
# These variables can also be set in a file named config.user.pri, which is
# used if it is found in the same directory as this file (config.pri).
# ##############################################################################
# ##############################################################################
# BUILD OPTIONS:
# CONFIG+=build32    To build floats version
# CONFIG+=pythonqt  # To build with PythonQt support
# CONFIG+=rtmidi   To build with RtMidi support
# CONFIG+=record_support
# OS X only OPTIONS:
# CONFIG+=universal   To build i386/ppc version. Default is platform default
# ##############################################################################

record_support {
DEFINES += PERFTHREAD_RECORD # Requires Csound >= 6.04
}
csound6: {
message("No need to specify CONFIG+=csound6 anymore as Csound6 build is now default")
}

!csound5 {
    DEFINES += CSOUND6
    CONFIG += csound6
    debugger {
        DEFINES += QCS_DEBUGGER
        message("Building debugger")
    }
    message("Building for Csound 6")
} else {
message("Building for Csound 5 (unsupported)")
}

greaterThan(QT_MAJOR_VERSION, 4) {
    QT += widgets
    QT += printsupport
    DEFINES += USE_QT5
    CONFIG += QCS_QT5
}

greaterThan(QT_MAJOR_VERSION, 4): greaterThan (QT_MINOR_VERSION, 2) {
    QT += quickwidgets
    DEFINES += USE_QT_GT_53
    CONFIG += QCS_QT53
}

buildDoubles: message("Doubles is now built by default, no need to specify buildDoubles option")

!build32: CONFIG += build64

build32:build64:CONFIG -= build32
unix {
    macx:include (qcs-macx.pro)
    else:haiku-g++ {include (qcs-haiku.pro) }
    else: include (qcs-unix.pro)
}
win32-g++:include (qcs-win32.pro)

include(src/src.pri)
TRANSLATIONS = "src/translations/qutecsound_en.ts" \
    "src/translations/qutecsound_es.ts" \
    "src/translations/qutecsound_de.ts" \
    "src/translations/qutecsound_pt.ts" \
    "src/translations/qutecsound_fr.ts" \
    "src/translations/qutecsound_it.ts" \
    "src/translations/qutecsound_tr.ts" \
    "src/translations/qutecsound_el.ts" \
    "src/translations/qutecsound_uk.ts" \
    "src/translations/qutecsound_fi.ts" \
    "src/translations/qutecsound_ru.ts" \
    "src/translations/qutecsound_fa.ts"

pythonqt {
    include ( $${PYTHONQT_SRC_DIR}/build/PythonQt.prf )
    include ( $${PYTHONQT_SRC_DIR}/build/PythonQt_QtAll.prf )

    LIBS *= -L$${PYTHONQT_LIB_DIR} -l$${PYTHONQT_LIB} -l$${PYTHONQT_LIB}_QtAll
    LIBS -= -l$${PYTHONQT_LIB}_d -l$${PYTHONQT_LIB}_QtAll_d

# Note, this is Python, not PythonQt include dir!
    win32:INCLUDEPATH *= $${PYTHON_INCLUDE_DIR}

    INCLUDEPATH *= $${PYTHONQT_SRC_DIR}/src
    INCLUDEPATH *= $${PYTHONQT_SRC_DIR}/extensions/PythonQt_QtAll
    QT += svg sql webkit xmlpatterns opengl
    QCS_QT53 {
        QT += webkitwidgets multimedia multimediawidgets positioning sensors
    }
}

INCLUDEPATH *= $${CSOUND_API_INCLUDE_DIR}
INCLUDEPATH *= $${CSOUND_INTERFACES_INCLUDE_DIR}

#DESTDIR = $${_PRO_FILE_PWD_}/bin
DESTDIR = bin
MOC_DIR = build/moc
UI_DIR = build/ui
RCC_DIR = build/rc

TARGET = CsoundQt

build32:TARGET = $${TARGET}-f
build64:TARGET = $${TARGET}-d
pythonqt:TARGET = $${TARGET}-py

csound6:TARGET = $${TARGET}-cs6

CONFIG(debug, debug|release):TARGET = $${TARGET}-debug

