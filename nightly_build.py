import os
import shutil
import sys
from datetime import datetime, date
from time import sleep
import subprocess
from subprocess import check_output

# Set these global variables
qt_base_dir = '/usr/local/opt/qt5/'
qcs_source_path='/Users/admin/src/qutecsound'
qcs_build_prefix='/Users/admin/src/'
pythonqt_dir = '../PythonQt_Orochimarufan'
#pythonqt_dir = None
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

do_build = True

if '-n' in sys.argv:
    do_build = False

if do_build:
    f.write("\nRunning Qmake\n")
    configs = 'CONFIG+=release CONFIG+=rtmidi CONFIG+=x86_64 CONFIG+=record_support CONFIG+=debugger '
    if pythonqt_dir:
        configs += 'CONFIG+=pythonqt '
        configs += 'PYTHONQT_SRC_DIR=' + pythonqt_dir + ' '
#spec = '-spec max-g++ '
    
    qmake_bin = 'qmake -r '

    qmake_bin = qt_base_dir + 'bin/' + qmake_bin

    os.system('git pull origin master')
    if os.path.isdir('../' + build_dir):
        shutil.rmtree('../' + build_dir)
    os.mkdir('../' + build_dir)
    os.chdir('../' + build_dir)
    print " ------------------- Running qmake:"
    print qmake_bin + configs + ' ' + qcs_source_path + '/qcs.pro'
    os.system(qmake_bin + configs + ' ' + qcs_source_path + '/qcs.pro')
    f.write("\nRunning make\n")
    os.system('make -w -j7')
else :
    os.chdir('../' + build_dir)
    print "skipping build."

app_name = 'CsoundQt-d%s-cs6.app'%("-py" if pythonqt_dir else "")

os.chdir('bin')

outname = 'CsoundQt-nightly-predeploy-%s.tar.gz'%today
check_output(('tar -czvf %s ' + app_name + ' &>/dev/null')%outname, shell=True)

os.mkdir(app_name + '/Contents/Frameworks')
shutil.copyfile('../' + pythonqt_dir + '/lib/libPythonQt.1.0.0.dylib',  app_name + '/Contents/Frameworks/libPythonQt.1.dylib')                                            
shutil.copyfile('../' + pythonqt_dir + '/lib/libPythonQt_QtAll.1.0.0.dylib',  app_name + '/Contents/Frameworks/libPythonQt_QtAll.1.dylib')  

print "Running deployqt utility ------"
check_output(qt_base_dir + 'bin/' + 'macdeployqt ' + app_name + ' -qmldir=' +  qcs_source_path + '/src/QML verbose=3 -always-overwrite', shell=True)

print "Adjusting symlinks ------"

#shutil.copyfile('/usr/local/lib/libcsnd6.6.0.dylib',  app_name + '/Contents/Frameworks/libcsnd6.6.0.dylib')
#if pythonqt_dir:
#    shutil.copyfile('../' + pythonqt_dir + '/lib/libPythonQt.1.0.0.dylib',  app_name + '/Contents/Frameworks/libPythonQt.1.dylib')
#    shutil.copyfile('../' + pythonqt_dir + '/lib/libPythonQt_QtAll.1.0.0.dylib',  app_name + '/Contents/Frameworks/libPythonQt_QtAll.1.dylib')

#check_output('install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../Frameworks/libsndfile.1.dylib ' + app_name + '/Contents/Frameworks/libcsnd6.6.0.dylib', shell=True)

#check_output('install_name_tool -change CsoundLib64.framework/Versions/6.0/CsoundLib64 @executable_path/../Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 ' + app_name + '/Contents/Frameworks/libcsnd6.6.0.dylib', shell=True)

if pythonqt_dir:
    check_output('install_name_tool -change libPythonQt.1.dylib @executable_path/../Frameworks/libPythonQt.1.dylib ' + app_name + '/Contents/Frameworks/libPythonQt_QtAll.1.dylib', shell=True)

    # processing PythonQt
    plugins = ["libqcocoa.dylib", "libcocoaprintersupport.dylib", "libqtaccessiblewidgets.dylib", "libqtaccessiblequick.dylib"]

    #for plugin in plugins:  
    #    shutil.copyfile(qt_base_dir + '/plugins/' + plugin,  app_name + '/Contents/Frameworks')

    modules = ['QtCore', 'QtGui', 'QtWidgets']
    for module in modules:
        check_output("install_name_tool -change " + qt_base_dir + 'lib/' + module + '.framework/Versions/5/' + module +
                     ' @executable_path/../Frameworks/' + module + '.framework/Versions/5/' + module + ' ' + app_name + "/Contents/Frameworks/libPythonQt.1.dylib", shell=True)
                                                                                                                                                           
        modules = ['QtCore', 'QtGui', 'QtWidgets', 'QtWebKitWidgets', 'QtWebKit','QtNetwork', 'QtQuick', 'QtQml', 'QtMultimediaWidgets', 'QtMultimedia', 'QtPrintSupport', 'QtOpenGL', 'QtSvg', 'QtXmlPatterns', 'QtPositioning', 'QtSensors', 'QtXml', 'QtSql']

        for module in modules:
            check_output("install_name_tool -change " + qt_base_dir + 'lib/' + module + '.framework/Versions/5/' + module +
                 ' @executable_path/../Frameworks/' + module + '.framework/Versions/5/' + module + ' ' + app_name + "/Contents/Frameworks/libPythonQt_QtAll.1.dylib", shell=True)
            #    check_output("install_name_tool -change " + qt_base_dir + 'lib/' + module + '.framework/Versions/5/' + module +
#                 ' @executable_path/../Frameworks/' + module + '.framework/Versions/5/' + module + ' ' + app_name + "/Contents/PlugIns/platforms/libqcocoa.dylib", shell=True)


# Compress packages
outname = 'CsoundQt-nightly-%s.tar.gz'%today
check_output('cp -rf ../../qutecsound/src/Examples/ ' + app_name + '/Contents/Resources', shell=True)

check_output(('tar -czvf %s ' + app_name + ' &>/dev/null')%outname, shell=True)
# or: hdiutil create -format UDBZ -quiet -srcfolder YourApp.app YourAppArchive.dmg

f.write("\nUploading.\n")
print "Uploading...."
check_output('scp -i ~/.ssh/nightly %s %s@frs.sourceforge.net:/home/frs/project/qutecsound/CsoundQt/nightly-osx'%(outname,username), shell=True)

# With McCurdy Collection without CsoundLib (for release)
outname = 'CsoundQt-forrelease-%s.tar.gz'%today
#os.system('rm -rf ' + app_name + '/Contents/Frameworks/CsoundLib64.framework')
#os.system('rm -rf ' + app_name + '/Contents/Frameworks/libcsnd6.6.0.dylib')
#check_output("install_name_tool -change @executable_path/../Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 CsoundLib64.framework/Versions/6.0/CsoundLib64 " + app_name + "/Contents/MacOS/ + app_name", shell=True)
#check_output("install_name_tool -change @executable_path/../Frameworks/libcsnd6.6.0.dylib libcsnd6.6.0.dylibCsoundLib64.framework/Versions/6.0/CsoundLib64 " + app_name + "/Contents/MacOS/" + app_name, shell=True)

os.system(('tar -czvf %s ' + app_name +' &>/dev/null')%outname)

f.write("Done.\n")
f.close()
