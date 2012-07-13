import os
import sys
from datetime import date

# Set these global variables
# Full path for Qt SDK libs, with '/' at the end
qt_base_dir = '/opt/local/QtSDK/Desktop/Qt/474/gcc/'
#qt_base_dir = '/opt/local/QtSDK/Desktop/Qt/4.8.1/gcc/'

# if this is set to true, the framework installed and the build tools in PATH will be used.
use_installed_framework = False
if sys.platform == 'darwin':
    use_installed_framework = True

# -------------------------------------------------------------------
# There should be no need to touch anything from here on to configure
# -------------------------------------------------------------------

today = date.today().isoformat()
build_dir = 'csoundqt-' + today

configs = 'CONFIG+=release CONFIG+=buildDoubles CONFIG+=rtmidi CONFIG+=pythonqt '
spec = '-spec max-g++ '

qmake_bin = 'qmake -r '

if not use_installed_framework:
    qmake_bin = qt_base_dir + qmake_bin

os.system('git pull origin master')
os.mkdir('../' + build_dir)
os.cd('../' + build_dir)
os.system(qmake_bin + spec + configs + ' ../csoundqt/qcs.pro')
os.system('make -w')
import ../bin/osx-package.py
