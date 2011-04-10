#!/bin/sh

#mkdir $APP_NAME/Contents/Resources
#cp ../src/default.csd $APP_NAME/Contents/MacOS
#cp ../src/opcodes.xml $APP_NAME/Contents/MacOS

#-n don't compress
#-v version number

clear

echo "Enter version number/name (e.g. 0.7.0-alpha-py):"
read QUTECSOUND_VERSION


#CSOUNDLIBNAME=

nflag=0
vflag=
debug=
while getopts 'nvd:' OPTION
do
case $OPTION in
n)	nflag=1
;;
v)	vflag=1
bval="$OPTARG"
;;
d)	debug="_d"
;;
?)	printf "Usage: %s: [-d] [-n] [-n version] args\n" $(basename $0) >&2
exit 2
;;
esac
done
shift $(($OPTIND - 1))

PRECISION=-f
ORIGINAL_NAME=qutecsound${PRECISION}
NEW_NAME=QuteCsound

# Build everything just to make sure all versions packaged are synchronized
cd ..
qmake qcs.pro CONFIG+=rtmidi -spec macx-g++ -r CONFIG+=release
make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=build64 -spec macx-g++ -r CONFIG+=release
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=pythonqt
#make
#qmake qcs.pro CONFIG+=rtmidi CONFIG+=build64 CONFIG+=pythonqt
#make
cd bin

#lipo ${ORIGINAL_NAME}.app/Contents/MacOS/${ORIGINAL_NAME} ${ORIGINAL_NAME_D}.app/Contents/MacOS/${ORIGINAL_NAME_D} -create --output ${ORIGINAL_NAME}.app/Contents/MacOS/qutecsound

ORIG_APP_NAME=${ORIGINAL_NAME}.app
APP_NAME=${NEW_NAME}-${QUTECSOUND_VERSION}.app

mv $ORIG_APP_NAME/ $APP_NAME/
mkdir $APP_NAME/Contents/Resources
cp -r ../src/Examples/McCurdy\ Collection $APP_NAME/Contents/Resources
chmod -R a-w $APP_NAME/Contents/Resources

if [ "$nflag" -ne 1 ]
        then
  echo "---------------- Making noQt package"
  tar -czvf ${NEW_NAME}-${QUTECSOUND_VERSION}-noQt.tar.gz $APP_NAME &>/dev/null
fi

mkdir $APP_NAME/Contents/Frameworks

# make version including Qt
echo "---------------- Making incQt package"
cp -R /Library/Frameworks/QtCore.framework $APP_NAME/Contents/Frameworks/
cp -R /Library/Frameworks/QtGui.framework $APP_NAME/Contents/Frameworks/
cp -R /Library/Frameworks/QtXml.framework $APP_NAME/Contents/Frameworks/

cp -R ../../../../PythonQt2.0.1/lib/libPythonQt${debug}.1.0.0.dylib $APP_NAME/Contents/MacOS/libPythonQt${debug}.1.dylib

install_name_tool -change QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change QtGui.framework/Versions/4/QtGui @executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change QtXml.framework/Versions/4/QtXml @executable_path/../Frameworks/QtXml.framework/Versions/4/QtXml $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change libPythonQt${debug}.1.dylib @executable_path/libPythonQt${debug}.1.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}

install_name_tool -id @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore $APP_NAME/Contents/Frameworks/QtCore.framework/Versions/4/QtCore
install_name_tool -id @executable_path/../Frameworks/QtGui.framework/Versions/4.0/QtGui $APP_NAME/Contents/Frameworks/QtGui.framework/Versions/4/QtGui
install_name_tool -id @executable_path/../Frameworks/QtXml.framework/Versions/4.0/QtXml $APP_NAME/Contents/Frameworks/QtXml.framework/Versions/4/QtXml

install_name_tool -change  QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore $APP_NAME/Contents/Frameworks/QtGui.framework/Versions/4.0/QtGui
install_name_tool -change  QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore $APP_NAME/Contents/Frameworks/QtXml.framework/Versions/4.0/QtXml

install_name_tool -change QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore $APP_NAME/Contents/MacOS/libPythonQt${debug}.1.dylib
install_name_tool -change QtGui.framework/Versions/4/QtGui @executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui $APP_NAME/Contents/MacOS/libPythonQt${debug}.1.dylib

#rm $APP_NAME/Contents/Info.plist
#cp ../src/MyInfo.plist $APP_NAME/Contents/Info.plist

