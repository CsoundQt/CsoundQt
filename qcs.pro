
###############################################################################
#
# The following variables can be set in the qmake argument list if they are not
# found in the default locations.  Don't forget to use quotes.  For example ...
#   qmake qutecsound.pro "CSOUND_INCLUDE_DIR = <path to csound.h>"
#
# CSOUND_INCLUDE_DIR
# CSOUND_LIBRARY_DIR
# LIBSNDFILE_INCLUDE_DIR
# LIBSNDFILE_LIBRARY_DIR
#
# They can also be set in a file named config.user.pri, which is used if it is
# found in the same directory as this file (config.pri).
#
###############################################################################

###############################################################################
# BUILD OPTIONS:
# CONFIG+=build64    To build doubles version
#
# OS X only OPTIONS:
# CONFIG+=intel         To build intel only version (Universal is the default)
###############################################################################

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
