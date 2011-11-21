# ##############################################################################
# The following variables can be set in the qmake argument list if they are not
# found in the default locations.  Don't forget to use quotes.  For example ...
# qmake qutecsound.pro "CSOUND_INCLUDE_DIR = <path to csound.h>"
# CSOUND_INCLUDE_DIR
# CSOUND_LIBRARY_DIR
# LIBSNDFILE_INCLUDE_DIR
# LIBSNDFILE_LIBRARY_DIR
# RTMIDI_DIR
# If the Csound headers and libraries you are using were built from source but
# not installed, set CSOUND_SOURCE_TREE to the directory containing the Csound
# source tree.  In this case, the CSOUND_INCLUDE_DIR and CSOUND_LIBRARY_DIR
# variables do not need to be set explicitly.
# These variables can also be set in a file named config.user.pri, which is
# used if it is found in the same directory as this file (config.pri).
# ##############################################################################
# ##############################################################################
# BUILD OPTIONS:
# CONFIG+=buildDoubles    To build doubles version
# CONFIG+=build64    To build doubles version (deprecated)
# CONFIG+=pythonqt   To build with PythonQt support
# CONFIG+=rtmidi   To build with Portmidi support
# OS X only OPTIONS:
# CONFIG+=universal   To build i386/ppc version. Default is platform default
# ##############################################################################

buildDoubles: CONFIG += build64
!build32:!build64:CONFIG += build32
build32:build64:CONFIG -= build32
unix {
    macx:include (qcs-macx.pro)
    else:include (qcs-unix.pro)
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
	"src/translations/qutecsound_ru.ts"
pythonqt {
    include ( $${PYTHONQT_TREE_DIR}/build/PythonQt.prf )
    include ( $${PYTHONQT_TREE_DIR}/build/PythonQt_QtAll.prf )

    win32:INCLUDEPATH *= $${PYTHON_INCLUDE_DIR}
    INCLUDEPATH *= $${PYTHONQT_TREE_DIR}/src
    INCLUDEPATH *= $${PYTHONQT_TREE_DIR}/extensions/PythonQt_QtAll
}

INCLUDEPATH *= $${CSOUND_API_INCLUDE_DIR}
INCLUDEPATH *= $${CSOUND_INTERFACES_INCLUDE_DIR}
INCLUDEPATH *= $${LIBSNDFILE_INCLUDE_DIR}

DESTDIR = bin
TARGET = CsoundQt
build32:TARGET = $${TARGET}-f
build64:TARGET = $${TARGET}-d
pythonqt:TARGET = $${TARGET}-py
CONFIG(debug, debug|release):TARGET = $${TARGET}-debug
