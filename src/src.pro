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

LIBS += -lcsound \
-lcsnd
