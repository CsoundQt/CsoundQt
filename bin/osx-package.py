from subprocess import call
import shutil
import os
import pdb
import fileinput
import glob 

# Build everything just to make sure all versions packaged are synchronized
#cd ..
#qmake qcs.pro CONFIG+=rtmidi -spec macx-g++ -r CONFIG+=release
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=build64 -spec macx-g++ -r CONFIG+=release
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=pythonqt PYTHONQT_TREE_DIR=../../../pythonqt/trunk
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=build64 CONFIG+=pythonqt PYTHONQT_TREE_DIR=../../../pythonqt/trunk
#make
#cd bin

#lipo ${ORIGINAL_NAME}.app/Contents/MacOS/${ORIGINAL_NAME} ${ORIGINAL_NAME_D}.app/Contents/MacOS/${ORIGINAL_NAME_D} -create --output ${ORIGINAL_NAME}.app/Contents/MacOS/qutecsound


def change_link(link,new_link, bin_file):
    arguments = ['-change',  link, new_link, bin_file]
    retcode = call(['install_name_tool'] + arguments)
    if retcode != 0:
        print "Failed ---------"
    print "changed link:", link, "to", new_link, 'in', bin_file, 'ret:', retcode

def change_id(new_id, file_name):
    arguments = ['-id',  new_id, file_name]
    retcode = call(['install_name_tool'] + arguments)
    print "changed id:", new_id, 'in', file_name, 'ret:', retcode

def adjust_link(old_link, new_link, app_name, bin_name, suffix = '64'):

    change_id(new_link, app_name + '/Contents/Frameworks/' + new_link[new_link.rindex('/') + 1:])
    change_link(old_link, new_link, app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix, suffix))
    change_link(old_link, new_link, app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix)

