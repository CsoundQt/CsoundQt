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

INCLUDEPATH += $$PWD/../src

HEADERS += \
    $$PWD/../src/markdown.h

SOURCES += \
    $$PWD/../src/markdown.cpp \
    $$PWD/test_markdown.cpp
