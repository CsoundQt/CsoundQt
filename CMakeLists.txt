cmake_minimum_required(VERSION 3.5)

project(CsoundQt VERSION 0.1 LANGUAGES CXX)

option(CSQT_BUILD_DEBUGGER_SUPPORT "Build Debugger Support" OFF)
option(CSQT_BUILD_RECORDING_SUPPORT "Build recording support" ON)

# for user defined options: rename Custom.cmake.ex to Custom.cmake
# uncomment neccessary variable and make changes according to your system
find_file(CUSTOM_CMAKE "Custom.cmake" HINTS ${CMAKE_HOME_DIRECTORY})
if(CUSTOM_CMAKE)
    message(STATUS "Including Custom.cmake file: ${CUSTOM_CMAKE}")
    include(${CUSTOM_CMAKE})
else()
    message(STATUS "Not using Custom.cmake file.")
endif()


# TODOs
# * Build for Windows
# * Build for MacOS
# * Package for MacOS
# * Package for Windows?
# * Linux installation
# * Transaltions
# * HTML version

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets Concurrent Network PrintSupport QuickWidgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Concurrent Network Xml PrintSupport QuickWidgets LinguistTools)

# Validate Qt version
if(QT_VERSION_MAJOR EQUAL 5)
  if(QT_VERSION_MINOR LESS_EQUAL 8)
    message(FATAL_ERROR "Only QT version > 5.8 is supported")
  endif(QT_VERSION_MINOR LESS_EQUAL 8)
else()
  message(FATAL_ERROR "Only Qt5 is currently supported")
endif(QT_VERSION_MAJOR EQUAL 5)

set(PROJECT_SOURCES
  # Resources
  "src/application.qrc"
  "src/pythonscripts.qrc"
  "src/icons.qrc"
  "src/qml_resources.qrc"

  # Forms
  "src/about.ui"
  "src/configdialog.ui"
  "src/findreplace.ui"
  "src/keyboardshortcuts.ui"
  "src/keyselector.ui"
  "src/liveeventcontrol.ui"
  "src/liveeventframe.ui"
  "src/utilitiesdialog.ui"
  "src/appdetailspage.ui"
  "src/pluginspage.ui"
  "src/additionalfilespage.ui"
  "src/filebeditor.ui"
  src/midilearndialog.ui
  src/debugpanel.ui
  src/dockhelp.ui
  src/livecodeeditor.ui
  src/newbreakpointdialog.ui
  src/html5guidisplay.ui

  # Headers
  "src/about.h"
  "src/configdialog.h"
  "src/configlists.h"
  "src/console.h"
  "src/csoundengine.h"
  "src/csoundoptions.h"
  "src/curve.h"
  "src/dockhelp.h"
  "src/documentpage.h"
  "src/documentview.h"
  "src/dotgenerator.h"
  "src/eventsheet.h"
  "src/findreplace.h"
  "src/framewidget.h"
  "src/graphicwindow.h"
  "src/highlighter.h"
  "src/inspector.h"
  "src/keyboardshortcuts.h"
  "src/liveeventcontrol.h"
  "src/liveeventframe.h"
  "src/node.h"
  "src/opentryparser.h"
  "src/options.h"
  "src/qutebutton.h"
  "src/qutecheckbox.h"
  "src/qutecombobox.h"
  "src/quteconsole.h"
  "src/qutecsound.h"
  "src/qutedummy.h"
  "src/qutegraph.h"
  "src/quteknob.h"
  "src/qutemeter.h"
  "src/qutescope.h"
  "src/quteslider.h"
  "src/qutespinbox.h"
  "src/qutetext.h"
  "src/qutewidget.h"
  "src/texteditor.h"
  "src/types.h"
  "src/utilitiesdialog.h"
  "src/widgetlayout.h"
  "src/widgetpanel.h"
  "src/widgetpreset.h"
  "src/qutesheet.h"
  "src/basedocument.h"
  "src/baseview.h"
  "src/appwizard.h"
  "src/appdetailspage.h"
  "src/pluginspage.h"
  "src/additionalfilespage.h"
  "src/scoreeditor.h"
  "src/filebeditor.h"
  "src/myslider.h"
  "src/risset.h"
  "src/selectcolorbutton.h"
  "src/midihandler.h"
  "src/midilearndialog.h"
  "src/debugpanel.h"
  "src/livecodeeditor.h"
  "src/newbreakpointdialog.h"
  #src/CsoundHtmlOnlyWrapper.h

  # Sources
  "src/about.cpp"
  "src/configdialog.cpp"
  "src/configlists.cpp"
  "src/console.cpp"
  "src/csoundengine.cpp"
  "src/csoundoptions.cpp"
  "src/curve.cpp"
  "src/dockhelp.cpp"
  "src/documentpage.cpp"
  "src/documentview.cpp"
  "src/dotgenerator.cpp"
  "src/eventsheet.cpp"
  "src/findreplace.cpp"
  "src/framewidget.cpp"
  "src/graphicwindow.cpp"
  "src/highlighter.cpp"
  "src/inspector.cpp"
  "src/keyboardshortcuts.cpp"
  "src/liveeventcontrol.cpp"
  "src/liveeventframe.cpp"
  "src/main.cpp"
  "src/node.cpp"
  "src/opentryparser.cpp"
  "src/options.cpp"
  "src/qutebutton.cpp"
  "src/qutecheckbox.cpp"
  "src/qutecombobox.cpp"
  "src/quteconsole.cpp"
  "src/qutecsound.cpp"
  "src/qutedummy.cpp"
  "src/qutegraph.cpp"
  "src/quteknob.cpp"
  "src/qutemeter.cpp"
  "src/qutescope.cpp"
  "src/quteslider.cpp"
  "src/qutespinbox.cpp"
  "src/qutetext.cpp"
  "src/qutewidget.cpp"
  "src/texteditor.cpp"
  "src/utilitiesdialog.cpp"
  "src/widgetlayout.cpp"
  "src/widgetpanel.cpp"
  "src/widgetpreset.cpp"
  "src/qutesheet.cpp"
  "src/basedocument.cpp"
  "src/baseview.cpp"
  "src/appwizard.cpp"
  "src/appdetailspage.cpp"
  "src/pluginspage.cpp"
  "src/additionalfilespage.cpp"
  "src/scoreeditor.cpp"
  "src/filebeditor.cpp"
  "src/risset.cpp"
  "src/selectcolorbutton.cpp"
  "src/midihandler.cpp"
  "src/midilearndialog.cpp"
  "src/debugpanel.cpp"
  "src/livecodeeditor.cpp"
  "src/newbreakpointdialog.cpp"
  #src/csoundhtmlview.cpp
  #src/CsoundHtmlOnlyWrapper.cpp
)

