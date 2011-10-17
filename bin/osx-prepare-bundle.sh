#!/bin/sh

#-n don't compress
#-v version number
#-b clean and rebuild

nflag=0
vflag=
bflag=0
debug=
while getopts 'bnvd:' OPTION
do
case $OPTION in
n)	nflag=1
;;
b)	bflag=1
;;
v)	vflag=1
bval="$OPTARG"
;;
d)	debug="_d"
;;
?)	printf "Usage: %s: [-b] [-d] [-n] [-n version] args\n" $(basename $0) >&2
exit 2
;;
esac
done

shift $(($OPTIND - 1))

clear

echo "Enter version number/name (e.g. 0.7.0-alpha-py):"
read CSOUNDQT_VERSION

# Package without python first

PRECISION=-f
ORIGINAL_NAME=CsoundQt${PRECISION}
ORIGINAL_APP_NAME=${ORIGINAL_NAME}.app
APP_NAME=${ORIGINAL_APP_NAME}

if [ "$bflag"  -eq 1 ]
		then
		echo "---------------- Building floats package without python"

rm -Rf ${ORIGINAL_APP_NAME}
rm -Rf ${APP_NAME}
make clean > null
qmake qcs.pro -spec macx-g++ CONFIG+=rtmidi CONFIG+=release
make > build-floats.log
fi

cd bin
mv $ORIG_APP_NAME/ $APP_NAME/
#McCurdy collection
mkdir $APP_NAME/Contents/Resources
cp -r ../../src/Examples/McCurdy\ Collection $APP_NAME/Contents/Resources/McCurdy\ Collection

macdeployqt ${APP_NAME} -dmg
otool -L ${APP_NAME}/Contents/MacOS/$ORIGINAL_NAME
cd ..

# ----------------------- Now the doubles version
PRECISION=-d
ORIGINAL_NAME=CsoundQt${PRECISION}
ORIGINAL_APP_NAME=${ORIGINAL_NAME}.app
APP_NAME=${ORIGINAL_APP_NAME}

if [ "$bflag"  -eq 1 ]
		then
		echo "---------------- Building doubles package without python"

rm -Rf ${ORIGINAL_APP_NAME}
rm -Rf ${APP_NAME}
make clean > null
qmake qcs.pro -spec macx-g++ CONFIG+=rtmidi CONFIG+=release CONFIG+=build64
make > build-doubles.log
fi

cd bin
mv $ORIG_APP_NAME/ $APP_NAME/
#McCurdy collection
mkdir $APP_NAME/Contents/Resources
cp -r ../../src/Examples/McCurdy\ Collection $APP_NAME/Contents/Resources/McCurdy\ Collection

macdeployqt ${APP_NAME} -dmg
otool -L ${APP_NAME}/Contents/MacOS/$ORIGINAL_NAME

cd ..

# ---------------------- With Python
PRECISION=-d
ORIGINAL_NAME=CsoundQt${PRECISION}-py
NEW_NAME=CsoundQt
ORIG_APP_NAME=${ORIGINAL_NAME}.app
APP_NAME=${NEW_NAME}-${CSOUNDQT_VERSION}${PRECISION}-py.app
if [ "$bflag"  -eq 1 ]
then
		echo "---------------- Making package with python (intel only)"

rm -Rf ${ORIGINAL_APP_NAME}
rm -Rf ${APP_NAME}
cd ..
make clean > null
qmake qcs.pro -spec macx-g++ CONFIG+=intel CONFIG+=rtmidi CONFIG+=pythonqt CONFIG+=release CONFIG+=build64
make > build-python.log
fi

cd bin
# Copy PythonQt which is not found by macdeployqt
mkdir ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt.1.dylib ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt.1.0.0.dylib ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt_QtAll.1.0.0.dylib ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt_QtAll.1.dylib ${ORIG_APP_NAME}/Contents/Frameworks/

mv $ORIG_APP_NAME/ $APP_NAME/
#McCurdy collection
mkdir $APP_NAME/Contents/Resources
cp -r ../../src/Examples/McCurdy\ Collection $APP_NAME/Contents/Resources/McCurdy\ Collection

macdeployqt ${APP_NAME} -dmg
otool -L ${APP_NAME}/Contents/MacOS/$ORIGINAL_NAME
cd ..

# And for python floats

PRECISION=-f
ORIGINAL_NAME=CsoundQt${PRECISION}-py
NEW_NAME=CsoundQt
ORIG_APP_NAME=${ORIGINAL_NAME}.app
APP_NAME=${NEW_NAME}-${CSOUNDQT_VERSION}${PRECISION}-py.app
if [ "$bflag"  -eq 1 ]
then
		echo "---------------- Making package with python (intel only)"

rm -Rf ${ORIGINAL_APP_NAME}
rm -Rf ${APP_NAME}
make clean > null
qmake qcs.pro -spec macx-g++ CONFIG+=intel CONFIG+=rtmidi CONFIG+=pythonqt CONFIG+=release CONFIG+=build64
make > build-python.log
fi

cd bin
# Copy PythonQt which is not found by macdeployqt
mkdir ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt.1.dylib ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt.1.0.0.dylib ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt_QtAll.1.0.0.dylib ${ORIG_APP_NAME}/Contents/Frameworks/
cp ../libPythonQt_QtAll.1.dylib ${ORIG_APP_NAME}/Contents/Frameworks/

mv $ORIG_APP_NAME/ $APP_NAME/
#McCurdy collection
mkdir $APP_NAME/Contents/Resources
cp -r ../../src/Examples/McCurdy\ Collection $APP_NAME/Contents/Resources/McCurdy\ Collection

macdeployqt ${APP_NAME} -dmg
otool -L ${APP_NAME}/Contents/MacOS/$ORIGINAL_NAME


exit
# ----------------------------  make Standalone application
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
tar -czvf ${NEW_NAME}-${CSOUNDQT_VERSION}-Standalone.tar.gz $APP_NAME &>/dev/null
fi


