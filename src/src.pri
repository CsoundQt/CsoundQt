
RESOURCES += "src/application.qrc" \
    "src/icons.qrc" \
    "src/fonts.qrc" \
    src/qml_resources.qrc

FORMS = "src/about.ui" \
    "src/configdialog.ui" \
    "src/keyboardshortcuts.ui" \
    "src/keyselector.ui" \
    "src/utilitiesdialog.ui" \
    src/midilearndialog.ui \
    src/debugpanel.ui \
    src/dockhelp.ui \
    src/livecodeeditor.ui \
    src/newbreakpointdialog.ui \
    src/html5guidisplay.ui

HEADERS = "src/about.h" \
    "src/configdialog.h" \
    "src/configlists.h" \
    "src/console.h" \
    "src/bundledfonts.h" \
    "src/widgetstyle.h" \
    "src/notification.h" \
    "src/debuglog.h" \
    "src/editorthemes.h" \
    "src/csoundengine.h" \
    "src/csoundoptions.h" \
    "src/curve.h" \
    "src/dockhelp.h" \
    "src/dockpanelutils.h" \
    "src/litehtmlview.h" \
    "src/litehtmlcontainer.h" \
    "src/searchindex.h" \
    "src/documentpage.h" \
    "src/documentview.h" \
    "src/externallauncher.h" \
    "src/eventsheet.h" \
    "src/findbar.h" \
    "src/widgetpropertyinfo.h" \
    "src/framewidget.h" \
    "src/bracketmatcher.h" \
    "src/channeltext.h" \
    "src/channelhighlightmode.h" \
    "src/sourcecursor.h" \
    "src/codescan.h" \
    "src/markdown.h" \
    "src/docstringpopup.h" \
    "src/scanservice.h" \
    "src/includecache.h" \
    "src/highlighter.h" \
    "src/inspector.h" \
    "src/keyboardshortcuts.h" \
    "src/node.h" \
    "src/opcodeinsertbar.h" \
    "src/opentryparser.h" \
    "src/options.h" \
    "src/qutebutton.h" \
    "src/qutecheckbox.h" \
    "src/qutecombobox.h" \
    "src/quteconsole.h" \
    "src/csoundqt.h" \
    "src/qutedummy.h" \
    "src/qutegraph.h" \
    "src/quteknob.h" \
    "src/qutemeter.h" \
    "src/qutescope.h" \
    "src/qutewaveform.h" \
    "src/qutevumeter.h" \
    "src/quteslider.h" \
    "src/qutespinbox.h" \
    "src/qutetext.h" \
    "src/qutewidget.h" \
    "src/texteditor.h" \
    "src/themedicons.h" \
    "src/types.h" \
    "src/valuemapping.h" \
    "src/utilitiesdialog.h" \
    "src/widgetlayout.h" \
    "src/widgetpanel.h" \
    "src/widgetpreset.h" \
    "src/qutesheet.h" \
    "src/basedocument.h" \
    "src/baseview.h" \
    $$PWD/csound_threaded_csqt.hpp \
    $$PWD/risset.h \
    $$PWD/selectcolorbutton.h \
    src/midihandler.h \
    src/midilearndialog.h \
    src/debugpanel.h \
    src/livecodeeditor.h \
    src/newbreakpointdialog.h \
    #$$PWD/CsoundHtmlOnlyWrapper.h

