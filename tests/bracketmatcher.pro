# Unit tests for the bracket matcher (no Csound, no full CsoundQt build).
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/bracketmatcher.pro CONFIG+=release
#   make
#   QT_QPA_PLATFORM=offscreen ./test_bracketmatcher

QT += core gui testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_bracketmatcher

# Workaround for Xcode 16+/26 clang on Apple Silicon: Qt's qyieldcpu.h calls
# __yield() without including <arm_acle.h>, which newer clang rejects with
# "implicitly declaring library function '__yield'". Include the header clang
# asks for (declares __yield) and, as a fallback, silence the diagnostic.
macx {
    contains(QT_ARCH, arm64)|contains(QT_ARCH, aarch64): QMAKE_CXXFLAGS += -include arm_acle.h
    QMAKE_CXXFLAGS += -Wno-implicit-function-declaration
}

INCLUDEPATH += $$PWD/../src

HEADERS += \
    $$PWD/../src/bracketmatcher.h \
    $$PWD/../src/editorthemes.h \
    $$PWD/../src/highlighter.h

SOURCES += \
    $$PWD/../src/bracketmatcher.cpp \
    $$PWD/../src/editorthemes.cpp \
    $$PWD/../src/highlighter.cpp \
    $$PWD/test_bracketmatcher.cpp
