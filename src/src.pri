RESOURCES = "$${PWD}/*.qrc"
FORMS = "$${PWD}/*.ui"
HEADERS = "$${PWD}/*.h"
SOURCES = "$${PWD}/*.cpp"
TRANSLATIONS =  \
    "$${PWD}/translations/qutecsound_en.ts" \
    "$${PWD}/translations/qutecsound_es.ts" \
    "$${PWD}/translations/qutecsound_de.ts" \
    "$${PWD}/translations/qutecsound_pt.ts" \
    "$${PWD}/translations/qutecsound_fr.ts" \
    "$${PWD}/translations/qutecsound_it.ts" \
    "$${PWD}/translations/qutecsound_tr.ts" \
    "$${PWD}/translations/qutecsound_el.ts" \
LIBS += $${LCSOUND} \
    $${LCSND} \
    $${LSNDFILE}
DISTFILES += "$${PWD}/default.csd" \
    "$${PWD}/opcodes.xml" \
    "$${PWD}/qutecsound.rc" \
    "$${PWD}/test.csd"
OTHER_FILES = $${DISTFILES}
