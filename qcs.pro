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
# To support HTML5 via the <html> element in the csd using the Qt WebEngine
# (preferably use Qt 5.8 or later):
# CONFIG+=html_webengine
# If you want to build HTML5 support using QtWebkit framework (Qt 5.5 or earlier):
# CONFIG+=html_webkit
# OS X only OPTIONS:
# CONFIG+=universal  #  To build i386/ppc version. Default is x86_64
# CONFIG+=i386  #  To build i386 version. Default is x86_64
# LINUX ONLY:
# To install CsoundQt and its dekstop file and icons somewhere else than /usr/local/bin and /usr/share
# use variables INSTALL_DIR (default /usr/local) and SHARE_DIR (default /usr/share).
# For example for local install use:
# qmake qcs.pro INSTALL_DIR=~ SHARE_DIR=~/.local/share
################################################################################

DEFINES += NOMINMAX

csound6 {
    message("No need to specify CONFIG+=csound6 anymore as Csound6 build is now default.")
}

# Add C++11 support since version 0.9.4
greaterThan(QT_MAJOR_VERSION, 4){
CONFIG += c++11
} else {
QMAKE_CXXFLAGS += -std=c++0x
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
} else {
    DEFINES += USE_QT_LT_50
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
win32-msvc2017:include (qcs-win32.pro)

# Requires Csound >= 6.04
record_support|perfThread_build {
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
    "src/translations/qutecsound_fa.ts" \
    "src/translations/qutecsound_kr.ts"


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


html_webengine: {
message("Building html support with QtWebengine")
DEFINES += QCS_QTHTML USE_WEBENGINE
QT += network webenginewidgets webchannel
CONFIG += c++11
}

html_webkit: {
message("Building html support with QtWebkit")
DEFINES += QCS_QTHTML USE_WEBKIT
QT += network webkit webkitwidgets
CONFIG += c++11
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
html_webkit|html_webengine:TARGET = $${TARGET}-html

csound6:TARGET = $${TARGET}-cs6

CONFIG(debug, debug|release):TARGET = $${TARGET}-debug

# install commands for linux (for make install)
# use 'sudo make install' for system wide installation
unix:!macx {
    isEmpty(INSTALL_DIR) {
		INSTALL_DIR=/usr/local  # ~  #for HOME
	}
	isEmpty(SHARE_DIR) {
        SHARE_DIR=/usr/share # ~/.local/share for HOME install
	}
	target.path = $$INSTALL_DIR/bin
	target.files = $$OUT_PWD/$$DESTDIR/$$TARGET
	target.commands = ln -sf $$target.path/$$TARGET $(INSTALL_ROOT)/$$INSTALL_DIR/bin/csoundqt #	 create link always with the same name


	
	# see comments: https://github.com/CsoundQt/CsoundQt/issues/258
    desktop.path=$$SHARE_DIR/applications
    desktop.commands = rm -f $$SHARE_DIR/applications/CsoundQt.desktop &&  # remove the old, uppercase one, if present one
	desktop.commands += desktop-file-install --mode=644 --dir=$$SHARE_DIR/applications $$PWD/csoundqt.desktop
    #TODO: if local install, ie not /usr/share, dekstop-file-install  --dir=$$desktop.path

	icon.path=$$SHARE_DIR/icons/hicolor/scalable/apps
    icon.files=images/csoundqt.svg

	mimetypes.path=$$INSTALL_DIR # in some reason path must be set to create install target in Makefile
	mimetypes.commands = cd $$PWD/mime-types/; ./add_csound_mimetypes.sh $(INSTALL_ROOT)/$$INSTALL_DIR


    examples.path = $$SHARE_DIR/csoundqt/
    examples.commands = rm -rf $$SHARE_DIR/qutecsound #remove the old examples
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
        #if PythonQt 3.2, naming the libraries is different
        #this should be set progammatically but hardcode for now.
        pythonQtDylib = libPythonQt-Qt5-Python2.7.3.dylib# before PyhontQt3.2: libPythonQt.1.dylib
        pythonQtAllDylib =   libPythonQt_QtAll-Qt5-Python2.7.3.dylib # # before PythonQt 3.2:  libPythonQt_QtAll.1.dylib
        pythonqt.path = $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks
        pythonqt.files = $${PYTHONQT_LIB_DIR}/$$pythonQtAllDylib $${PYTHONQT_LIB_DIR}/$$pythonQtDylib #TODO: use pythonqt/lib dir
        INSTALLS += pythonqt
    }

    pythonlinks.path= $$PWD
    pythonlinks.commands = install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python Python.framework/Versions/2.7/Python $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/$$TARGET ;
    pythonqt {
        pythonlinks.commands += install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python Python.framework/Versions/2.7/Python $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/$$pythonQtDylib ;
        pythonlinks.commands += install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python Python.framework/Versions/2.7/Python $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/$$pythonQtAllDylib ;
        pythonlinks.commands += install_name_tool -change $$pythonQtDylib @rpath/$$pythonQtDylib $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/$$TARGET ;
        pythonlinks.commands += install_name_tool -change $$pythonQtAllDylib  @rpath/$$pythonQtAllDylib  $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/$$TARGET ;
        pythonlinks.commands += install_name_tool -change $$pythonQtDylib @rpath/$$pythonQtDylib $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/$$pythonQtAllDylib  ;


    }

    final.commands = rm -rf  $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework ;
    final.commands += install_name_tool -change @rpath/libcsnd6.6.0.dylib libcsnd6.6.0.dylib $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/$$TARGET ;
    final.commands += install_name_tool -change  @rpath/CsoundLib64.framework/Versions/6.0/CsoundLib64 CsoundLib64.framework/Versions/6.0/CsoundLib64 $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/$$TARGET ;
    final.commands += $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD/src/QML #-dmg # nb! -dmg only for local build, do not commit to git!
    final.path = $$PWD
    INSTALLS += cocoa printsupport pythonlinks final

}

win32 {
    first.path = $$PWD
    first.commands = $$[QT_INSTALL_PREFIX]/bin/windeployqt  -qmldir=$$PWD/src/QML  $$OUT_PWD/$$DESTDIR/$${TARGET}.exe # first deployment
    INSTALLS += first
}

message(CONFIGs are:    $${CONFIG})
message(DEFINES are:    $${DEFINES})
message(INCLUDEPATH is: $${INCLUDEPATH})
message(LIBS are:       $${LIBS})
message(TARGET is:      $${TARGET})

DISTFILES += \
    config.user.pri

