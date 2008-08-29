#select CsoundLib or CsoundLib64 below for Mac version
MAC_LIB=CsoundLib
#MAC_LIB=CsoundLib64

SOURCES += qutecsound.cpp \
           main.cpp \
 dockhelp.cpp \
 opentryparser.cpp \
 options.cpp \
 highlighter.cpp \
 configdialog.cpp \
 configlists.cpp \
 console.cpp \
 documentpage.cpp
HEADERS += qutecsound.h \
 dockhelp.h \
 opentryparser.h \
 options.h \
 highlighter.h \
 types.h \
 configdialog.h \
 configlists.h \
 console.h \
 documentpage.h
TEMPLATE = app
CONFIG += warn_on \
	  thread \
          qt
TARGET = ../bin/qutecsound
RESOURCES = application.qrc

QT += xml

DISTFILES += default.csd \
 opcodes.xml \
 qutecsound.rc

FORMS += configdialog.ui

win32 {
    DEFINES +=WIN32
    HEADERS += "C:/Archivos de programa/Csound/include/CppSound.hpp"
    LIBS += "C:\Archivos de programa\Csound\bin\csnd.dll"
    RC_FILE = qutecsound.rc
}

linux-g++ {
    DEFINES +=LINUX    
    INCLUDEPATH += /usr/local/include/csound/
    LIBS += -lcsound \
-lcsnd
}

macx {
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

CONFIG -= stl

