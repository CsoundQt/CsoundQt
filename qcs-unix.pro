!unix:error(This project file is only for Unix-based systems.)
!no_messages {
	message()
	message(Building QuteCsound for Unix-based system.)
}

# Set default paths
DEFAULT_CSOUND_API_INCLUDE_DIRS = /usr/local/include/csound \
	/usr/include/csound
DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS = $${DEFAULT_CSOUND_API_INCLUDE_DIRS}
DEFAULT_CSOUND_LIBRARY_DIRS = /usr/local/lib \
	/usr/lib
DEFAULT_LIBSNDFILE_INCLUDE_DIRS = /usr/include
DEFAULT_LIBSNDFILE_LIBRARY_DIRS = /usr/lib
build32:DEFAULT_CSOUND_LIBS = libcsound.so \
	libcsound.a
build64:DEFAULT_CSOUND_LIBS = libcsound64.so \
	libcsound64.a
#CSND_LIB = libcsnd.so
LIBSNDFILE_LIB = libsndfile.so

DEFAULT_PYTHONQT_INCLUDE_DIRS = /usr/local/include \
	/usr/include
DEFAULT_PYTHONQT_LIBRARY_DIRS = /usr/local/lib \
        /usr/lib\
        ../../../PythonQt2.0.1 \
        ../PythonQt2.0.1 \
        PythonQt2.0.1
DEFAULT_PYTHONQT_TREE_DIRS = ../../../PythonQt2.0.1 \
        ../PythonQt2.0.1 \
        PythonQt2.0.1
PYTHONQT_LIB = libPythonQt_QtAll$${DEBUG_EXT}.so

DEFAULT_PORTMIDI_DIR =  /usr/local/include

# Do configuration step
include(config.pri)

# Use results from config step
LIBS *= -L$${CSOUND_LIBRARY_DIR}
LIBS *= -L$${LIBSNDFILE_LIBRARY_DIR}
rtmidi {
DEFINES += __LINUX_ALSASEQ__
LIBS += -lasound
}
build32:LCSOUND = -lcsound
build64:LCSOUND = -lcsound64
LSNDFILE = -lsndfile

