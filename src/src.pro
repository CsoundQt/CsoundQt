#Builds for float version by default. If you want to use
#the doubles version, run qmake "CONFIG += build64"
#CONFIG += build64

build64 {
    message(Building for doubles \(64-bit\) csound)
    DEFINES += QUTECSOUND_DOUBLE
}
else {
    message(Building for float \(32-bit\) csound.)
    message(For doubles use qmake \"CONFIG += build64\")
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
 qutewidget.cpp
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
 qutewidget.h
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
 qutecsound.rc

FORMS += configdialog.ui \
  utilitiesdialog.ui

win32 {
    DEFINES +=WIN32
    INCLUDEPATH += "C:\Archivos de programa\Csound\include"
    HEADERS += "C:\Archivos de programa\Csound\include\CppSound.hpp"
    build64 {
        LIBS += "C:\Archivos de programa\Csound\bin\Csound64.dll.5.1" \
	   "C:\Archivos de programa\Csound\bin\csnd.dll" 
    }
    else {
        LIBS += "C:\Archivos de programa\Csound\bin\Csound32.dll.5.1" \
	   "C:\Archivos de programa\Csound\bin\csnd.dll" 
    }
    RC_FILE = qutecsound.rc
}

linux-g++ {
    DEFINES +=LINUX    
    INCLUDEPATH += /usr/local/include/csound/
    LIBS += -lcsound \
-lcsnd
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
    HEADERS += /Library/Frameworks/CsoundLib.framework/Versions/Current/Headers/CppSound.hpp
    LIBS += -framework QtXml
    LIBS += -framework QtGui
    LIBS += -framework QtCore
    LIBS += -framework $${MAC_LIB} -lcsnd
    LIBS += -L/Library/Frameworks/$${MAC_LIB}.framework/Versions/Current
    QMAKE_INFO_PLIST = MyInfo.plist
    ICON = ../images/qtcs.icns
}

CONFIG -= stl \
 release

#QMAKE_CXXFLAGS_DEBUG += -DDEBUG

