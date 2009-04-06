#Builds for float version by default. If you want to use
#the doubles version, run:
#qmake "CONFIG += build64"

CONFIG += qute_cpp \
 libsndfile

DEFINES += QUTE_USE_CSOUNDPERFORMANCETHREAD

TRANSLATIONS = qutecsound_es.ts \
               qutecsound_en.ts


win32 {
    QUTECSOUND_CSOUND_PATH = C:\Program Files\Csound
    LIBSNDFILE_PATH = C:\Development Files\libsndfile-1_0_17
}
build64 {
    message(Building for doubles \(64-bit\) csound)
    DEFINES += USE_DOUBLE
}
else {
    message(Building for float \(32-    bit\) csound.)
    message(For doubles use qmake \"CONFIG += build64\")
}


libsndfile {
    !win32 : LIBS += -lsndfile
    DEFINES += USE_LIBSNDFILE
}

SOURCES += qutecsound.cpp \
           main.cpp \
 dockhelp.cpp \
 opentryparser.cpp \
 options.cpp \
 highlighter.cpp \
 configdialog.cpp \
 configlists.cpp \
 console.cpp \
 documentpage.cpp \
 utilitiesdialog.cpp \
 widgetpanel.cpp \
 qutewidget.cpp \
 quteslider.cpp \
 findreplace.cpp \
 qutetext.cpp \
 qutebutton.cpp \
 qutedummy.cpp \
 quteknob.cpp \
 qutecombobox.cpp \
 qutecheckbox.cpp \
 quteconsole.cpp \
 qutemeter.cpp \
 qutegraph.cpp \
 framewidget.cpp \
 curve.cpp \
 qutespinbox.cpp \
 qutescope.cpp \
 node.cpp \
 graphicwindow.cpp
HEADERS += qutecsound.h \
 dockhelp.h \
 opentryparser.h \
 options.h \
 highlighter.h \
 types.h \
 configdialog.h \
 configlists.h \
 console.h \
 documentpage.h \
 utilitiesdialog.h \
 widgetpanel.h \
 qutewidget.h \
 quteslider.h \
 findreplace.h \
 qutetext.h \
 qutebutton.h \
 qutedummy.h \
 quteknob.h \
 qutecombobox.h \
 qutecheckbox.h \
 quteconsole.h \
 qutemeter.h \
 qutegraph.h \
 framewidget.h \
 curve.h \
 qutespinbox.h \
 qutescope.h \
 node.h \
 graphicwindow.h
TEMPLATE = app
CONFIG += warn_on \
	  thread \
          qt \
 debug
TARGET = ../bin/qutecsound
RESOURCES = application.qrc

QT += xml

DISTFILES += default.csd \
 opcodes.xml \
 qutecsound.rc \
 test.csd

FORMS += configdialog.ui \
  utilitiesdialog.ui \
 findreplace.ui

win32 {
    DEFINES +=WIN32
    INCLUDEPATH += "$${QUTECSOUND_CSOUND_PATH}\include"
    HEADERS += "$${QUTECSOUND_CSOUND_PATH}\include\csound.h"
    qute_cpp {
        HEADERS += "$${QUTECSOUND_CSOUND_PATH}\csound.hpp"
        HEADERS += "$${QUTECSOUND_CSOUND_PATH}\include\csPerfThread.hpp"
        HEADERS += "$${QUTECSOUND_CSOUND_PATH}\include\cwindow.h"
        LIBS += "$${QUTECSOUND_CSOUND_PATH}\bin\csnd.dll"
    }
    build64 {
        LIBS += "$${QUTECSOUND_CSOUND_PATH}\bin\libcsound64.a"
    }
    else {
        LIBS += "$${QUTECSOUND_CSOUND_PATH}\bin\libcsound32.a"
    }
    libsndfile {
        INCLUDEPATH += "$${LIBSNDFILE_PATH}"
        LIBS += "$${LIBSNDFILE_PATH}\libsndfile-1.a"
    }
    RC_FILE = qutecsound.rc
}

linux-g++ {
    DEFINES += LINUX
    INCLUDEPATH += /usr/local/include/csound/ /usr/include/csound/
    qute_cpp {
        LIBS += -lcsnd
    }
    build64 {
        LIBS += -lcsound64
    }
    else {
        LIBS += -lcsound
    }
}

solaris-g++-64 {
    DEFINES += SOLARIS
    INCLUDEPATH += /usr/local/include/csound/
    qute_cpp {
        LIBS += -lcsnd
    }
    build64 {
        LIBS += -lcsound64
    }
    else {
        LIBS += -lcsound
    }
}

macx {
    build64 {
        MAC_LIB = CsoundLib64
    }
    else {
        MAC_LIB = CsoundLib
    }
    message(Building using $${MAC_LIB})
    DEFINES +=MACOSX
    HEADERS += /Library/Frameworks/CsoundLib.framework/Versions/Current/Headers/csound.h
    qute_cpp {
        HEADERS += /Library/Frameworks/CsoundLib.framework/Versions/Current/Headers/csound.hpp
        HEADERS += /Library/Frameworks/CsoundLib.framework/Versions/Current/Headers/csPerfThread.hpp
        HEADERS += /Library/Frameworks/CsoundLib.framework/Versions/Current/Headers/cwindow.h
        LIBS += /Library/Frameworks/CsoundLib.framework/Versions/Current/lib_csnd.dylib
    }
    LIBS += -framework QtXml
    LIBS += -framework QtGui
    LIBS += -framework QtCore
    LIBS += -framework $${MAC_LIB}
    LIBS += -L/Library/Frameworks/$${MAC_LIB}.framework/Versions/Current
    QMAKE_INFO_PLIST = MyInfo.plist
    ICON = ../images/qtcs.icns
}


#QMAKE_CXXFLAGS_DEBUG += -DDEBUG

CONFIG -= stl \
 release


