

## Dependencies

1) Install MSVC 2019 (community) -  Csound 6.18 is built with that


2) Install Qt5 (5.15.2)

3) Install Git,  https://git-scm.com/download/win
libsndfile (Mega-Nerd) http://www.mega-nerd.com/libsndfile/

4) Csound https://csound.com/download.html 

* installing just binaries does not work -  missing csPerfThread, version.h.in needs replacement

copy include and lib directories to CsoundQt/../csound/

5) pthread https://sourceforge.net/projects/pthreads4w/files/ unpack to  to CsoundQt/../csound/



## Prepratation

1) Configure QtCreator for git (Version Control -> Git, Command C:\Program Files\Git\bin\git.exe)

2) get/update CsoundQt sources (QtCreator Import project -> Git -> https://github.com/CsoundQt/CsoundQt.git

* Pull with submodules (recursive) ti build with rtmidi support.

3) copy Csound header files and libraries to a directory without spaces,  for example next to CsoundQt source folder.




## Configuration

Create  `config.user.pri`  in CsoundQt source root directory and enter following lines:

With content like:

```
CONFIG *= rtmidi
CONFIG *= perfThread_build
#CONFIG +=record_support # crash on Windows 11...
CONFIG+=html_webengine

CSOUND_INTERFACES_INCLUDE_DIR = $$PWD/../csound/include/csound
DEFAULT_CSOUND_API_INCLUDE_DIRS = $$PWD/../csound/include/csound
DEFAULT_CSOUND_LIBRARY_DIRS = $$PWD/../csound/lib

DEFAULT_LIBSNDFILE_INCLUDE_DIRS = "C:\Program Files\Mega-Nerd\libsndfile\include"
DEFAULT_LIBSNDFILE_LIBRARY_DIRS = "C:\Program Files\Mega-Nerd\libsndfile\bin"

PTHREAD_INCLUDE_DIR = $$PWD/../pthreads/Pre-built.2/include
LPTHREAD = $$PWD/../pthreads/Pre-built.2/lib/x64/pthreadVC2.lib

```

## Build, install

Build with QtCreator.
You might need to copy libsndfile-1.dll to the build's bin dir.
If succeeded, add build step: intall (make install), that runs qtwindeploy that pulls necessary Qt libraries to the build/bin directory
Copy Examples folder to build/bin dir.
To include also Csound, copy the following from Csound installation directory:
- Csound6_x64/doc -> bin/doc
- Csound6_x64/bin/* -> bin (next to CsoundQt executable
- Csound6_x64/plugins64/  -> bin

