CONFIG *= thread \
    warn_on
CONFIG -= stl
QT *= xml
CONFIG(debug, debug|release):CONFIG -= release
CONFIG(release, debug|release):CONFIG -= debug
debug {
    CONFIG -= debug
    CONFIG += debug
}
release {
    CONFIG -= release
    CONFIG += release
}
warn_on {
    CONFIG -= warn_on
    CONFIG += warn_on
}
CONFIG -= lex \
    yacc
exceptions:CONFIG -= exceptions_off
rtti:CONFIG -= rtti_off
thread:CONFIG -= thread_off
!isEqual(OUT_PWD, $${PWD}):!isEqual(OUT_PWD, $${PWD}/):CONFIG *= shadow_build \
    no_fixpath
shadow_build:TMPDIR = $${OUT_PWD}
!shadow_build:TMPDIR = $${PWD}/build
build32:TMPDIR = $${TMPDIR}/floats
build64:TMPDIR = $${TMPDIR}/doubles
debug:TMPDIR = $${TMPDIR}/debug
release:TMPDIR = $${TMPDIR}/release
build64:DEFINES += USE_DOUBLE
RCC_DIR = "$${TMPDIR}/rcc"
UI_DIR = "$${TMPDIR}/ui"
INCDIR += "$${TMPDIR}/ui"
MOC_DIR = "$${TMPDIR}/moc"
OBJECTS_DIR = "$${TMPDIR}/obj"
DESTDIR = "$${PWD}/bin"
TARGET = qutecsound
build32:TARGET = $${TARGET}-f
build64:TARGET = $${TARGET}-d
pythonqt:TARGET = $${TARGET}-py
debug:TARGET = $${TARGET}-debug

DEFAULT_RTMIDI_DIRNAME="rtmidi-1.0.11"
DEFAULT_RTMIDI_DIRS = $${DEFAULT_RTMIDI_DIRNAME} \
  ../$${DEFAULT_RTMIDI_DIRNAME} \
  ../../../$${DEFAULT_RTMIDI_DIRNAME}

