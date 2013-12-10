RESOURCES += "src/application.qrc" \
    "src/pythonscripts.qrc" \
	"src/icons.qrc"
FORMS = "src/about.ui" \
    "src/configdialog.ui" \
    "src/findreplace.ui" \
    "src/keyboardshortcuts.ui" \
    "src/keyselector.ui" \
    "src/liveeventcontrol.ui" \
    "src/liveeventframe.ui" \
    "src/utilitiesdialog.ui" \
    "src/appdetailspage.ui" \
    "src/pluginspage.ui" \
    "src/additionalfilespage.ui" \
    "src/filebeditor.ui" \
    src/midilearndialog.ui
HEADERS = "src/about.h" \
    "src/configdialog.h" \
    "src/configlists.h" \
    "src/console.h" \
    "src/csoundengine.h" \
    "src/csoundoptions.h" \
    "src/curve.h" \
    "src/dockhelp.h" \
    "src/documentpage.h" \
    "src/documentview.h" \
    "src/dotgenerator.h" \
    "src/eventsheet.h" \
    "src/findreplace.h" \
    "src/framewidget.h" \
    "src/graphicwindow.h" \
    "src/highlighter.h" \
    "src/inspector.h" \
    "src/keyboardshortcuts.h" \
    "src/liveeventcontrol.h" \
    "src/liveeventframe.h" \
    "src/node.h" \
    "src/opentryparser.h" \
    "src/options.h" \
    "src/qutebutton.h" \
    "src/qutecheckbox.h" \
    "src/qutecombobox.h" \
    "src/quteconsole.h" \
    "src/qutecsound.h" \
    "src/qutedummy.h" \
    "src/qutegraph.h" \
    "src/quteknob.h" \
    "src/qutemeter.h" \
    "src/qutescope.h" \
    "src/quteslider.h" \
    "src/qutespinbox.h" \
    "src/qutetext.h" \
    "src/qutewidget.h" \
    "src/texteditor.h" \
    "src/types.h" \
    "src/utilitiesdialog.h" \
    "src/widgetlayout.h" \
    "src/widgetpanel.h" \
    "src/widgetpreset.h" \
    "src/qutesheet.h" \
	"src/basedocument.h" \
    "src/baseview.h" \
    "src/appwizard.h" \
    "src/appdetailspage.h" \
    "src/pluginspage.h" \
    "src/additionalfilespage.h" \
    "src/scoreeditor.h" \
    "src/filebeditor.h" \
    src/midihandler.h \
    src/midilearndialog.h
SOURCES = "src/about.cpp" \
    "src/configdialog.cpp" \
    "src/configlists.cpp" \
    "src/console.cpp" \
    "src/csoundengine.cpp" \
    "src/csoundoptions.cpp" \
    "src/curve.cpp" \
    "src/dockhelp.cpp" \
    "src/documentpage.cpp" \
    "src/documentview.cpp" \
    "src/dotgenerator.cpp" \
    "src/eventsheet.cpp" \
    "src/findreplace.cpp" \
    "src/framewidget.cpp" \
    "src/graphicwindow.cpp" \
    "src/highlighter.cpp" \
    "src/inspector.cpp" \
    "src/keyboardshortcuts.cpp" \
    "src/liveeventcontrol.cpp" \
    "src/liveeventframe.cpp" \
    "src/main.cpp" \
    "src/node.cpp" \
    "src/opentryparser.cpp" \
    "src/options.cpp" \
    "src/qutebutton.cpp" \
    "src/qutecheckbox.cpp" \
    "src/qutecombobox.cpp" \
    "src/quteconsole.cpp" \
    "src/qutecsound.cpp" \
    "src/qutedummy.cpp" \
    "src/qutegraph.cpp" \
    "src/quteknob.cpp" \
    "src/qutemeter.cpp" \
    "src/qutescope.cpp" \
    "src/quteslider.cpp" \
    "src/qutespinbox.cpp" \
    "src/qutetext.cpp" \
    "src/qutewidget.cpp" \
    "src/texteditor.cpp" \
    "src/utilitiesdialog.cpp" \
    "src/widgetlayout.cpp" \
    "src/widgetpanel.cpp" \
    "src/widgetpreset.cpp" \
    "src/qutesheet.cpp" \
	"src/basedocument.cpp" \
    "src/baseview.cpp" \
    "src/appwizard.cpp" \
    "src/appdetailspage.cpp" \
    "src/pluginspage.cpp" \
    "src/additionalfilespage.cpp" \
    "src/scoreeditor.cpp" \
    "src/filebeditor.cpp" \
    src/midihandler.cpp \
    src/midilearndialog.cpp
DISTFILES += "src/default.csd" \
    "src/opcodes.xml" \
    "src/qutecsound.rc" \
    "src/test.csd"
pythonqt {
    HEADERS += "src/pythonconsole.h" \
        "src/pyqcsobject.h"
    SOURCES += "src/pythonconsole.cpp" \
        "src/pyqcsobject.cpp"
}
rtmidi {
    HEADERS += "src/../$${RTMIDI_DIR}/RtMidi.h"
    SOURCES += "src/../$${RTMIDI_DIR}/RtMidi.cpp"
    INCLUDEPATH += src/../$${RTMIDI_DIR}
}

LIBS += $${LCSOUND} \
	$${LCSND} \
    $${LSNDFILE} \
    $${RTMIDI}

OTHER_FILES += \
    src/appstyle.css

