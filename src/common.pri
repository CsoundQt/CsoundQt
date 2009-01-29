build_pass \
{
    CONFIG(debug, debug|release) \
    {
        message(Generating Makefile.Debug...)
    }
    else \
    {
        message(Generating Makefile.Release...)
    }
}



DESTDIR = \
$${QUTECSOUND_SRC_DIR}\bin



UI_DIR      = tmp\ui
OBJECTS_DIR = tmp\obj
MOC_DIR     = tmp\moc
RCC_DIR     = tmp\rcc

CONFIG(debug, debug|release) \
{
    UI_DIR      = $$join(UI_DIR     ,,,\debug)
    OBJECTS_DIR = $$join(OBJECTS_DIR,,,\debug)
    MOC_DIR     = $$join(MOC_DIR    ,,,\debug)
    RCC_DIR     = $$join(RCC_DIR    ,,,\debug)
}
CONFIG(release, debug|release) \
{
    UI_DIR      = $$join(UI_DIR     ,,,\release)
    OBJECTS_DIR = $$join(OBJECTS_DIR,,,\release)
    MOC_DIR     = $$join(MOC_DIR    ,,,\release)
    RCC_DIR     = $$join(RCC_DIR    ,,,\release)
}

INCLUDEPATH += \
$${UI_DIR} \



TEMPLATE = \
app



CONFIG -= \
stl \

CONFIG += \
qt \
warn_on \
thread \
qute_cpp \
libsndfile \



QT += \
xml \



DEFINES += \
QUTE_USE_CSOUNDPERFORMANCETHREAD \

libsndfile \
{
    DEFINES += \
    USE_LIBSNDFILE
}



INCLUDEPATH += \
$${CSOUND_DIR}\include

libsndfile \
{
    INCLUDEPATH += \
    $${LIBSNDFILE_DIR} \
}



RESOURCES = \
$${QUTECSOUND_SRC_DIR}\application.qrc

RC_FILE = \
$${QUTECSOUND_SRC_DIR}\qutecsound.rc



FORMS += \
$${QUTECSOUND_SRC_DIR}\configdialog.ui \
$${QUTECSOUND_SRC_DIR}\utilitiesdialog.ui \
$${QUTECSOUND_SRC_DIR}\findreplace.ui \



SOURCES += \
$${QUTECSOUND_SRC_DIR}\qutecsound.cpp \
$${QUTECSOUND_SRC_DIR}\main.cpp \
$${QUTECSOUND_SRC_DIR}\dockhelp.cpp \
$${QUTECSOUND_SRC_DIR}\opentryparser.cpp \
$${QUTECSOUND_SRC_DIR}\options.cpp \
$${QUTECSOUND_SRC_DIR}\highlighter.cpp \
$${QUTECSOUND_SRC_DIR}\configdialog.cpp \
$${QUTECSOUND_SRC_DIR}\configlists.cpp \
$${QUTECSOUND_SRC_DIR}\console.cpp \
$${QUTECSOUND_SRC_DIR}\documentpage.cpp \
$${QUTECSOUND_SRC_DIR}\utilitiesdialog.cpp \
$${QUTECSOUND_SRC_DIR}\widgetpanel.cpp \
$${QUTECSOUND_SRC_DIR}\qutewidget.cpp \
$${QUTECSOUND_SRC_DIR}\quteslider.cpp \
$${QUTECSOUND_SRC_DIR}\findreplace.cpp \
$${QUTECSOUND_SRC_DIR}\qutetext.cpp \
$${QUTECSOUND_SRC_DIR}\qutebutton.cpp \
$${QUTECSOUND_SRC_DIR}\qutedummy.cpp \
$${QUTECSOUND_SRC_DIR}\quteknob.cpp \
$${QUTECSOUND_SRC_DIR}\qutecombobox.cpp \
$${QUTECSOUND_SRC_DIR}\qutecheckbox.cpp \
$${QUTECSOUND_SRC_DIR}\quteconsole.cpp \
$${QUTECSOUND_SRC_DIR}\qutemeter.cpp \
$${QUTECSOUND_SRC_DIR}\qutegraph.cpp \
$${QUTECSOUND_SRC_DIR}\framewidget.cpp \
$${QUTECSOUND_SRC_DIR}\curve.cpp \
$${QUTECSOUND_SRC_DIR}\qutespinbox.cpp \
$${QUTECSOUND_SRC_DIR}\qutescope.cpp \
$${QUTECSOUND_SRC_DIR}\node.cpp \
$${QUTECSOUND_SRC_DIR}\graphicwindow.cpp \



HEADERS += \
$${CSOUND_DIR}\include\csound.h \
\
$${QUTECSOUND_SRC_DIR}\qutecsound.h \
$${QUTECSOUND_SRC_DIR}\dockhelp.h \
$${QUTECSOUND_SRC_DIR}\opentryparser.h \
$${QUTECSOUND_SRC_DIR}\options.h \
$${QUTECSOUND_SRC_DIR}\highlighter.h \
$${QUTECSOUND_SRC_DIR}\types.h \
$${QUTECSOUND_SRC_DIR}\configdialog.h \
$${QUTECSOUND_SRC_DIR}\configlists.h \
$${QUTECSOUND_SRC_DIR}\console.h \
$${QUTECSOUND_SRC_DIR}\documentpage.h \
$${QUTECSOUND_SRC_DIR}\utilitiesdialog.h \
$${QUTECSOUND_SRC_DIR}\widgetpanel.h \
$${QUTECSOUND_SRC_DIR}\qutewidget.h \
$${QUTECSOUND_SRC_DIR}\quteslider.h \
$${QUTECSOUND_SRC_DIR}\findreplace.h \
$${QUTECSOUND_SRC_DIR}\qutetext.h \
$${QUTECSOUND_SRC_DIR}\qutebutton.h \
$${QUTECSOUND_SRC_DIR}\qutedummy.h \
$${QUTECSOUND_SRC_DIR}\quteknob.h \
$${QUTECSOUND_SRC_DIR}\qutecombobox.h \
$${QUTECSOUND_SRC_DIR}\qutecheckbox.h \
$${QUTECSOUND_SRC_DIR}\quteconsole.h \
$${QUTECSOUND_SRC_DIR}\qutemeter.h \
$${QUTECSOUND_SRC_DIR}\qutegraph.h \
$${QUTECSOUND_SRC_DIR}\framewidget.h \
$${QUTECSOUND_SRC_DIR}\curve.h \
$${QUTECSOUND_SRC_DIR}\qutespinbox.h \
$${QUTECSOUND_SRC_DIR}\qutescope.h \
$${QUTECSOUND_SRC_DIR}\node.h \
$${QUTECSOUND_SRC_DIR}\graphicwindow.h \

qute_cpp \
{
    HEADERS += \
    $${CSOUND_DIR}\include\csound.hpp \
    $${CSOUND_DIR}\include\csPerfThread.hpp \
    $${CSOUND_DIR}\include\cwindow.h \
}



LIBS += \

qute_cpp \
{
    LIBS += \
    $${CSOUND_DIR}\bin\csnd.dll \
}

libsndfile \
{
    LIBS += \
    $${LIBSNDFILE_DIR}\libsndfile-1.a \
}



DISTFILES += \
$${QUTECSOUND_SRC_DIR}\default.csd \
$${QUTECSOUND_SRC_DIR}\opcodes.xml \
$${QUTECSOUND_SRC_DIR}\qutecsound.rc \
$${QUTECSOUND_SRC_DIR}\test.csd \