exists(config.user.pri) {
    include(config.user.pri)
    !no_messages:message(... config.user.pri found)
}
!no_messages {
    message()
    build32:message(Building QuteCsound for the single precision version of Csound.)
    build64:message(Building QuteCsound for the double precision version of Csound.)
    debug:message(Building debug version.)
    release:message(Building release version.)
    message()
    message(CONFIG ...)
    for(flag, CONFIG):message(+ $$flag)
    message()
    message(QuteCsound build directory is $${OUT_PWD})
    message(QuteCsound intermediate file directory is $${TMPDIR})
    message(QuteCsound bin directory is $${DESTDIR})
    message()
}
isEmpty(CSOUND_API_INCLUDE_DIR) {
    !isEmpty(CSOUND_INCLUDE_DIR):CSOUND_API_INCLUDE_DIR = $${CSOUND_INCLUDE_DIR}
    isEmpty(CSOUND_API_INCLUDE_DIR):!isEmpty(CSOUND_SOURCE_TREE):CSOUND_API_INCLUDE_DIR = $${CSOUND_SOURCE_TREE}/H
    isEmpty(CSOUND_API_INCLUDE_DIR) {
        !no_messages:message(Csound API include directory not specified.)
        for(dir, DEFAULT_CSOUND_API_INCLUDE_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}):exists($${dir}/csound.h):exists($${dir}/cwindow.h) {
                !no_messages {
                    message(CSOUND_API_INCLUDE_DIR set to $${dir})
                    message()
                }
                CSOUND_API_INCLUDE_DIR = $${dir}
                break()
            }
        }
    }
    isEmpty(CSOUND_API_INCLUDE_DIR):error(A valid Csound API include directory was not found.)
}
isEmpty(CSOUND_INTERFACES_INCLUDE_DIR) {
    !isEmpty(CSOUND_INCLUDE_DIR):CSOUND_INTERFACES_INCLUDE_DIR = $${CSOUND_INCLUDE_DIR}
    isEmpty(CSOUND_INTERFACES_INCLUDE_DIR):!isEmpty(CSOUND_SOURCE_TREE):CSOUND_INTERFACES_INCLUDE_DIR = $${CSOUND_SOURCE_TREE}/interfaces
    isEmpty(CSOUND_INTERFACES_INCLUDE_DIR) {
        !no_messages:message(Csound interfaces include directory not specified.)
        for(dir, DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}):
            exists($${dir}/csound.hpp):exists($${dir}/csPerfThread.hpp) {
                !no_messages {
                    message(CSOUND_INTERFACES_INCLUDE_DIR set to $${dir})
                    message()
                }
                CSOUND_INTERFACES_INCLUDE_DIR = $${dir}
                break()
            }
        }
    }
    isEmpty(CSOUND_INTERFACES_INCLUDE_DIR):error(A valid Csound interfaces include directory was not found.)
}
isEmpty(CSOUND_LIBRARY_DIR) {
    !isEmpty(CSOUND_SOURCE_TREE):CSOUND_LIBRARY_DIR = $${CSOUND_SOURCE_TREE}
    else {
        !no_messages:message(Csound library directory not specified.)
        for(dir, DEFAULT_CSOUND_LIBRARY_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}) {
                !no_messages:message(... in $${dir} for $${DEFAULT_CSOUND_LIBS})
                for(csound_lib, DEFAULT_CSOUND_LIBS):exists($${dir}/$${csound_lib}):exists($${dir}/$${CSND_LIB}) {
                    !no_messages {
                        message(CSOUND_LIB set to $${csound_lib})
                        message(CSOUND_LIBRARY_DIR set to $${dir})
                        message()
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
    for(csound_lib, DEFAULT_CSOUND_LIBS):exists($${CSOUND_LIBRARY_DIR}/$${csound_lib}) {
        CSOUND_LIB = $${csound_lib}
        break()
    }
    isEmpty(CSOUND_LIB):error(A valid csound library was not found.)
}
isEmpty(LIBSNDFILE_INCLUDE_DIR) {
    !no_messages:message(libsndfile include directory not specified.)
    for(dir, DEFAULT_LIBSNDFILE_INCLUDE_DIRS) {
        !no_messages:message(... searching in $${dir})
        exists($${dir}):exists($${dir}/sndfile.h) {
            !no_messages {
                message(LIBSNDFILE_INCLUDE_DIR set to $${dir})
                message()
            }
            LIBSNDFILE_INCLUDE_DIR = $${dir}
            break()
        }
    }
    isEmpty(LIBSNDFILE_INCLUDE_DIR):error(A valid libsndfile include directory was not found.)
}
isEmpty(LIBSNDFILE_LIBRARY_DIR) {
    !no_messages:message(libsndfile library directory not specified.)
    for(dir, DEFAULT_LIBSNDFILE_LIBRARY_DIRS) {
        !no_messages:message(... searching in $${dir})
        exists($${dir}):exists($${dir}/$${LIBSNDFILE_LIB}) {
            !no_messages {
                message(LIBSNDFILE_LIBRARY_DIR set to $${dir})
                message()
            }
            LIBSNDFILE_LIBRARY_DIR = $${dir}
            break()
        }
    }
    isEmpty(LIBSNDFILE_LIBRARY_DIR):error(A valid libsndfile library directory was not found.)
}
pythonqt {
    win32:isEmpty(PYTHON_INCLUDE_DIR) {
        !no_messages:message(Python include directory not specified.)
        for(dir, DEFAULT_PYTHON_INCLUDE_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}) {
                !no_messages {
                    message(PYTHON_INCLUDE_DIR set to $${dir})
                    message()
                }
                PYTHON_INCLUDE_DIR = $${dir}
                break()
            }
        }
        isEmpty(PYTHON_INCLUDE_DIR):error(A valid Python include directory was not found.)
    }
    isEmpty(PYTHONQT_TREE_DIR) {
        !no_messages:message(PythonQt library directory not specified.)
        for(dir, DEFAULT_PYTHONQT_TREE_DIRS) {
            !no_messages:message(... searching in $${dir})
            exists($${dir}) {
                !no_messages {
                    message(PYTHONQT_TREE_DIR set to $${dir})
                    message()
                }
                PYTHONQT_TREE_DIR = $${dir}
                break()
            }
        }
        isEmpty(PYTHONQT_TREE_DIR):error(A valid PythonQt library directory was not found.)
    }
}
isEmpty(RTMIDI_DIR) {
    !no_messages:message(RtMidi include directory not specified.)
    for(dir, DEFAULT_RTMIDI_DIRS) {
        !no_messages:message(... searching in $${dir})
        exists($${dir}) {
            !no_messages {
                message(RTMIDI_DIR set to $${dir})
                message()
            }
            RTMIDI_DIR = $${dir}
            DEFINES += QCS_RTMIDI
            CONFIG += rtmidi
            break()
        }
    }
}
win32 {
    CSOUND_INCLUDE_DIR = $$replace(CSOUND_INCLUDE_DIR, \\\\, /)
    CSOUND_LIBRARY_DIR = $$replace(CSOUND_LIBRARY_DIR, \\\\, /)
    LIBSNDFILE_INCLUDE_DIR = $$replace(LIBSNDFILE_INCLUDE_DIR, \\\\, /)
    LIBSNDFILE_LIBRARY_DIR = $$replace(LIBSNDFILE_LIBRARY_DIR, \\\\, /)
}
!no_messages {
    message(Csound API include directory is $${CSOUND_API_INCLUDE_DIR})
    message(Csound interfaces include directory is $${CSOUND_INTERFACES_INCLUDE_DIR})
    message(Csound library directory is $${CSOUND_LIBRARY_DIR})
    message(libsndfile include directory is $${LIBSNDFILE_INCLUDE_DIR})
    message(libsndfile library directory is $${LIBSNDFILE_LIBRARY_DIR})
    pythonqt {
        win32:message(Python include directory is $${PYTHON_INCLUDE_DIR})
        message(PythonQt source tree directory is $${PYTHONQT_TREE_DIR})
    }
    rtmidi {
        message(RtMidi directory is $${RTMIDI_DIR})
    }
    message()
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
    defineTest(libsndfileHeaderExists) {
        exists($${LIBSNDFILE_INCLUDE_DIR}/$${1}):return(true)
        return(false)
    }
    defineTest(libsndfileLibraryExists) {
        exists($${LIBSNDFILE_LIBRARY_DIR}/$${1}):return(true)
        return(false)
    }
    !directoryExists($${CSOUND_API_INCLUDE_DIR}):error(Csound API include directory not found)
    !directoryExists($${CSOUND_INTERFACES_INCLUDE_DIR}):error(Csound interfaces include directory not found)
    !directoryExists($${CSOUND_LIBRARY_DIR}):error(Csound library directory not found)
    !directoryExists($${LIBSNDFILE_INCLUDE_DIR}):error(libsndfile include directory not found)
    !directoryExists($${LIBSNDFILE_LIBRARY_DIR}):error(libsndfile library directory not found)
    pythonqt {
        win32:!directoryExists($${PYTHON_INCLUDE_DIR}):error(Python include directory not found)
        !directoryExists($${PYTHONQT_TREE_DIR}):error(PythonQt source tree directory not found)
    }
    !csoundApiHeaderExists(csound.h):error(csound.h not found)
    !csoundApiHeaderExists(csound.hpp):error(csound.hpp not found)
    !csoundApiHeaderExists(cwindow.h):error(cwindow.h not found)
    !csoundInterfacesHeaderExists(csPerfThread.hpp):error(csPerfThread.hpp not found)
    !csoundLibraryExists($${CSOUND_LIB}):error(Csound API library not found)
    !csoundLibraryExists($${CSND_LIB}):error(Csound C++ interface library not found)
    !libsndfileHeaderExists(sndfile.h):error(sndfile.h not found)
    !libsndfileLibraryExists($${LIBSNDFILE_LIB}):error(libsndfile library not found)
}
