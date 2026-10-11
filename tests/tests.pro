# Unit tests that do not need Csound or the full CsoundQt build.
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/tests.pro CONFIG+=release
#   make
#   QT_QPA_PLATFORM=offscreen ./test_externallauncher

QT += core gui testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_externallauncher

INCLUDEPATH += $$PWD/../src

HEADERS += \
    $$PWD/../src/externallauncher.h

SOURCES += \
    $$PWD/../src/externallauncher.cpp \
    $$PWD/test_externallauncher.cpp
