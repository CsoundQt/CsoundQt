
#TEMPLATE = app

unix {
    macx: include (qcs-macx.pro)
    else: include (qcs-unix.pro)
}
win32-g++: include (qcs-win32.pro)

include(src/src.pri)

TRANSLATIONS = "src/translations/qutecsound_en.ts" \
    "src/translations/qutecsound_es.ts" \
    "src/translations/qutecsound_de.ts" \
    "src/translations/qutecsound_pt.ts" \
    "src/translations/qutecsound_fr.ts" \
    "src/translations/qutecsound_it.ts" \
    "src/translations/qutecsound_tr.ts" \
    "src/translations/qutecsound_el.ts" \
    "src/translations/qutecsound_uk.ts"

#SUBDIRS += ClearQuteCsoundPrefs/ClearQuteCsoundPrefs.pro