SOURCES = "src/about.cpp" \
    "src/configdialog.cpp" \
    "src/configlists.cpp" \
    "src/console.cpp" \
    "src/bundledfonts.cpp" \
    "src/notification.cpp" \
    "src/debuglog.cpp" \
    "src/editorthemes.cpp" \
    "src/csoundengine.cpp" \
    "src/csoundoptions.cpp" \
    "src/curve.cpp" \
    "src/dockhelp.cpp" \
    "src/litehtmlview.cpp" \
    "src/litehtmlcontainer.cpp" \
    "src/searchindex.cpp" \
    "src/documentpage.cpp" \
    "src/documentview.cpp" \
    "src/externallauncher.cpp" \
    "src/eventsheet.cpp" \
    "src/findbar.cpp" \
    "src/framewidget.cpp" \
    "src/bracketmatcher.cpp" \
    "src/channeltext.cpp" \
    "src/sourcecursor.cpp" \
    "src/codescan.cpp" \
    "src/markdown.cpp" \
    "src/docstringpopup.cpp" \
    "src/scanservice.cpp" \
    "src/includecache.cpp" \
    "src/highlighter.cpp" \
    "src/inspector.cpp" \
    "src/keyboardshortcuts.cpp" \
    "src/main.cpp" \
    "src/node.cpp" \
    "src/opcodeinsertbar.cpp" \
    "src/opentryparser.cpp" \
    "src/options.cpp" \
    "src/qutebutton.cpp" \
    "src/qutecheckbox.cpp" \
    "src/qutecombobox.cpp" \
    "src/quteconsole.cpp" \
    "src/csoundqt.cpp" \
    "src/qutedummy.cpp" \
    "src/qutegraph.cpp" \
    "src/quteknob.cpp" \
    "src/qutemeter.cpp" \
    "src/qutescope.cpp" \
    "src/qutewaveform.cpp" \
    "src/qutevumeter.cpp" \
    "src/quteslider.cpp" \
    "src/qutespinbox.cpp" \
    "src/qutetext.cpp" \
    "src/qutewidget.cpp" \
    "src/texteditor.cpp" \
    "src/themedicons.cpp" \
    "src/utilitiesdialog.cpp" \
    "src/widgetlayout.cpp" \
    "src/widgetpanel.cpp" \
    "src/widgetpreset.cpp" \
    "src/qutesheet.cpp" \
    "src/basedocument.cpp" \
    "src/baseview.cpp" \
    $$PWD/risset.cpp \
    $$PWD/selectcolorbutton.cpp \
    src/midihandler.cpp \
    src/midilearndialog.cpp \
    src/debugpanel.cpp \
    src/livecodeeditor.cpp \
    src/newbreakpointdialog.cpp \
    #src/csoundhtmlview.cpp \
    #$$PWD/CsoundHtmlOnlyWrapper.cpp


DISTFILES += "src/default.csd" \
    "src/opcodes.xml" \
    "src/csoundqt.rc" \
    "src/test.csd" \
    $$PWD/QML/ControlSlider.qml

rtmidi {
    HEADERS += "src/../$${RTMIDI_DIR}/RtMidi.h"
    SOURCES += "src/../$${RTMIDI_DIR}/RtMidi.cpp"
    INCLUDEPATH += src/../$${RTMIDI_DIR}
}

html_support: {
	HEADERS += src/csoundhtmlview.h
	HEADERS += src/csoundhtmlwrapper.h
    HEADERS += src/CsoundHtmlOnlyWrapper.h

	SOURCES += src/csoundhtmlview.cpp
	SOURCES += src/csoundhtmlwrapper.cpp
    SOURCES += src/CsoundHtmlOnlyWrapper.cpp
}

LIBS += $${LCSOUND} \
    $${LSNDFILE} \
    $${RTMIDI} \
    $${LPTHREAD}

OTHER_FILES += \
    src/appstyle-dark.css \
    src/appstyle-green.css \
    src/appstyle-white.css \
    src/QML/Keyboard.qml \
    src/QML/Key.qml \
    src/QML/VirtualKeyboard.qml \
    src/QML/Controls.qml

# Bundled litehtml (HTML/CSS renderer) for the documentation viewer.
# Included last so its SOURCES += appends after the SOURCES = assignments above.
include($$PWD/../litehtml.pri)

# Needed for correct deployment on OS X
QML_IMPORT_PATH =src/QML
QML2_IMPORT_PATH =src/QML
