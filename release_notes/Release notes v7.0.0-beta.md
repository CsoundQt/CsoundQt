# CsoundQt 7.0.0-beta1 Release Notes

<br>

*<small>Written by Github Copilit Agent. Edited by Tarmo Johannes</small>*


**CsoundQt 7.0.0-beta1** represents a major milestone in the evolution of CsoundQt. This release introduces significant modernization efforts, full compatibility with Csound 7, and a complete migration to Qt 6, providing a more robust and future-ready foundation for the IDE.

The source and upcoming binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/v7.0.0-beta1>.

<br>

## Major Platform and Dependency Updates

### Qt 6 Migration
* **Complete migration to Qt 6**: CsoundQt7 now requires Qt 6 (tested with Qt 6.5) for improved performance and modern platform support
* **Forced Fusion style on Windows**: Ensures consistent appearance across platforms
* **Better macOS integration**: Removed deprecated MySlider for macOS as no longer needed


### Csound 7 Support
* **Full Csound 7 compatibility**: Updated all APIs and dependencies for Csound 7. Tested against Csound7-beta9.
* **Local copy of csound_threaded.hpp**: Maintains compatibility for HTML wrapper functionality
* **OPCODE7DIR64 environment variable**: Uses Csound 7's plugin directory structure, dropping support for older OPCODEDIR variables

<br>

## New Features and User Interface Improvements

### Dark Theme and Color System
* **Comprehensive dark theme support**: All components including console, widgets, table editors, and virtual keyboard properly support dark mode
* **Dynamic theme switching**: Users can now switch between light and dark themes at runtime from the View menu (does not work well on Windows)
* **Automatic theme detection**: CsoundQt can automatically follow the system's dark/light theme preference
* **Theme-aware icons**: Updated icon system with automatic color inversion for dark themes


### Examples
*	**Renewed CsoundQt examples** : Reorganized, updated, improved
*  **Csound 7 examples**: Special examples about new features in Csound 7
*  **UI Fixes**: All spinboxes updated to use background (to work with dark theme), added compulsory channel to buttons that missed it
*  **New Audio/MIDI tests**:  As first entry in Examples

### Enhanced Table Editor
* **GEN7 table editor improvements**: Better visual representation with theme-aware colors
* **Freehand table editing**: New capability for manual table curve drawing, entered as GEN02 table
* **GEN10 editor**: Ability to make a GEN10 waveform controlling the relative strength of harmonics via sliders and visual representation on the UI. 


### Split View and Score Editing Enhancements
* **Font size zooming**: Added Ctrl/Cmd + Plus/Minus zoom functionality for editor, console, and score view
* **Score column naming**: Automatic extraction and display of column names from score headers (the first line should be comment withe headers of the p-fields like:   
`; instr | start | dur | amp | freq | etc` 
* **Improved highlighting**: Fixed syntax highlighting in split view for orchestra and score sections, multiline strings and comments within multiline comments

### Word Completion and Editor Features
* **Enhanced autocomplete**: Now works with any words in the document (instrument names, macros, etc.), not just keywords
* **Better word boundary detection**: Improved completion for text within quotes and parentheses 

### HTML and Web Integration
* **Qt-based HTML support**:  Dropped WebKit support, use QWebEngine (Chromium based).  Build configuration for qmake:    
`CONFIG+=html_support`
* **Improved HTML examples**: Cleaned up and modernized HTML interface examples
* **Local content access**: Better handling of local file access for HTML interfaces


### Improved Virtual MIDI Keyboard
* **Enhanced MIDI keyboard**: Better layout with editable spinboxes for MIDI parameters
* **Improved virtual keyboard**: Fixed color themes and interaction handling

## Core Infrastructure and Code Quality

### Modernization and Cleanup
* **Comprehensive renaming**: Migrated from 'qutecsound' to 'csoundqt' throughout the codebase
* **Updated macro system**: Changed from QCS_* to CSQT_* prefixes for better namespace management
* **Settings reorganization**: Now uses QSettings("csoundqt", "csoundqt") with config in ~/.config/csoundqt/
* **Code analysis fixes**: Addressed numerous warnings and code quality issues
* **Removed deprecated code**: Cleaned up legacy code paths and unused functions

### Removed Features
* **PythonQt support dropped**: Simplified the build system and reduced dependencies
* **Live Event Sheets removed**: Functionality replaced by live code evaluation and Scratch Pad


### Build System and Distribution
* **Iniated CMake support**: Not ready yet. Use qmake build system  (qcs.pro) for now
* **Updated packaging**: Cleaned up binary distribution and moved installer-related files
* **Code signing improvements**: Enhanced macOS code signing process


## Bug Fixes and Stability Improvements

### Error Handling and Messages
* **Better error reporting**: Improved error message display and formatting
* **Fixed console overflow**: Eliminated duplicate messages when compilation fails
* **Crash fixes**: Resolved crashes in QuteGraph, table editors, and HTML stopping
* **Memory leak fixes**: Fixed memory allocation issues in opcode parsing

### Widget and Interface Fixes
* **Spinbox locale protection**: Fixed issues with Chinese numerals in spinboxes
* **Button channel validation**: Added warnings for buttons without channel names
* **Fixed widget value handling**: Improved communication between widgets and Csound
* **HTML file handling**: Better temporary file management for non-writable locations

### Platform-specific Fixes
* **Windows stability**: Improved reliability on Windows platforms
* **macOS compatibility**: Fixed various macOS-specific issues including file paths and permissions
* **Linux AppImage**: Corrected relative paths for AppImage distribution

## Documentation and Examples

New online documentation: https://csoundqt.github.io/doc/ 


## Breaking Changes and Migration Notes

### For Users
* **Qt 6 requirement**: CsoundQt7 depends on Qt 6 (included in installation bundles)
* **Csound 7 requirement**: Csound 6 is no longer supported
* **Configuration migration**: Settings will need to be reconfigured due to new settings location
* **Plugin paths**: Update OPCODE7DIR64 environment variable instead of older OPCODEDIR variables

### For Developers
* **Build system changes**: Updated build requirements and dependencies
* **API changes**: Significant internal API modernization
* **Code style updates**: Modernized C++ practices and Qt 6 patterns

## Known Issues and Limitations

* CMake build support is still in development
* Some legacy features may have changed behavior due to modernization
* Plugin compatibility should be verified with Csound 7

## Acknowledgments

Special thanks to all contributors including Tarmo Johannes, Joachim Heintz, Eduardo Moguillansky, Gleb Rogozinksi. Thanks go to everybody who issued bug reports, asked questions or gave comments!

---

**Note**: This is a beta release intended for testing and feedback. Please report any issues on the [CsoundQt GitHub repository](https://github.com/CsoundQt/CsoundQt/issues).

Tarmo Johannes  
Project Maintainer