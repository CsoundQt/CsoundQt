################################################################################
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
################################################################################
# BUILD OPTIONS:
# CONFIG+=build32    To build floats version
# CONFIG+=pythonqt   To build with PythonQt support
# CONFIG+=rtmidi     To build with RtMidi support
# CONFIG+=record_support
# CONFIG+=debugger
# To support HTML5 via the <html> element in the csd using the Qt WebEngine:
# CONFIG+=html_webengine
# OS X only OPTIONS:
# CONFIG+=universal  #  To build i386/ppc version. Default is x86_64
# CONFIG+=i386  #  To build i386 version. Default is x86_64
################################################################################

#testing for qt based html support
#CONFIG += html_webkit # OR: html_webengine
#CONFIG += html_webengine

html_webkit: {
message("Building html support with QtWebkit")
DEFINES += QCS_QTHTML USE_WEBKIT
QT += network webkit webkitwidgets
CONFIG += c++11
}

html_webengine: {
message("Building html support with QtWebengine")
DEFINES += QCS_QTHTML USE_WEBENGINE
QT += network webenginewidgets webchannel
CONFIG += c++11
}


DEFINES += NOMINMAX

csound6 {
    message("No need to specify CONFIG+=csound6 anymore as Csound6 build is now default.")
}

!csound5 {
    DEFINES += CSOUND6
    CONFIG += csound6
    debugger {
        DEFINES += QCS_DEBUGGER
        message("Building debugger.")
    }
    message("Building for Csound 6.")
} else {
    message("Building for Csound 5 (unsupported).")
}

QT += concurrent network

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

greaterThan(QT_MAJOR_VERSION, 4): greaterThan (QT_MINOR_VERSION, 3) {
    DEFINES += USE_QT_GT_54
    CONFIG += QCS_QT54
}

greaterThan(QT_MAJOR_VERSION, 4): greaterThan (QT_MINOR_VERSION, 5) {
	DEFINES += USE_QT_GT_55
	CONFIG += QCS_QT55
}

greaterThan(QT_MAJOR_VERSION, 4): greaterThan (QT_MINOR_VERSION, 7) {
        DEFINES += USE_QT_GT_58
        CONFIG += QCS_QT58
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
win32-msvc2013:include (qcs-win32.pro)
win32-msvc2015:include (qcs-win32.pro)

# Requires Csound >= 6.04
record_support {
    DEFINES += PERFTHREAD_RECORD
    message("Building recording support.")
}

!csound5 {
    debugger {
        DEFINES += QCS_DEBUGGER
        message("Building debugger.")
    }
}

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
    # Note, this is Python, not PythonQt include dir!
    win32:INCLUDEPATH *= $${PYTHON_INCLUDE_DIR}
    INCLUDEPATH *= $${PYTHONQT_SRC_DIR}/src
    INCLUDEPATH *= $${PYTHONQT_SRC_DIR}/extensions/PythonQt_QtAll
    QT += svg sql webkit xmlpatterns opengl
    QCS_QT53 {
		QT += webkitwidgets multimedia multimediawidgets #positioning sensors
    }
	QCS_QT55 {
		QT -= webkit webkitwidgets
		#QT += webengine # maybe we need to add that for some functionality
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

# install commands for linux (for make install)
# use 'sudo make install' for system wide installation
unix:!macx {
	isEmpty(INSTALL_DIR) {
		INSTALL_DIR=/usr/local  # ~  #for HOME
	}
	isEmpty(SHARE_DIR) {
		SHARE_DIR=/usr/share # ~/.local for HOME install
	}
	target.path = $$INSTALL_DIR/bin
	target.commands = ln -sf $$TARGET $(INSTALL_ROOT)/$$INSTALL_DIR/bin/csoundqt #	 create link always with the same name
	target.files = $$DESTDIR/$$TARGET


	desktop.path=$$SHARE_DIR/applications
	desktop.files=CsoundQt.desktop

	icon.path=$$SHARE_DIR/icons # not sure in fact, if /usr/share/icons is enough or better to put into hicolor...
	icon.files=images/qtcs.svg

	mimetypes.path=$$INSTALL_DIR # in some reason path must be set to create install target in Makefile
	mimetypes.commands = cd $$PWD/mime-types/; ./add_csound_mimetypes.sh $(INSTALL_ROOT)/$$INSTALL_DIR

	examples.path = $$SHARE_DIR/qutecsound/
	examples.files = src/Examples

	INSTALLS += target desktop icon mimetypes examples
}

# for OSX add Scripts and Examples to be bundle in Contents->Resources
macx {
    pythonqt {
        scripts.path = Contents/Resources
        scripts.files = src/Scripts
        QMAKE_BUNDLE_DATA += scripts
    }
    examples.path = Contents/Resources
    examples.files = "src/Examples/FLOSS Manual Examples"
    examples.files += "src/Examples/McCurdy Collection"
    examples.files += "src/Examples/Stria Synth"
    QMAKE_BUNDLE_DATA += examples

    # EXPERIMENTAL INSTALL instructions for making bundle (ie make install)
    first.path = $$PWD
    first.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD/src/QML # first deployment
    INSTALLS += first

    cocoa.path = $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/PlugIns/platforms # fix missing plugins (with qt 5.4.2 at least)
    cocoa.files =  $$[QT_INSTALL_PREFIX]/plugins/platforms/libqcocoa.dylib

    printsupport.path =  $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/PlugIns/printsupport
    printsupport.files =  $$[QT_INSTALL_PREFIX]/plugins/printsupport/libcocoaprintersupport.dylib

    pythonqt {
        pythonqt.path = $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks
        pythonqt.files = $${PYTHONQT_LIB_DIR}/libPythonQt_QtAll.1.dylib $${PYTHONQT_LIB_DIR}/libPythonQt.1.dylib #TODO: use pythonqt/lib dir
        INSTALLS += pythonqt
    }

    pythonlinks.path= a$$PWD
    pythonlinks.commands = install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python Python.framework/Versions/2.7/Python $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/$$TARGET ;
    pythonqt {
        pythonlinks.commands += install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python Python.framework/Versions/2.7/Python $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/libPythonQt.1.dylib ;
        pythonlinks.commands += install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python Python.framework/Versions/2.7/Python $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/libPythonQt_QtAll.1.dylib
    }

    final.commands = rm -rf  $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework ;
    final.commands += $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD/src/QML
    final.path = $$PWD
    INSTALLS += cocoa printsupport pythonlinks final

}

message(CONFIGs are:    $${CONFIG})
message(DEFINES are:    $${DEFINES})
message(INCLUDEPATH is: $${INCLUDEPATH})
message(LIBS are:       $${LIBS})
message(TARGET is:      $${TARGET})

DISTFILES += \
    config.user.pri

