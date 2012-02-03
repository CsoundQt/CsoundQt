# -------------------------------------------------
# Project created by QtCreator 2010-10-16T20:41:09
# -------------------------------------------------
QT += xml
TEMPLATE = app
TMPDIR = "build"

buildDoubles: CONFIG+=build64
!build32:!build64:CONFIG += build32
build32:build64:CONFIG -= build32
CONFIG += is_quteapp # This is for bundling the QuteApp in the main CsoundQt app, so shouldn't be here
CONFIG += rtmidi #force build rtmidi

unix { 
    macx:include (../qcs-macx.pro)
    else:include (../qcs-unix.pro)
}
win32-g++:include (../qcs-win32.pro)

# No python for QuteApp for now!
#pythonqt:DEFINES += QCS_PYTHONQT
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
    "$${QCSPWD}/documentview.cpp" \
    "$${QCSPWD}/findreplace.cpp" \
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
    "$${QCSPWD}/scoreeditor.cpp" \
    "$${QCSPWD}/filebeditor.cpp" \
    "$${QCSPWD}/eventsheet.cpp" \
    "$${PWD}/main.cpp" \
	"$${PWD}/quteapp.cpp" \
    "$${PWD}/simpledocument.cpp" \
    "$${PWD}/settingsdialog.cpp" \
    aboutwidget.cpp
HEADERS += "$${QCSPWD}/configlists.h" \
    "$${QCSPWD}/console.h" \
    "$${QCSPWD}/csoundengine.h" \
    "$${QCSPWD}/csoundoptions.h" \
    "$${QCSPWD}/curve.h" \
    "$${QCSPWD}/dockhelp.h" \
    "$${QCSPWD}/basedocument.h" \
    "$${QCSPWD}/baseview.h" \
    "$${QCSPWD}/documentview.h" \
    "$${QCSPWD}/findreplace.h" \
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
    "$${QCSPWD}/scoreeditor.h" \
    "$${QCSPWD}/filebeditor.h" \
    "$${QCSPWD}/eventsheet.h" \
	"$${QCSPWD}/types.h" \
	"$${PWD}/quteapp.h" \
    "$${PWD}/simpledocument.h" \
    "$${PWD}/settingsdialog.h" \
    aboutwidget.h
FORMS += "$${PWD}/settingsdialog.ui" \
    "$${QCSPWD}/filebeditor.ui"\
    "$${QCSPWD}/liveeventframe.ui" \
    "$${QCSPWD}/findreplace.ui" \
    "aboutwidget.ui"
LIBS += $${LCSOUND} \
    $${LSNDFILE} \
    $${RTMIDI}
rtmidi { 
    HEADERS += "$${PWD}/../$${RTMIDI_DIR}/RtMidi.h"
    SOURCES += "$${PWD}/../$${RTMIDI_DIR}/RtMidi.cpp"
    INCLUDEPATH += $${PWD}/../$${RTMIDI_DIR}
}

build32:TARGET = QuteApp_f
build64:TARGET = QuteApp_d

DESTDIR = bin
INCLUDEPATH *= $${CSOUND_API_INCLUDE_DIR}
INCLUDEPATH *= $${CSOUND_INTERFACES_INCLUDE_DIR}
INCLUDEPATH *= $${LIBSNDFILE_INCLUDE_DIR}
RESOURCES += "$${PWD}/application.qrc"




