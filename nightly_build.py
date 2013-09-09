import os
import shutil
import sys
from datetime import date

# Set these global variables
qt_base_dir = '~/Qt/5.1.1'
qcs_source_path='~/Documents/src/qutecsound'
qcs_build_prefix='~/src/'

# -------------------------------------------------------------------
# There should be no need to touch anything from here on to configure
# -------------------------------------------------------------------

today = date.today().isoformat()
build_dir = 'csoundqt-' + today

configs = 'CONFIG+=release CONFIG+=buildDoubles CONFIG+=rtmidi CONFIG+=csound6 CONFIG+=x86_64'
#spec = '-spec max-g++ '

qmake_bin = 'qmake -r '

qmake_bin = qt_base_dir + '/clang_64/bin/' + qmake_bin

os.system('git pull origin master')
if os.path.isdir('../' + build_dir):
    shutil.rmtree('../' + build_dir)
os.mkdir('../' + build_dir)
os.chdir('../' + build_dir)
os.system(qmake_bin + configs + ' ' + qcs_source_path + '/qcs.pro')
os.system('make -w -j7')
os.system(qt_base_dir + '/clang_64/bin/' + 'macdeployqt ' + 'bin/CsoundQt-d-cs6.app/')

shutil.copyfile('/Library/Frameworks/CsoundLib64.framework/Versions/6.0/libcsnd.6.0.dylib',  'bin/CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib')

os.system("install_name_tool -change /usr/local/lib/libsndfile.1.dylib bin/CsoundQt-d-cs6.app/Contents/Frameworks/libsndfile.1.dylib bin/CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib")

os.system("install_name_tool -change CsoundLib64.framework/Versions/6.0/CsoundLib64 bin/CsoundQt-d-cs6.app/Contents/Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 bin/CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib")

os.chdir('bin')
os.system('tar -czvf CsoundQt-nightly-%s.tar.gz CsoundQt-d-cs6.app &>/dev/null'%today)

