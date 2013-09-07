
!win32-g++: error(This project file is only for Windows builds using MinGW/g++.)
!no_messages {
    message()
    message(Building CsoundQt for Windows using MinGW/g++.)
}

CONFIG -= debug_and_release debug_and_release_target \
    copy_dir_files precompile_header shared

# Set default paths
DEFAULT_CSOUND_API_INCLUDE_DIRS = "$$(PROGRAMFILES)\\Csound\\include"
DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS = $${DEFAULT_CSOUND_API_INCLUDE_DIRS}
DEFAULT_CSOUND_LIBRARY_DIRS = "$$(PROGRAMFILES)\\Csound\\bin"
DEFAULT_LIBSNDFILE_INCLUDE_DIRS = "$$(PROGRAMFILES)\\Mega-Nerd\\libsndfile\\include"
DEFAULT_LIBSNDFILE_LIBRARY_DIRS = $${DEFAULT_CSOUND_LIBRARY_DIRS}
build32: DEFAULT_CSOUND_LIBS = csound32.dll.5.2
build64: DEFAULT_CSOUND_LIBS = csound64.dll.5.2
LIBSNDFILE_LIB = libsndfile-1.dll

DEFAULT_PYTHON_INCLUDE_DIRS = "$$(HOMEDRIVE)\\Python26\\include"
DEFAULT_PYTHONQT_SRC_DIRS = "$$(PROGRAMFILES)\\PythonQt"


# Do configuration step
include(config.pri)

# Use results from config step
RC_FILE = "src/qutecsound.rc"
LCSOUND = "$${CSOUND_LIBRARY_DIR}/$${CSOUND_LIB}"
csound6: LCSND = "$${CSOUND_LIBRARY_DIR}/csnd6.dll"
else: LCSND =  "$${CSOUND_LIBRARY_DIR}/csnd.dll"
LSNDFILE = "$${LIBSNDFILE_LIBRARY_DIR}/$${LIBSNDFILE_LIB}"

rtmidi {
DEFINES += __WINDOWS_MM__
LIBS += -lwinmm
}

quteapp_f {
message(Bundling QuteApp_f)
RESOURCES += "src/quteapp_f_win.qrc"
}
quteapp_d {
message(Bundling QuteApp_d)
RESOURCES += "src/quteapp_d_win.qrc"
}

# For OleInitialize() FLTK bug workaround
LIBS *= -lole32
