import os
import shutil
import sys
from datetime import datetime, date
import subprocess
from time import sleep


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

if not subprocess.check_output('git fetch --dry-run', shell=True, stderr=subprocess.STDOUT):
    print "No changes in git. Not performing nightly build"
    f.write("No changes in git. Not performing nightly build\n")
    f.close()
    sys.exit()
else:
    os.system("git pull")

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
sleep(30)


os.system(qt_base_dir + '/clang_64/bin/' + 'macdeployqt ' + 'bin/CsoundQt-d-cs6.app/')
sleep(10)
os.chdir('bin')

os.system("install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../Frameworks/libsndfile.1.dylib CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib")

shutil.copyfile('/Library/Frameworks/CsoundLib64.framework/Versions/6.0/libcsnd.6.0.dylib',  'CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib')

os.system("install_name_tool -change CsoundLib64.framework/Versions/6.0/CsoundLib64 @executable_path/../Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib")


outname = 'CsoundQt-nightly-%s.tar.gz'%today
os.system('tar -czvf %s CsoundQt-d-cs6.app &>/dev/null'%outname)
# or: hdiutil create -format UDBZ -quiet -srcfolder YourApp.app YourAppArchive.dmg
os.system('scp -i ~/.ssh/nightly %s %s@frs.sourceforge.net:/home/frs/project/qutecsound/CsoundQt/nightly-osx'%(outname,username))

# With McCurdy Collection without CsoundLib (for release)
outname = 'CsoundQt-forrelease-%s.tar.gz'%today
os.system('rm -rf CsoundQt-d-cs6.app/Contents/Frameworks/CsoundLib64.framework')
os.system('rm -rf CsoundQt-d-cs6.app/Contents/Frameworks/libcsnd.6.0.dylib')
os.system('cp -rf ../../qutecsound/src/Examples/ CsoundQt-d-cs6.app/Contents/Resources')
os.system('tar -czvf %s CsoundQt-d-cs6.app &>/dev/null'%outname)

f.write("Done.\n")
f.close()
