import os
import shutil
import sys
from datetime import datetime, date
from time import sleep
import subprocess
from subprocess import check_output

# Set these global variables
qt_base_dir = '~/Qt/5.1.1'
qcs_source_path='~/src/qutecsound'
qcs_build_prefix='~/src/'
username = 'mantaraya36'

# -------------------------------------------------------------------
# There should be no need to touch anything from here on to configure
# -------------------------------------------------------------------
today = date.today().isoformat()
build_dir = 'csoundqt-' + today

f = open("log_nightly.txt", "a")
f.write("\n" + datetime.today().ctime() + "\n")

if not check_output('git fetch --dry-run', shell=True, stderr=subprocess.STDOUT):
    if '-f' in sys.argv:
        print "No changes in git, but forcing build"
        os.system("git pull")
    else:
        print "No changes in git. Not performing nightly build"
        f.write("No changes in git. Not performing nightly build\n")
        f.close()
        sys.exit()

else:
    os.system("git pull")

f.write("\nRunning Qmake\n")
configs = 'CONFIG+=release CONFIG+=buildDoubles CONFIG+=rtmidi CONFIG+=csound6 CONFIG+=x86_64'
#configs += 'CONFIG+=pythonqt '
#configs += 'PYTHONQT_SRC_DIR=../PythonQt2.1_Qt4.8'
#spec = '-spec max-g++ '

qmake_bin = 'qmake -r '

qmake_bin = qt_base_dir + '/clang_64/bin/' + qmake_bin

os.system('git pull origin master')
if os.path.isdir('../' + build_dir):
    shutil.rmtree('../' + build_dir)
os.mkdir('../' + build_dir)
os.chdir('../' + build_dir)
os.system(qmake_bin + configs + ' ' + qcs_source_path + '/qcs.pro')
f.write("\nRunning make\n")
os.system('make -w -j7')

check_output(qt_base_dir + '/clang_64/bin/' + 'macdeployqt ' + 'bin/CsoundQt-d-cs6.app/', shell=True)
os.chdir('bin')

check_output("install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../Frameworks/libsndfile.1.dylib CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib", shell=True)

shutil.copyfile('/Library/Frameworks/CsoundLib64.framework/Versions/6.0/libcsnd.6.0.dylib',  'CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib')

check_output("install_name_tool -change CsoundLib64.framework/Versions/6.0/CsoundLib64 @executable_path/../Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib", shell=True)


outname = 'CsoundQt-nightly-%s.tar.gz'%today
check_output('tar -czvf %s CsoundQt-d-cs6.app &>/dev/null'%outname, shell=True)
# or: hdiutil create -format UDBZ -quiet -srcfolder YourApp.app YourAppArchive.dmg

f.write("\nUploading.\n")
check_output('scp -i ~/.ssh/nightly %s %s@frs.sourceforge.net:/home/frs/project/qutecsound/CsoundQt/nightly-osx'%(outname,username), shell=True)

# With McCurdy Collection without CsoundLib (for release)
outname = 'CsoundQt-forrelease-%s.tar.gz'%today
os.system('rm -rf CsoundQt-d-cs6.app/Contents/Frameworks/CsoundLib64.framework')
os.system('rm -rf CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib')
os.system('cp -rf ../../qutecsound/src/Examples/ CsoundQt-d-cs6.app/Contents/Resources')
os.system('tar -czvf %s CsoundQt-d-cs6.app &>/dev/null'%outname)

f.write("Done.\n")
f.close()
