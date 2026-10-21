# Unit tests for the opcode list that CsoundQt parses from src/opcodes.xml.
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/opcodes.pro CONFIG+=release
#   make
#   QT_QPA_PLATFORM=offscreen ./test_opcodes

QT += core gui xml testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_opcodes

macx {
    contains(QT_ARCH, arm64)|contains(QT_ARCH, aarch64): QMAKE_CXXFLAGS += -include arm_acle.h
    QMAKE_CXXFLAGS += -Wno-implicit-function-declaration
}

INCLUDEPATH += $$PWD/../src

# The opcodes.xml of the source tree, so that the test finds it wherever it is
# built.
DEFINES += OPENTRIES_XML_PATH=\\\"$$PWD/../src/opcodes.xml\\\"

# types.h includes the Csound API header. The path can be given on the qmake
# command line, like for the main project.
isEmpty(CSOUND_API_INCLUDE_DIR): CSOUND_API_INCLUDE_DIR = /usr/local/include/csound
INCLUDEPATH += $$CSOUND_API_INCLUDE_DIR

HEADERS += \
    $$PWD/../src/node.h \
    $$PWD/../src/opentryparser.h \
    $$PWD/../src/types.h

SOURCES += \
    $$PWD/../src/node.cpp \
    $$PWD/../src/opentryparser.cpp \
    $$PWD/test_opcodes.cpp
