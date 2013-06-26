!haiku:error(This project file is only for Haiku systems.)
!no_messages {
	message()
	message(Building QuteCsound for Haiku system.)
}

## "CSOUND_SOURCE_TREE = /boot/WORK/CSOUND_GIT/csound5" "LIBSNDFILE_INCLUDE_DIR = /boot/common/include" "LIBSNDFILE_LIBRARY_DIR = /boot/common/lib"
# Set default paths
DEFAULT_CSOUND_API_INCLUDE_DIRS = /boot/common/include/csound
DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS = $${DEFAULT_CSOUND_API_INCLUDE_DIRS}
DEFAULT_CSOUND_LIBRARY_DIRS = /boot/common/lib
DEFAULT_LIBSNDFILE_INCLUDE_DIRS = /boot/common/include
DEFAULT_LIBSNDFILE_LIBRARY_DIRS = /boot/common/lib
build32:DEFAULT_CSOUND_LIBS = libcsound.so \
	libcsound.a
build64:DEFAULT_CSOUND_LIBS = libcsound64.so \
	libcsound64.a
#CSND_LIB = libcsnd.so
LIBSNDFILE_LIB = libsndfile.so

DEFAULT_PYTHONQT_INCLUDE_DIRS = /boot/common/include
DEFAULT_PYTHONQT_LIBRARY_DIRS = /boot/common/lib \
        ../../../PythonQt2.0.1 \
        ../PythonQt2.0.1 \
        PythonQt2.0.1
DEFAULT_PYTHONQT_TREE_DIRS = ../../../PythonQt2.0.1 \
        ../PythonQt2.0.1 \
        PythonQt2.0.1
PYTHONQT_LIB = libPythonQt_QtAll$${DEBUG_EXT}.so


# Do configuration step
include(config.pri)

# Use results from config step
LIBS *= -L$${CSOUND_LIBRARY_DIR}
LIBS *= -L$${LIBSNDFILE_LIBRARY_DIR}
build32:LCSOUND = -lcsound
build64:LCSOUND = -lcsound64
LSNDFILE = -lsndfile

