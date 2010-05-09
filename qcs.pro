
TEMPLATE = subdirs
unix {
    macx: SUBDIRS = qcs-macx.pro
    else: SUBDIRS = qcs-unix.pro
}
win32-g++: SUBDIRS = qcs-win32.pro
OTHER_FILES += config.pri \
    config.user.pri \
    src/src.pri
#SUBDIRS += ClearQuteCsoundPrefs/ClearQuteCsoundPrefs.pro
