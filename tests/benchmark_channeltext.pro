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

# Workaround for Xcode 16+/26 clang on Apple Silicon: Qt's qyieldcpu.h calls
# __yield() without including <arm_acle.h>, which newer clang rejects with
# "implicitly declaring library function '__yield'". Include the header clang
# asks for (declares __yield) and, as a fallback, silence the diagnostic.
macx {
    contains(QT_ARCH, arm64)|contains(QT_ARCH, aarch64): QMAKE_CXXFLAGS += -include arm_acle.h
    QMAKE_CXXFLAGS += -Wno-implicit-function-declaration
}

HEADERS += \
    $$PWD/../src/channeltext.h

SOURCES += \
    $$PWD/../src/channeltext.cpp \
    $$PWD/benchmark_channeltext.cpp
