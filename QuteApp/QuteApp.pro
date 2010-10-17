# -------------------------------------------------
# Project created by QtCreator 2010-10-16T20:41:09
# -------------------------------------------------
QT += xml
TEMPLATE = app
OBJECTS_DIR = "build/obj"
RCC_DIR = "build/rcc"
UI_DIR = "build/ui"
MOC_DIR = "build/moc"
TMPDIR = "build"
!build32:!build64:CONFIG += build32
build32:build64:CONFIG -= build32
unix { 
    macx:include (../qcs-macx.pro)
    else:include (../qcs-unix.pro)
}
win32-g++:include (../qcs-win32.pro)
pythonqt:DEFINES += QCS_PYTHONQT
rtmidi:DEFINES += QCS_RTMIDI
INCLUDEPATH = ../src
QCSPWD = "../src"
SOURCES += "$${QCSPWD}/configlists.cpp" \
    "$${QCSPWD}/console.cpp" \
    "$${QCSPWD}/csoundengine.cpp" \
    "$${QCSPWD}/csoundoptions.cpp" \
    "$${QCSPWD}/curve.cpp" \
    "$${QCSPWD}/dockhelp.cpp" \
    "$${QCSPWD}/basedocument.cpp" \
    "$${QCSPWD}/baseview.cpp" \
    "$${QCSPWD}/framewidget.cpp" \
    "$${QCSPWD}/highlighter.cpp" \ # "$${QCSPWD}/keyboardshortcuts.cpp" \
    "$${QCSPWD}/node.cpp" \
    "$${QCSPWD}/opentryparser.cpp" \
    "$${QCSPWD}/options.cpp" \
    "$${QCSPWD}/qcsperfthread.cpp" \
    "$${QCSPWD}/qutebutton.cpp" \
    "$${QCSPWD}/qutecheckbox.cpp" \
    "$${QCSPWD}/qutecombobox.cpp" \
    "$${QCSPWD}/quteconsole.cpp" \
    "$${QCSPWD}/qutedummy.cpp" \
    "$${QCSPWD}/qutegraph.cpp" \
    "$${QCSPWD}/quteknob.cpp" \
    "$${QCSPWD}/qutemeter.cpp" \
    "$${QCSPWD}/qutescope.cpp" \
    "$${QCSPWD}/quteslider.cpp" \
    "$${QCSPWD}/qutespinbox.cpp" \
    "$${QCSPWD}/qutetext.cpp" \
    "$${QCSPWD}/qutewidget.cpp" \
    "$${QCSPWD}/texteditor.cpp" \
    "$${QCSPWD}/widgetlayout.cpp" \
    "$${QCSPWD}/widgetpreset.cpp" \
    main.cpp \
    quteapp.cpp \
    quteappwizard.cpp \
    simpledocument.cpp
HEADERS += "$${QCSPWD}/configlists.h" \
    "$${QCSPWD}/console.h" \
    "$${QCSPWD}/csoundengine.h" \
    "$${QCSPWD}/csoundoptions.h" \
    "$${QCSPWD}/curve.h" \
    "$${QCSPWD}/dockhelp.h" \
    "$${QCSPWD}/basedocument.h" \
    "$${QCSPWD}/baseview.h" \
    "$${QCSPWD}/framewidget.h" \
    "$${QCSPWD}/highlighter.h" \ # "$${QCSPWD}/keyboardshortcuts.h" \
    "$${QCSPWD}/node.h" \
    "$${QCSPWD}/opentryparser.h" \
    "$${QCSPWD}/options.h" \
    "$${QCSPWD}/qcsperfthread.h" \
    "$${QCSPWD}/qutebutton.h" \
    "$${QCSPWD}/qutecheckbox.h" \
    "$${QCSPWD}/qutecombobox.h" \
    "$${QCSPWD}/quteconsole.h" \
    "$${QCSPWD}/qutedummy.h" \
    "$${QCSPWD}/qutegraph.h" \
    "$${QCSPWD}/quteknob.h" \
    "$${QCSPWD}/qutemeter.h" \
    "$${QCSPWD}/qutescope.h" \
    "$${QCSPWD}/quteslider.h" \
    "$${QCSPWD}/qutespinbox.h" \
    "$${QCSPWD}/qutetext.h" \
    "$${QCSPWD}/qutewidget.h" \
    "$${QCSPWD}/texteditor.h" \
    "$${QCSPWD}/widgetlayout.h" \
    "$${QCSPWD}/widgetpreset.h" \
    quteapp.h \
    quteappwizard.h \
    simpledocument.h
FORMS += quteappwizard.ui
LIBS += $${LCSOUND} \ # $${LCSND} \
    $${LSNDFILE} \
    $${RTMIDI}
rtmidi { 
    HEADERS += "$${PWD}/../$${RTMIDI_DIR}/RtMidi.h"
    SOURCES += "$${PWD}/../$${RTMIDI_DIR}/RtMidi.cpp"
    INCLUDEPATH += $${PWD}/../$${RTMIDI_DIR}
}
TARGET = QuteApp
DESTDIR = bin
INCLUDEPATH *= $${CSOUND_API_INCLUDE_DIR}
INCLUDEPATH *= $${CSOUND_INTERFACES_INCLUDE_DIR}
INCLUDEPATH *= $${LIBSNDFILE_INCLUDE_DIR}
RESOURCES += application.qrc