# Remove debugging info
rm -Rf $APP_NAME/Contents/Frameworks/QtGui.framework/QtGui_debug.dSYM
rm -Rf $APP_NAME/Contents/Frameworks/QtGui.framework/Versions/4/QtGui_debug
rm -Rf $APP_NAME/Contents/Frameworks/QtCore.framework/QtCore_debug.dSYM
rm -Rf $APP_NAME/Contents/Frameworks/QtCore.framework/Versions/4/QtCore_debug
rm -Rf $APP_NAME/Contents/Frameworks/QXml.framework/QtXml_debug.dSYM
rm -Rf $APP_NAME/Contents/Frameworks/QtXml.framework/Versions/4/QtXml_debug

otool -L $APP_NAME/Contents/MacOS/$ORIGINAL_NAME

if [ "$nflag"  -ne 1 ]
        then
tar -czvf ${NEW_NAME}-${QUTECSOUND_VERSION}-incQt.tar.gz $APP_NAME &>/dev/null
fi

# make Standalone application
echo "---------------- Making standalone app"
cp -R /Library/Frameworks/CsoundLib.framework $APP_NAME/Contents/Frameworks/
cp /usr/local/lib/libsndfile.1.dylib $APP_NAME/Contents/libsndfile.dylib
cp /usr/local/lib/libportaudio.2.0.0.dylib $APP_NAME/Contents/libportaudio.dylib
cp /usr/local/lib/libportmidi.dylib $APP_NAME/Contents/libportmidi.dylib
cp /usr/local/lib/libmpadec.dylib $APP_NAME/Contents/libmpadec.dylib
cp /usr/local/lib/liblo.0.6.0.dylib $APP_NAME/Contents/liblo.dylib
cp /usr/local/lib/libfltk.1.1.dylib $APP_NAME/Contents/libfltk.dylib
cp /usr/local/lib/libfltk_images.1.1.dylib $APP_NAME/Contents/libfltk_images.dylib
cp /usr/local/lib/libfluidsynth.1.dylib $APP_NAME/Contents/libfluidsynth.dylib
cp /usr/local/lib/libpng12.0.dylib $APP_NAME/Contents/libpng12.dylib
cp /usr/local/lib/libpng12.0.dylib $APP_NAME/Contents/libpng12.dylib

install_name_tool -id @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change  /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/Current/CsoundLib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib


install_name_tool -id @executable_path/../libsndfile.dylib $APP_NAME/Contents/libsndfile.dylib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}

install_name_tool -id @executable_path/../libportaudio.dylib $APP_NAME/Contents/libportaudio.dylib
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libportmidi.dylib $APP_NAME/Contents/libportmidi.dylib
install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libmpadec.dylib $APP_NAME/Contents/libmpadec.dylib
install_name_tool -change /usr/local/lib/libmpadec.dylib @executable_path/../libmpadec.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libmpadec.2.dylib @executable_path/../libmpadec.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../liblo.dylib $APP_NAME/Contents/liblo.dylib
install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libfltk.dylib $APP_NAME/Contents/libfltk.dylib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libfltk_images.dylib $APP_NAME/Contents/libfltk_images.dylib
install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $APP_NAME/Contents/libfltk_images.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib $APP_NAME/Contents/libfltk_images.dylib

install_name_tool -id @executable_path/../libpng12.dylib $APP_NAME/Contents/libpng12.dylib

install_name_tool -id @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/libfluidsynth.dylib
install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# TODO include dot and Jack installers in an optional directory.

otool -L $APP_NAME/Contents/MacOS/${ORIGINAL_NAME}
otool -L $APP_NAME/Contents/libsndfile.dylib
otool -L $APP_NAME/Contents/libportaudio.dylib
otool -L $APP_NAME/Contents/libportmidi.dylib
otool -L $APP_NAME/Contents/libmpadec.dylib
otool -L $APP_NAME/Contents/liblo.dylib
otool -L $APP_NAME/Contents/libpng12.dylib
otool -L $APP_NAME/Contents/libfltk_images.dylib
otool -L $APP_NAME/Contents/libfluidsynth.dylib

# Process plugin opcodes dylibs

cd $APP_NAME/Contents/Frameworks/CsoundLib.framework/Versions/5.2/Resources/Opcodes/

for f in *
do
  echo "---------------- Processing $f file..."
  # take action on each file. $f stores current file name

install_name_tool -id @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/Resources/Opcodes/$f $f
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib $f
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib $f
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib $f
install_name_tool -change libmpadec.dylib @executable_path/../libmpadec.dylib $f
otool -L $f
#  cat $f
done

# Extra changes for plugins with dependencies

install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib libfluidOpcodes.dylib

install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib libimage.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib libimage.dylib

install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib libosc.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib libosc.dylib

install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib libpmidi.dylib

cd ../../../../../../../../

# Compress final archive

if [ "$nflag" -ne 1 ]
        then
tar -czvf ${NEW_NAME}-${QUTECSOUND_VERSION}-full.tar.gz $APP_NAME &>/dev/null
fi


