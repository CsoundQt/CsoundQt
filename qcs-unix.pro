!unix:error(This project file is only for Unix-based systems.)
!no_messages { 
    message()
    message(Building QuteCsound for Unix-based system.)
}
!build32:!build64:CONFIG += build32
build32:build64:CONFIG -= build32
DEFAULT_CSOUND_INCLUDE_DIRS = /usr/local/include/csound \
    /usr/include/csound
DEFAULT_CSOUND_LIBRARY_DIRS = /usr/local/lib \
    /usr/lib
DEFAULT_LIBSNDFILE_INCLUDE_DIRS = /usr/include
DEFAULT_LIBSNDFILE_LIBRARY_DIRS = /usr/lib
build32:DEFAULT_CSOUND_LIBS = libcsound.so \
    libcsound.a
build64:DEFAULT_CSOUND_LIBS = libcsound64.so \
    libcsound64.a
CSND_LIB = libcsnd.so
LIBSNDFILE_LIB = libsndfile.a
include(config.pri)
INCLUDEPATH += $${CSOUND_INCLUDE_DIR} \
    $${LIBSNDFILE_INCLUDE_DIR}
LIBS += -L$${CSOUND_LIBRARY_DIR} \
    -L$${LIBSNDFILE_LIBRARY_DIR}
build32:LCSOUND = -lcsound
build64:LCSOUND = -lcsound64
LCSND = -lcsnd
LSNDFILE = -lsndfile
include(src/src.pri)
