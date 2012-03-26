from subprocess import call
import shutil
import os
import pdb
import fileinput 


QUTECSOUND_VERSION = '0.7.0-alpha'
NEW_NAME='CsoundQt'
QtFrameworksDir = '/Users/acabrera/QtSDK/Desktop/Qt/473/'
PythonQtLibPaths = ['../PythonQt-build-desktop-Release/lib/', '../../../../PythonQt-build-desktop-Release/lib/', './']

debug = False
CsoundQtBinPath = '../../qcs-build-desktop-pythonqt/bin'

# Build everything just to make sure all versions packaged are synchronized
#cd ..
#qmake qcs.pro CONFIG+=rtmidi -spec macx-g++ -r CONFIG+=release
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=build64 -spec macx-g++ -r CONFIG+=release
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=pythonqt
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=build64 CONFIG+=pythonqt
#make
#cd bin

#lipo ${ORIGINAL_NAME}.app/Contents/MacOS/${ORIGINAL_NAME} ${ORIGINAL_NAME_D}.app/Contents/MacOS/${ORIGINAL_NAME_D} -create --output ${ORIGINAL_NAME}.app/Contents/MacOS/qutecsound



def deployWithPython(PRECISION):
    global NEW_NAME, QtFrameworksDir, QUTECSOUND_VERSION

    ORIGINAL_NAME = 'CsoundQt' + PRECISION + '-py'
    if debug:
        ORIGINAL_NAME += '-debug'
    APP_NAME= NEW_NAME + PRECISION + '-py-' + QUTECSOUND_VERSION + '.app'

    ORIG_APP_NAME=ORIGINAL_NAME + '.app'
    if (os.path.exists(APP_NAME)):
        shutil.rmtree(APP_NAME)
    shutil.copytree(CsoundQtBinPath + '/' + ORIG_APP_NAME, ORIG_APP_NAME)
    print "Copied ",CsoundQtBinPath + '/' + ORIG_APP_NAME

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
    
    #chmod -R a-w $APP_NAME/Contents/Resources
    #pdb.set_trace()
    
    os.mkdir(ORIG_APP_NAME+ '/Contents/Frameworks')
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


    arguments = ['-change',  'libPythonQt.1.dylib',
            '@executable_path/../Frameworks/libPythonQt.1.dylib',
            '%s/Contents/MacOs/%s'%(ORIG_APP_NAME, ORIGINAL_NAME)]
    retcode = call(['install_name_tool'] + arguments)
    arguments = ['-change',  'libPythonQt.1.dylib',
            '@executable_path/../Frameworks/libPythonQt.1.dylib',
            '%s/Contents/Frameworks/libPythonQt_QtAll.1.dylib'%(ORIG_APP_NAME)]
    retcode = call(['install_name_tool'] + arguments)
    arguments = ['-change',  'libPythonQt_QtAll.1.dylib',
            '@executable_path/../Frameworks/libPythonQt_QtAll.1.dylib',
            '%s/Contents/MacOS/%s'%(ORIG_APP_NAME, ORIGINAL_NAME)]
    retcode = call(['install_name_tool'] + arguments)


    QtLibs = ['QtCore', 'QtGui', 'QtXml', 'QtDBus', 'QtSvg', 'QtSql', 'QtXmlPatterns', 'QtOpenGL', 'QtNetwork', 'QtWebKit', 'phonon']

    for lib in QtLibs:
        arguments = ['-change',  '%sgcc/lib/%s.framework/Versions/Current/%s'%(QtFrameworksDir,lib,lib),
                     '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib,lib),
                     '%s/Contents/Frameworks/libPythonQt.1.dylib'%(ORIG_APP_NAME)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/%s.framework/Versions/Current/%s'%(QtFrameworksDir,lib,lib),
                     '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib,lib),
                     '%s/Contents/Frameworks/libPythonQt_QtAll.1.dylib'%(ORIG_APP_NAME)]
        retcode = call(['install_name_tool'] + arguments)

    arguments = ['-change',  '@executable_path/../Frameworks/libsndfile.1.dylib',
                 'libsndfile.1.dylib',
                 '%s/Contents/MacOS/%s'%(ORIG_APP_NAME, ORIGINAL_NAME)]
    retcode = call(['install_name_tool'] + arguments)

    
    QtLibs = ['QtCore', 'QtGui', 'QtXml', 'QtSvg', 'QtSql', 'QtXmlPatterns', 'QtOpenGL', 'QtNetwork', 'QtWebKit', 'phonon']
    QtDepLibs = ['QtGui', 'QtXml', 'QtSvg', 'QtSql', 'QtXmlPatterns', 'QtOpenGL', 'QtNetwork', 'QtWebKit', 'phonon']
    deployQtLibs(ORIG_APP_NAME, ORIGINAL_NAME, QtLibs, QtDepLibs)
    
    arguments = [ORIG_APP_NAME, '-verbose=1']
    retcode = call([QtFrameworksDir + 'gcc/bin/macdeployqt'] + arguments)
    
    os.rename(ORIG_APP_NAME, APP_NAME)
    #rm $APP_NAME/Contents/Info.plist
    #cp ../src/MyInfo.plist $APP_NAME/Contents/Info.plist
    
    retcode = call(['tar', '-czvf', '%s%s-%s.tar.gz'%(NEW_NAME,PRECISION,QUTECSOUND_VERSION), APP_NAME])
    

