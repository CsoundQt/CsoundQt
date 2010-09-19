RESOURCES = "$${PWD}/application.qrc" \
    "./pythonscripts.qrc"
FORMS = "$${PWD}/about.ui" \
    "$${PWD}/configdialog.ui" \
    "$${PWD}/findreplace.ui" \
    "$${PWD}/keyboardshortcuts.ui" \
    "$${PWD}/keyselector.ui" \
    "$${PWD}/liveeventcontrol.ui" \
    "$${PWD}/liveeventframe.ui" \
    "$${PWD}/utilitiesdialog.ui"
HEADERS = "$${PWD}/about.h" \
    "$${PWD}/configdialog.h" \
    "$${PWD}/configlists.h" \
    "$${PWD}/console.h" \
    "$${PWD}/csoundengine.h" \
    "$${PWD}/csoundoptions.h" \
    "$${PWD}/curve.h" \
    "$${PWD}/dockhelp.h" \
    "$${PWD}/documentpage.h" \
    "$${PWD}/documentview.h" \
    "$${PWD}/dotgenerator.h" \
    "$${PWD}/eventsheet.h" \
    "$${PWD}/findreplace.h" \
    "$${PWD}/framewidget.h" \
    "$${PWD}/graphicwindow.h" \
    "$${PWD}/highlighter.h" \
    "$${PWD}/inspector.h" \
    "$${PWD}/keyboardshortcuts.h" \
    "$${PWD}/liveeventcontrol.h" \
    "$${PWD}/liveeventframe.h" \
    "$${PWD}/node.h" \
    "$${PWD}/opentryparser.h" \
    "$${PWD}/options.h" \
    "$${PWD}/qutebutton.h" \
    "$${PWD}/qutecheckbox.h" \
    "$${PWD}/qutecombobox.h" \
    "$${PWD}/quteconsole.h" \
    "$${PWD}/qutecsound.h" \
    "$${PWD}/qutedummy.h" \
    "$${PWD}/qutegraph.h" \
    "$${PWD}/quteknob.h" \
    "$${PWD}/qutemeter.h" \
    "$${PWD}/qutescope.h" \
    "$${PWD}/quteslider.h" \
    "$${PWD}/qutespinbox.h" \
    "$${PWD}/qutetext.h" \
    "$${PWD}/qutewidget.h" \
    "$${PWD}/texteditor.h" \
    "$${PWD}/types.h" \
    "$${PWD}/utilitiesdialog.h" \
    "$${PWD}/widgetlayout.h" \
    "$${PWD}/widgetpanel.h" \
    "$${PWD}/widgetpreset.h" \
    "$${PWD}/qutesheet.h" \
    "$${PWD}/basedocument.h" \
    "$${PWD}/qcsperfthread.h"
SOURCES = "$${PWD}/about.cpp" \
    "$${PWD}/configdialog.cpp" \
    "$${PWD}/configlists.cpp" \
    "$${PWD}/console.cpp" \
    "$${PWD}/csoundengine.cpp" \
    "$${PWD}/csoundoptions.cpp" \
    "$${PWD}/curve.cpp" \
    "$${PWD}/dockhelp.cpp" \
    "$${PWD}/documentpage.cpp" \
    "$${PWD}/documentview.cpp" \
    "$${PWD}/dotgenerator.cpp" \
    "$${PWD}/eventsheet.cpp" \
    "$${PWD}/findreplace.cpp" \
    "$${PWD}/framewidget.cpp" \
    "$${PWD}/graphicwindow.cpp" \
    "$${PWD}/highlighter.cpp" \
    "$${PWD}/inspector.cpp" \
    "$${PWD}/keyboardshortcuts.cpp" \
    "$${PWD}/liveeventcontrol.cpp" \
    "$${PWD}/liveeventframe.cpp" \
    "$${PWD}/main.cpp" \
    "$${PWD}/node.cpp" \
    "$${PWD}/opentryparser.cpp" \
    "$${PWD}/options.cpp" \
    "$${PWD}/qutebutton.cpp" \
    "$${PWD}/qutecheckbox.cpp" \
    "$${PWD}/qutecombobox.cpp" \
    "$${PWD}/quteconsole.cpp" \
    "$${PWD}/qutecsound.cpp" \
    "$${PWD}/qutedummy.cpp" \
    "$${PWD}/qutegraph.cpp" \
    "$${PWD}/quteknob.cpp" \
    "$${PWD}/qutemeter.cpp" \
    "$${PWD}/qutescope.cpp" \
    "$${PWD}/quteslider.cpp" \
    "$${PWD}/qutespinbox.cpp" \
    "$${PWD}/qutetext.cpp" \
    "$${PWD}/qutewidget.cpp" \
    "$${PWD}/texteditor.cpp" \
    "$${PWD}/utilitiesdialog.cpp" \
    "$${PWD}/widgetlayout.cpp" \
    "$${PWD}/widgetpanel.cpp" \
    "$${PWD}/widgetpreset.cpp" \
    "$${PWD}/qutesheet.cpp" \
    "$${PWD}/basedocument.cpp" \
    "$${PWD}/qcsperfthread.cpp"
LIBS += $${LCSOUND} \
    $${LCSND} \
    $${LSNDFILE}
DISTFILES += "$${PWD}/default.csd" \
    "$${PWD}/opcodes.xml" \
    "$${PWD}/qutecsound.rc" \
    "$${PWD}/test.csd"
pythonqt { 
    HEADERS += "$${PWD}/pythonconsole.h" \
        "$${PWD}/pyqcsobject.h"
    SOURCES += "$${PWD}/pythonconsole.cpp" \
        "$${PWD}/pyqcsobject.cpp"
}
