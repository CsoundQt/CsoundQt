# Benchmark for the editor's per-line channel lookup.
#
# Build and run:
#   mkdir build-benchmark && cd build-benchmark
#   qmake ../tests/benchmark_channeltext.pro CONFIG+=release
#   make
#   ./benchmark_channeltext
#
# The benchmark reports the cold-parser cost. The hover feature also caches
# the last resolved channel span, so repeated mouse moves inside one channel
# avoid this lookup; the benchmark is intended to show the worst case when the
# pointer moves onto/out of a channel.

QT += core
CONFIG += console
CONFIG -= app_bundle

TEMPLATE = app
TARGET = benchmark_channeltext

INCLUDEPATH += $$PWD/../src

HEADERS += \
    $$PWD/../src/channeltext.h

SOURCES += \
    $$PWD/../src/channeltext.cpp \
    $$PWD/benchmark_channeltext.cpp
