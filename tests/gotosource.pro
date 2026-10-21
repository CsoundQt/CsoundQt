# Unit tests for the "Go to Source" helpers: the index of source definitions,
# the cursor helpers and the position of a context menu request (no Csound, no
# full CsoundQt build).
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/gotosource.pro CONFIG+=release
#   make
#   QT_QPA_PLATFORM=offscreen ./test_gotosource

QT += core gui widgets testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_gotosource

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
    $$PWD/../src/editorthemes.h \
    $$PWD/../src/highlighter.h \
    $$PWD/../src/sourcedefinitions.h \
    $$PWD/../src/texteditor.h

SOURCES += \
    $$PWD/../src/editorthemes.cpp \
    $$PWD/../src/highlighter.cpp \
    $$PWD/../src/sourcedefinitions.cpp \
    $$PWD/../src/texteditor.cpp \
    $$PWD/test_gotosource.cpp
