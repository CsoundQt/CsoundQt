RESOURCES = "$${PWD}/*.qrc"
FORMS = "$${PWD}/*.ui"
HEADERS = "$${PWD}/*.h"
SOURCES = "$${PWD}/*.cpp"
TRANSLATIONS = "$${PWD}/translations/qutecsound_*"
LIBS += $${LCSOUND} \
    $${LCSND} \
    $${LSNDFILE}
DISTFILES += "$${PWD}/default.csd" \
    "$${PWD}/opcodes.xml" \
    "$${PWD}/qutecsound.rc" \
    "$${PWD}/test.csd"
OTHER_FILES = $${DISTFILES} \
    "$${PWD}/translations/qutecsound_*.ts"
