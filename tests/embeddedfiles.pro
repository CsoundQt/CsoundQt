# Unit tests for the <CsFileB> parsing, encoding and extraction helper.
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/embeddedfiles.pro CONFIG+=release
#   make
#   ./test_embeddedfiles

QT += core testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_embeddedfiles

INCLUDEPATH += $$PWD/../src

HEADERS += \
    $$PWD/../src/embeddedfiles.h

SOURCES += \
    $$PWD/../src/embeddedfiles.cpp \
    $$PWD/test_embeddedfiles.cpp
