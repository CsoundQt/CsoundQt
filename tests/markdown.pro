# Unit tests for the small Markdown renderer used by UDO docstrings.
#
# Build and run:
#   mkdir build && cd build
#   qmake ../tests/markdown.pro CONFIG+=release
#   make
#   ./test_markdown

QT += core testlib
CONFIG += testcase console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = test_markdown

# Workaround for Xcode 16+/26 clang on Apple Silicon: Qt's qyieldcpu.h calls
# __yield() without including <arm_acle.h>, which newer clang rejects with
# "implicitly declaring library function '__yield'". Include the header clang
# asks for (declares __yield), and as a fallback, silence the diagnostic.
macx {
    contains(QT_ARCH, arm64)|contains(QT_ARCH, aarch64): QMAKE_CXXFLAGS += -include arm_acle.h
    QMAKE_CXXFLAGS += -Wno-implicit-function-declaration
}

INCLUDEPATH += $$PWD/../src

HEADERS += \
    $$PWD/../src/markdown.h

SOURCES += \
    $$PWD/../src/markdown.cpp \
    $$PWD/test_markdown.cpp
