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
 opcodes.xml

FORMS += configdialog.ui

!macx {
    LIBS += -lcsound \
-lcsnd
}

win {
    DEFINES +=WIN32
}
linux-g++ {
    DEFINES +=LINUX    
    INCLUDEPATH += /usr/local/include/csound/
}

macx {
    DEFINES +=MACOSX
    HEADERS += /Library/Frameworks/CsoundLib.framework/Versions/Current/Headers/CppSound.hpp
    LIBS += -framework QtXml
    LIBS += -framework QtGui
    LIBS += -framework QtCore
    LIBS += -framework CsoundLib -lcsnd
    LIBS += -L/Library/Frameworks/CsoundLib.framework/Versions/Current

}

