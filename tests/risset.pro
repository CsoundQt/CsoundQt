# Unit tests for risset discovery and the managed plugin paths.
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/risset.pro CONFIG+=release
#   make
#   ./test_risset

QT += core xml testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_risset

INCLUDEPATH += $$PWD/csound-stub $$PWD/../src

HEADERS += \
    $$PWD/../src/risset.h \
    $$PWD/../src/opentryparser.h \
    $$PWD/../src/node.h \
    $$PWD/../src/types.h

SOURCES += \
    $$PWD/../src/risset.cpp \
    $$PWD/test_risset.cpp