def deployWithPython(PRECISION, NEW_NAME, QUTECSOUND_VERSION, QtFrameworksDir, CsoundQtBinPath, PythonQtLibPaths, debug=False):
    ORIGINAL_NAME = 'CsoundQt' + PRECISION + '-py'
    if debug:
        ORIGINAL_NAME += '-debug'
    APP_NAME= NEW_NAME + PRECISION + '-py-' + QUTECSOUND_VERSION + '.app'

    ORIG_APP_NAME=ORIGINAL_NAME + '.app'
    # if (os.path.exists(ORIG_APP_NAME)):
    #     shutil.rmtree(ORIG_APP_NAME)
    #shutil.copytree(CsoundQtBinPath + '/' + ORIG_APP_NAME, ORIG_APP_NAME)
    #print "Copied ",CsoundQtBinPath + '/' + ORIG_APP_NAME

    arguments = [ORIG_APP_NAME, '-verbose=1']
    retcode = call([QtBinDir + '/macdeployqt'] + arguments)

    add_path = False

    for line in fileinput.input( CsoundQtBinPath + '/' + ORIG_APP_NAME+ '/Contents/Info.plist', inplace=1):
        if line.strip().startswith('<string>????</string>'):
            add_path = True
        else:
            if add_path:
                print '''    <key>LSEnvironment</key>
    <array>
    <dict>
      <key>PATH</key>
      <string>/usr/local/bin</string>
    </dict>
    </array>'''
            add_path = False
        print line,
    
    if os.path.exists('../src/res/osx/QuteApp_f.app'):
        shutil.copytree('../src/res/osx/QuteApp_f.app', ORIG_APP_NAME + '/Contents/Resources/QuteApp_f.app', symlinks=True)
    if os.path.exists('../src/res/osx/QuteApp_d.app'):
        shutil.copytree('../src/res/osx/QuteApp_d.app', ORIG_APP_NAME + '/Contents/Resources/QuteApp_d.app', symlinks=True)
    # os.mkdir(APP_NAME + '/Contents/Resources')
    shutil.copytree(
        '../src/Examples/McCurdy Collection', ORIG_APP_NAME + '/Contents/Resources/McCurdy Collection')
    shutil.copytree(
        '../src/Scripts', ORIG_APP_NAME + '/Contents/Resources/Scripts')
    
    #chmod -R a-w $APP_NAME/Contents/Resources
    #pdb.set_trace()

    #os.mkdir(ORIG_APP_NAME+ '/Contents/Frameworks')
    # PythonQt is not copied by macdeployqt so copy it manually
    PythonQtPath = ''
    for path in PythonQtLibPaths:
        if os.path.exists(path + 'libPythonQt.1.0.0.dylib'):
            PythonQtPath = path
            break
    if PythonQtPath == '':
        print "Can't find libPythonQt. Exiting."
        return
    print "Using PythonQtPath: " + PythonQtPath 
    shutil.copy(PythonQtPath + 'libPythonQt.1.0.0.dylib', ORIG_APP_NAME + '/Contents/Frameworks/libPythonQt.1.dylib')
    shutil.copy(PythonQtPath + 'libPythonQt_QtAll.1.0.0.dylib', ORIG_APP_NAME + '/Contents/Frameworks/libPythonQt_QtAll.1.dylib')
    arguments = ['-id',  '@executable_path/../Frameworks/libPythonQt.1.dylib',
                 '%s/Contents/Frameworks/libPythonQt.1.dylib'%(ORIG_APP_NAME)]
    retcode = call(['install_name_tool'] + arguments)
    arguments = ['-id',  '@executable_path/../Frameworks/libPythonQt_QtAll.1.dylib',
                 '%s/Contents/Frameworks/libPythonQt_QtAll.1.dylib'%(ORIG_APP_NAME)]
    retcode = call(['install_name_tool'] + arguments)


    change_link('libPythonQt.1.dylib',
            '@executable_path/../Frameworks/libPythonQt.1.dylib',
            '%s/Contents/MacOs/%s'%(ORIG_APP_NAME, ORIGINAL_NAME))
    change_link('libPythonQt.1.dylib',
            '@executable_path/../Frameworks/libPythonQt.1.dylib',
            '%s/Contents/Frameworks/libPythonQt_QtAll.1.dylib'%(ORIG_APP_NAME))
    change_link('libPythonQt_QtAll.1.dylib',
            '@executable_path/../Frameworks/libPythonQt_QtAll.1.dylib',
            '%s/Contents/MacOS/%s'%(ORIG_APP_NAME, ORIGINAL_NAME))

    change_link('libsndfile.1.dylib',
                 '@executable_path/../Frameworks/libsndfile.1.dylib',
                 '%s/Contents/MacOS/%s'%(ORIG_APP_NAME, ORIGINAL_NAME))

        #deployCsound(ORIG_APP_NAME , '%s/Contents/MacOS/%s'%(ORIG_APP_NAME, ORIGINAL_NAME), PRECISION == '-d')

    #QtLibs = ['QtCore', 'QtGui', 'QtXml', 'QtSvg', 'QtSql', 'QtXmlPatterns', 'QtOpenGL', 'QtNetwork', 'QtWebKit', 'phonon']
    #QtDepLibs = ['QtGui', 'QtXml', 'QtSvg', 'QtSql', 'QtXmlPatterns', 'QtOpenGL', 'QtNetwork', 'QtWebKit', 'phonon']
    #deployQtLibs(ORIG_APP_NAME, ORIGINAL_NAME, QtLibs, QtDepLibs)

    # Now fix dependencies for copied libs
    QtLibs = ['QtCore', 'QtGui', 'QtXml', 'QtDBus', 'QtSvg', 'QtSql', 'QtXmlPatterns', 'QtOpenGL', 'QtNetwork', 'QtWebKit', 'phonon']

    for lib in QtLibs:
        change_link('%s/gcc/lib/%s.framework/Versions/4/%s'%(QtFrameworksDir,lib,lib),
                     '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib,lib),
                     '%s/Contents/Frameworks/libPythonQt.1.dylib'%(ORIG_APP_NAME))
        change_link('%s.framework/Versions/4/%s'%(lib,lib),
                     '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib,lib),
                     '%s/Contents/Frameworks/libPythonQt_QtAll.1.dylib'%(ORIG_APP_NAME))
        change_link('%s.framework/Versions/4/%s'%(lib,lib),
                     '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib,lib),
                     '%s/Contents/Frameworks/libPythonQt.1.dylib'%(ORIG_APP_NAME))
        change_link('%s/gcc/lib/%s.framework/Versions/4/%s'%(QtFrameworksDir,lib,lib),
                     '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib,lib),
                     '%s/Contents/Frameworks/libPythonQt_QtAll.1.dylib'%(ORIG_APP_NAME))

    
    if (os.path.exists(APP_NAME)):
        shutil.rmtree(APP_NAME)
    os.rename(ORIG_APP_NAME, APP_NAME)
    #rm $APP_NAME/Contents/Info.plist
    #cp ../src/MyInfo.plist $APP_NAME/Contents/Info.plist
    
    retcode = call(['tar', '-czvf', '%s%s-%s.tar.gz'%(NEW_NAME,PRECISION,QUTECSOUND_VERSION), APP_NAME])
    
