
TEMPLATE = subdirs
unix {
    macx: SUBDIRS = qcs-macx.pro
    else: SUBDIRS = qcs-unix.pro
}
win32-g++: SUBDIRS = qcs-win32.pro
OTHER_FILES += config.pri \
    config.user.pri \
    src/src.pri

TRANSLATIONS =  \
    "$${PWD}/src/translations/qutecsound_en.ts" \
    "$${PWD}/src/translations/qutecsound_es.ts" \
    "$${PWD}/src/translations/qutecsound_de.ts" \
    "$${PWD}/src/translations/qutecsound_pt.ts" \
    "$${PWD}/src/translations/qutecsound_fr.ts" \
    "$${PWD}/src/translations/qutecsound_it.ts" \
    "$${PWD}/src/translations/qutecsound_tr.ts" \
    "$${PWD}/src/translations/qutecsound_el.ts" \
#SUBDIRS += ClearQuteCsoundPrefs/ClearQuteCsoundPrefs.pro
