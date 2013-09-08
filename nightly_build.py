import os
import shutil
import sys
from datetime import date

# Set these global variables
qt_base_dir = '~/Qt/5.1.1'
qcs_source_path='~/src/qutecsound'
qcs_build_prefix='~/src/'

# -------------------------------------------------------------------
# There should be no need to touch anything from here on to configure
# -------------------------------------------------------------------

today = date.today().isoformat()
build_dir = 'csoundqt-' + today

configs = 'CONFIG+=release CONFIG+=buildDoubles CONFIG+=rtmidi CONFIG+=x86_64'
#spec = '-spec max-g++ '

qmake_bin = 'qmake -r '

qmake_bin = qt_base_dir + '/' + qmake_bin

os.system('git pull origin master')
if os.path.isdir('../' + build_dir):
    shutil.rmtree('../' + build_dir)
os.mkdir('../' + build_dir)
os.chdir('../' + build_dir)
os.system(qmake_bin + configs + ' ../csoundqt/qcs.pro')
os.system('make -w -j7')
os.system(qt_base_dir + '/' + 'macdeployqt ' + 'bin/CsoundQt-d-cs6.app/')
shutil.copyfile('/usr/local/lib/libcsnd.6.0.dylib',  build_dir + '/bin/CsoundQt-d-cs6.app/Contents/Frameworks/')

os.system('tar -czvf CsoundQt-nightly-%s.tar.gz CsoundQt-d-cs6.app &>/dev/null'%today)