def deployCsound(app_name, bin_name, doubles=True):
    suffix = '64' if doubles else ''
    cs_framework = '/Library/Frameworks/CsoundLib%s.framework'%suffix
    try:
        shutil.copytree(cs_framework, app_name + '/Contents/Frameworks/CsoundLib%s.framework'%suffix, symlinks=True )
    except Exception:
        print "Warning: Csound Framework not copied"
        pass
    
    libs = { 'libsndfile.1.dylib': 'libsndfile.1.dylib',
             'libportaudio.2.dylib': 'libportaudio.dylib',
             'libportmidi.dylib': 'libportmidi.dylib',
             #'libmpadec.dylib': 'libmpadec.dylib',
             'liblo.0.dylib' : 'liblo.dylib',
             'libfltk.1.3.dylib' : 'libfltk.dylib',
             'libfltk_images.1.3.dylib' : 'libfltk_images.dylib',
             'libfluidsynth.1.dylib' : 'libfluidsynth.dylib',
             'libpng12.0.dylib' : 'libpng12.dylib',
             'libfluidsynth.1.dylib' : 'libfluidsynth.dylib'}

    lib_dir = '/usr/local/lib/'
    for lib, dest_lib in libs.items():
        shutil.copy(lib_dir + lib, app_name + '/Contents/Frameworks/' + dest_lib )
        adjust_link('/usr/local/lib/' + lib , '@executable_path/../Frameworks/' + dest_lib, app_name, bin_name, suffix)
    
    change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            bin_name)
    change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix,
            '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix,
            bin_name)
    change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
            app_name + '/Contents/Frameworks/CsoundLib%s.framework/Versions/5.2/lib_csnd.dylib'%suffix)
                
    
    change_link('/usr/local/lib/libfltk.1.3.dylib',
            '@executable_path/../libfltk.dylib',
            app_name + '/Contents/Frameworks/libfltk_images.dylib')
    change_link('/usr/local/lib/libpng12.0.dylib',
            '@executable_path/../libpng12.dylib',
            app_name + '/Contents/Frameworks/libfltk_images.dylib')

    opcode_dir = app_name +'/Contents/Frameworks/CsoundLib%s.framework/Resources/Opcodes%s'%(suffix,suffix)
    opcode_libs = glob.glob(opcode_dir + '/*.dylib')
    
    for op_lib in opcode_libs:
        for dep_lib, dep_dest_lib in libs.items():
            change_link('/usr/local/lib/' + dep_lib , '@executable_path/../Frameworks/' + dep_dest_lib,
                    op_lib)
            change_link('/usr/local/lib/' + dep_lib , '@executable_path/../Frameworks/' + dep_dest_lib,
                    op_lib)
            change_link('/Library/Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
                    '@executable_path/../Frameworks/CsoundLib%s.framework/Versions/5.2/CsoundLib%s'%(suffix,suffix),
                    op_lib)

if __name__=='__main__':
    # make version including Qt
    print "start"
    QUTECSOUND_VERSION = '0.7.0-alpha'
    NEW_NAME='CsoundQt'
    QtFrameworksDir = '/Users/andres/QtSDK/Desktop/Qt/4.8.1/'
    QtBinDir = '/Users/andres/QtSDK/Desktop/Qt/4.8.1/gcc/bin'
    CsoundQtBinPath = '../../qcs-build-desktop-Desktop_Qt_4_8_1_for_GCC__Qt_SDK__Release/bin'
    # for non QtSDK libs 
    QtFrameworksDir = '/Library/Frameworks'
    QtBinDir = '/usr/bin'
    CsoundQtBinPath = './'
    
    PythonQtLibPaths = ['/usr/local/lib/', '../../PythonQt2.1_Qt4.8/lib/', '../../../../PythonQt2.1_Qt4.8/lib/', './']

    print "---------------- Making doubles package"
    deployWithPython('-d', NEW_NAME, QUTECSOUND_VERSION, QtFrameworksDir, CsoundQtBinPath,PythonQtLibPaths)