def deployQtLibs(APP_NAME, ORIGINAL_NAME, QtLibs, QtDepLibs):
    for lib in QtLibs:
        shutil.copytree('%s/gcc/lib/%s.framework'%(QtFrameworksDir, lib), APP_NAME + '/Contents/Frameworks/%s.framework'%(lib), symlinks=True)
        arguments = ['-id',  '@executable_path/../Frameworks/%s.framework/Versions/4/%s'%(lib, lib),
                     '%s/Contents/Frameworks/%s.framework/Versions/4/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        os.remove('%s/Contents/Frameworks/%s.framework/%s_debug'%(APP_NAME, lib, lib))
        os.remove('%s/Contents/Frameworks/%s.framework/Versions/Current/%s_debug'%(APP_NAME, lib, lib))
        #	os.remove('%s/Contents/Frameworks/%s.framework/Versions/4.0/%s_debug'%(APP_NAME, lib, lib))
        #	os.remove('%s/Contents/Frameworks/%s.framework/Versions/4/%s_debug'%(APP_NAME, lib, lib))
        #shutil.rmtree('%s/Contents/Frameworks/%s.framework/%s_debug.dSYM'%(APP_NAME, lib, lib))
        #os.remove('%s/Contents/Frameworks/%s.framework/%s_debug.prl'%(APP_NAME, lib, lib))
        
    for lib in QtDepLibs:
        print 'processing: ', lib
        arguments = ['-change',  '%sgcc/lib/QtCore.framework/Versions/4/QtCore'%QtFrameworksDir,
                     '@executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore',
                     '%s/Contents/Frameworks/%s.framework//%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/QtGui.framework/Versions/4/QtGui'%QtFrameworksDir,
                     '@executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui',
                     '%s/Contents/Frameworks/%s.framework/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/QtXml.framework/Versions/4/QtXml'%QtFrameworksDir,
                     '@executable_path/../Frameworks/QtXml.framework/Versions/Current/QtXml',
                     '%s/Contents/Frameworks/%s.framework/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/QtDbus.framework/Versions/4/QtDbus'%QtFrameworksDir,
                     '@executable_path/../Frameworks/QtDBus.framework/Versions/4/QtDBus',
                     '%s/Contents/Frameworks/%s.framework/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/QtNetwork.framework/Versions/4/QtNetwork'%QtFrameworksDir,
                     '@executable_path/../Frameworks/QtNetwork.framework/Versions/4/QtNetwork',
                     '%s/Contents/Frameworks/%s.framework/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/QtXmlPatterns.framework/Versions/4/QtXmlPatterns'%QtFrameworksDir,
                     '@executable_path/../Frameworks/QtXmlPatterns.framework/Versions/4/QtXmlPatterns',
                     '%s/Contents/Frameworks/%s.framework/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        arguments = ['-change',  '%sgcc/lib/phonon.framework/Versions/4/phonon'%QtFrameworksDir,
                     '@executable_path/../Frameworks/phonon.framework/Versions/4/phonon',
                     '%s/Contents/Frameworks/%s.framework/%s'%(APP_NAME, lib, lib)]
        retcode = call(['install_name_tool'] + arguments)
        
# make version including Qt
print "---------------- Making doubles package"

deployWithPython('-d')

print "---------------- Making floats package"

deployWithPython('-f')


# make Standalone application
# echo "---------------- Making standalone app"
# cp -R /Library/Frameworks/CsoundLib.framework $APP_NAME/Contents/Frameworks/
# cp /usr/local/lib/libsndfile.1.dylib $APP_NAME/Contents/libsndfile.dylib
# cp /usr/local/lib/libportaudio.2.0.0.dylib $APP_NAME/Contents/libportaudio.dylib
# cp /usr/local/lib/libportmidi.dylib $APP_NAME/Contents/libportmidi.dylib
# cp /usr/local/lib/libmpadec.dylib $APP_NAME/Contents/libmpadec.dylib
# cp /usr/local/lib/liblo.0.6.0.dylib $APP_NAME/Contents/liblo.dylib
# cp /usr/local/lib/libfltk.1.1.dylib $APP_NAME/Contents/libfltk.dylib
# cp /usr/local/lib/libfltk_images.1.1.dylib $APP_NAME/Contents/libfltk_images.dylib
# cp /usr/local/lib/libfluidsynth.1.dylib $APP_NAME/Contents/libfluidsynth.dylib
# cp /usr/local/lib/libpng12.0.dylib $APP_NAME/Contents/libpng12.dylib
# cp /usr/local/lib/libpng12.0.dylib $APP_NAME/Contents/libpng12.dylib

# install_name_tool -id @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
# install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
# install_name_tool -change  /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
# install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
# install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/Current/CsoundLib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib


# install_name_tool -id @executable_path/../libsndfile.dylib $APP_NAME/Contents/libsndfile.dylib
# install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
# install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}

# install_name_tool -id @executable_path/../libportaudio.dylib $APP_NAME/Contents/libportaudio.dylib
# install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# install_name_tool -id @executable_path/../libportmidi.dylib $APP_NAME/Contents/libportmidi.dylib
# install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# install_name_tool -id @executable_path/../libmpadec.dylib $APP_NAME/Contents/libmpadec.dylib
# install_name_tool -change /usr/local/lib/libmpadec.dylib @executable_path/../libmpadec.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libmpadec.2.dylib @executable_path/../libmpadec.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# install_name_tool -id @executable_path/../liblo.dylib $APP_NAME/Contents/liblo.dylib
# install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# install_name_tool -id @executable_path/../libfltk.dylib $APP_NAME/Contents/libfltk.dylib
# install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# install_name_tool -id @executable_path/../libfltk_images.dylib $APP_NAME/Contents/libfltk_images.dylib
# install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
# install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/libfltk_images.dylib
# install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib $APP_NAME/Contents/libfltk_images.dylib

# install_name_tool -id @executable_path/../libpng12.dylib $APP_NAME/Contents/libpng12.dylib

# install_name_tool -id @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/libfluidsynth.dylib
# install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
# install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# # TODO include dot and Jack installers in an optional directory.

# otool -L $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
# otool -L $APP_NAME/Contents/libsndfile.dylib
# otool -L $APP_NAME/Contents/libportaudio.dylib
# otool -L $APP_NAME/Contents/libportmidi.dylib
# otool -L $APP_NAME/Contents/libmpadec.dylib
# otool -L $APP_NAME/Contents/liblo.dylib
# otool -L $APP_NAME/Contents/libpng12.dylib
# otool -L $APP_NAME/Contents/libfltk_images.dylib
# otool -L $APP_NAME/Contents/libfluidsynth.dylib

# # Process plugin opcodes dylibs

# cd $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/Resources/Opcodes/

# for f in *
# do
#   echo "---------------- Processing $f file..."
#   # take action on each file. $f stores current file name

# install_name_tool -id @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/Resources/Opcodes/$f $f
# install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $f
# install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $f
# install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $f
# install_name_tool -change libmpadec.dylib @executable_path/../libmpadec.dylib $f
# otool -L $f
# #  cat $f
# done

# # Extra changes for plugins with dependencies

# install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib libfluidOpcodes.dylib

# install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib libimage.dylib
# install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib libimage.dylib

# install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib libosc.dylib
# install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib libosc.dylib

# install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib libpmidi.dylib

# cd ../../../../../../../../

# # Compress final archive

# if [ "$nflag" -ne 1 ]
# 		then
# tar -czvf ${NEW_NAME}-${QUTECSOUND_VERSION}-full.tar.gz $APP_NAME &>/dev/null
# fi

