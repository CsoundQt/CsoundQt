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
    $$PWD/../src/externallauncher.h

SOURCES += \
    $$PWD/../src/externallauncher.cpp \
    $$PWD/test_externallauncher.cpp