set(TS_FILES "src/translations/qutecsound_en.ts"
  "src/translations/qutecsound_es.ts"
  "src/translations/qutecsound_de.ts"
  "src/translations/qutecsound_pt.ts"
  "src/translations/qutecsound_fr.ts"
  "src/translations/qutecsound_it.ts"
  "src/translations/qutecsound_tr.ts"
  "src/translations/qutecsound_el.ts"
  "src/translations/qutecsound_uk.ts"
  "src/translations/qutecsound_fi.ts"
  "src/translations/qutecsound_ru.ts"
  "src/translations/qutecsound_fa.ts"
  "src/translations/qutecsound_kr.ts"
)

set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/translations")

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(CsoundQt
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET CsoundQt APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(CsoundQt SHARED
            ${PROJECT_SOURCES}
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(CsoundQt
            ${PROJECT_SOURCES}
        )
    endif()
endif()

target_link_libraries(CsoundQt PRIVATE
  Qt${QT_VERSION_MAJOR}::Widgets
  # Qt${QT_VERSION_MAJOR}::Concurrent
  Qt${QT_VERSION_MAJOR}::Network
  Qt${QT_VERSION_MAJOR}::Xml
  Qt${QT_VERSION_MAJOR}::PrintSupport
  Qt${QT_VERSION_MAJOR}::QuickWidgets
)

if(CSQT_BUILD_DEBUGGER_SUPPORT)
  target_compile_definitions(CsoundQt PRIVATE QCS_DEBUGGER)
  message("Building debugger support.")
endif(CSQT_BUILD_DEBUGGER_SUPPORT)

if(CSQT_BUILD_RECORDING_SUPPORT)
  target_compile_definitions(CsoundQt PRIVATE PERFTHREAD_RECORD)
  message("Building recording support.")
endif(CSQT_BUILD_RECORDING_SUPPORT)


# LINUX definition
if(CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(LINUX YES)
    message(STATUS "LINUX operating system found")
else()
    set(LINUX NO)
endif()

#link to Csound
if (WIN32)
# win32-msvc:build64: DEFAULT_CSOUND_LIBS = csound64.lib
# win32-g++:build64: DEFAULT_CSOUND_LIBS = csound64.dll
# DEFAULT_CSOUND_API_INCLUDE_DIRS = "$$(PROGRAMFILES)\\Csound6\\include\\csound"
# DEFAULT_CSOUND_INTERFACES_INCLUDE_DIRS = $${DEFAULT_CSOUND_API_INCLUDE_DIRS}
# DEFAULT_CSOUND_LIBRARY_DIRS = "$$(PROGRAMFILES)\\Csound6\\bin"
# LCSOUND = "$${CSOUND_LIBRARY_DIR}/$${CSOUND_LIB}"
# win32-g++:csound6: LCSND = "$${CSOUND_LIBRARY_DIR}/csnd6.dll"
elseif(APPLE)

  #LCSOUND = -F$${HOME_DIRECTORY}/Library/Frameworks -F/Library/Frameworks -F/usr/local/opt/csound/Frameworks -F/opt/homebrew/opt/csound/Frameworks -framework $${MAC_LIB}


elseif(LINUX)
  find_library(CSOUND_LIBRARY csound64
    PATHS /usr/local/lib
          /usr/lib
    REQUIRED)
  find_library(CSND6_LIBRARY csnd6
    PATHS /usr/local/lib
          /usr/lib
    REQUIRED)

  #? how to add custom user defined paths from Custom.cmake ?
  set(CSOUND_INCLUDE_PATHS /usr/local/include/csound
              /usr/include/csound
  )

  message("Using csound: ${CSOUND_LIBRARY} ${CSND6_LIBRARY}")

  target_link_libraries(CsoundQt PRIVATE ${CSOUND_LIBRARY} ${CSND6_LIBRARY})
  target_include_directories(CsoundQt PRIVATE ${CSOUND_INCLUDE_PATHS})

else()
  message(FATAL_ERROR "Unsupported platform")
endif()



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.csound.CsoundQt)
endif()

set_target_properties(CsoundQt PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

if(QT_VERSION_MAJOR EQUAL 5)
  target_compile_definitions(CsoundQt PRIVATE
    USE_QT_GT_53 USE_QT_GT_54 USE_QT_GT_55 USE_QT_GT_58)
  #FIXME translations don't appear to be working right now?
  qt5_add_translation(CsoundQt ${TS_FILES})

else()
  # TODO complete when adding support for Qt 6
endif(QT_VERSION_MAJOR EQUAL 5)

include(GNUInstallDirs)
install(TARGETS CsoundQt
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(CsoundQt)
endif()
