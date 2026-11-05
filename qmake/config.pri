
CONFIG *= thread \
    warn_on
CONFIG -= stl
QT *= xml

build32:TMPDIR = build/floats
build64:TMPDIR = build/doubles
#build64:DEFINES += USE_DOUBLE
OBJECTS_DIR = "$${TMPDIR}/obj"

exists($$PWD/../config.user.pri) {
    include($$PWD/../config.user.pri)
	message(... config.user.pri found)
}
!no_messages {
    message(" ")
	build32:message(Building CsoundQt for the single precision version of Csound.)
	build64:message(Building CsoundQt for the double precision version of Csound.)
	CONFIG(debug, debug|release):message(Building debug version.)
	CONFIG(release, debug|release):message(Building release version.)
    message(" ")
	message(CONFIG ...)
	for(flag, CONFIG):message(+ $$flag)
    message(" ")
}
isEmpty(CSOUND_API_INCLUDE_DIR) {
    !isEmpty(CSOUND_INCLUDE_DIR):CSOUND_API_INCLUDE_DIR = $${CSOUND_INCLUDE_DIR}
    isEmpty(CSOUND_API_INCLUDE_DIR):!isEmpty(CSOUND_SOURCE_TREE) {
        CSOUND_API_INCLUDE_DIR = $${CSOUND_SOURCE_TREE}/include
        CSOUND_INTERFACES_INCLUDE_DIR = $${CSOUND_SOURCE_TREE}/interfaces
    }
    isEmpty(CSOUND_API_INCLUDE_DIR) {
        !no_messages:message(Csound API include directory not specified.)
        for(dir, DEFAULT_CSOUND_API_INCLUDE_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}):exists($${dir}/csound.h):exists($${dir}/cwindow.h) {
                !no_messages {
                    message(CSOUND_API_INCLUDE_DIR set to $${dir})
                    # message()
                }
                CSOUND_API_INCLUDE_DIR = $${dir}
                break()
            }
        }
    }
    isEmpty(CSOUND_API_INCLUDE_DIR):error(A valid Csound API include directory was not found.)
}
isEmpty(CSOUND_LIBRARY_DIR) {
    !isEmpty(CSOUND_SOURCE_TREE):CSOUND_LIBRARY_DIR = $${CSOUND_SOURCE_TREE}
    else {
        !no_messages:message(Csound library directory not specified.)
        for(dir, DEFAULT_CSOUND_LIBRARY_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}) {
                !no_messages:message(... in $${dir} for $${DEFAULT_CSOUND_LIBS})
                for(csound_lib, DEFAULT_CSOUND_LIBS):exists($${dir}/$${csound_lib}) {
                    !no_messages {
                        message(CSOUND_LIBRARY_DIR set to $${dir})
                        # message()
                    }
                    CSOUND_LIB = $${csound_lib}
                    CSOUND_LIBRARY_DIR = $${dir}
                    break()
                }
            }
        }
    }
    isEmpty(CSOUND_LIBRARY_DIR):error(A valid Csound library directory was not found.)
}
isEmpty(CSOUND_LIB) {
    for(csound_lib, DEFAULT_CSOUND_LIBS) {
    	message(Searching $${CSOUND_LIBRARY_DIR}/$${csound_lib})
	exists($${CSOUND_LIBRARY_DIR}/$${csound_lib}) {
	    CSOUND_LIB = $${csound_lib}
            break()
	}
    }
    isEmpty(CSOUND_LIB):error(A valid csound library was not found.)
}

rtmidi {
# Only the bundled rtmidi submodule is supported. System RtMidi libraries are
# deliberately not used: we cannot control their version or API.
!exists($$PWD/../rtmidi/RtMidi.h) {
    error("RtMidi submodule not found. Run 'git submodule update --init --recursive' or build with CONFIG+=no_rtmidi.")
}
!no_messages:message(Using the bundled rtmidi submodule.)
}
!rtmidi: message(Not building with RtMidi support.)
win32 {
    CSOUND_INCLUDE_DIR = $$replace(CSOUND_INCLUDE_DIR, \\\\, /)
    CSOUND_LIBRARY_DIR = $$replace(CSOUND_LIBRARY_DIR, \\\\, /)
}
!no_messages {
    message(Csound API include directory is $${CSOUND_API_INCLUDE_DIR})
    message(Csound interfaces include directory is $${CSOUND_INTERFACES_INCLUDE_DIR})
    message(Csound library directory is $${CSOUND_LIBRARY_DIR})
    message(Csound library is $${DEFAULT_CSOUND_LIBS})
    pythonqt {
        win32:message(Python include directory is $${PYTHON_INCLUDE_DIR})
        message(PythonQt source tree directory is $${PYTHONQT_SRC_DIR})
        message(PythonQt lib directory is $${PYTHONQT_LIB_DIR})
    }
    rtmidi {
        message(Using bundled RtMidi)
		DEFINES += CSQT_RTMIDI
    }
    # message()
}
!no_checks {
    defineTest(directoryExists) {
        exists($${1}):return(true)
        return(false)
    }
    defineTest(csoundApiHeaderExists) {
        exists($${CSOUND_API_INCLUDE_DIR}/$${1}):return(true)
        return(false)
    }
    defineTest(csoundInterfacesHeaderExists) {
        exists($${CSOUND_INTERFACES_INCLUDE_DIR}/$${1}):return(true)
        return(false)
    }
    defineTest(csoundLibraryExists) {
        exists($${CSOUND_LIBRARY_DIR}/$${1}):return(true)
        return(false)
    }
    !directoryExists($${CSOUND_API_INCLUDE_DIR}):error(Csound API include directory not found)
    !directoryExists($${CSOUND_LIBRARY_DIR}):error(Csound library directory not found)
    pythonqt {
        win32:!directoryExists($${PYTHON_INCLUDE_DIR}):error(Python include directory not found)
		!directoryExists($${PYTHONQT_SRC_DIR}):error(PythonQt include directory not found)
		!directoryExists($${PYTHONQT_LIB_DIR}):error(PythonQt build directory not found)
    }
    !csoundApiHeaderExists(csound.h):error(csound.h not found)
    !csoundApiHeaderExists(csound.hpp):error(csound.hpp not found)
    !csoundApiHeaderExists(cwindow.h):error(cwindow.h not found)
    !csoundLibraryExists($${CSOUND_LIB}):error(Csound API library not found)
}

unix:QMAKE_CXXFLAGS += -g -Wunused-parameter

win32-msvc2013:LIBS += user32.lib
win32-msvc2015:LIBS += user32.lib
win32-msvc2017:LIBS += user32.lib

win32-msvc2013:QMAKE_CXXFLAGS += -ID:\\msys\\local\\include -DSUB_PROCESS_DISABLED=1 /Zi
win32-msvc2013:QMAKE_LFLAGS += /DEBUG /OPT:REF /OPT:ICF /INCREMENTAL:NO
win32-msvc2015:QMAKE_CXXFLAGS += -ID:\\msys\\local\\include -DSUB_PROCESS_DISABLED=1 /Zi
win32-msvc2015:QMAKE_LFLAGS += /DEBUG /OPT:REF /OPT:ICF /INCREMENTAL:NO
win32-msvc2015:DEFINES += _TIMESPEC_DEFINED
win32-msvc2017:QMAKE_CXXFLAGS += -ID:\\msys\\local\\include -DSUB_PROCESS_DISABLED=1 /Zi
win32-msvc2017:QMAKE_LFLAGS += /DEBUG /OPT:REF /OPT:ICF /INCREMENTAL:NO
win32-msvc2017:DEFINES += _TIMESPEC_DEFINED
