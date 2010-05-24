
TEMPLATE = app

unix {
    macx: include (qcs-macx.pro)
    else: include (qcs-unix.pro)
}
win32-g++: include (qcs-win32.pro)

include(src/src.pri)

#SUBDIRS += ClearQuteCsoundPrefs/ClearQuteCsoundPrefs.pro
