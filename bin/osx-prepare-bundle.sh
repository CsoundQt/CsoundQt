#!/bin/sh

#mkdir QuteCsound.app/Contents/Resources
#cp ../src/default.csd QuteCsound.app/Contents/MacOS
#cp ../src/opcodes.xml QuteCsound.app/Contents/MacOS

#-n don't compress
#-v version number

nflag=0
vflag=
while getopts 'nv:' OPTION
do
case $OPTION in
n)	nflag=1
;;
v)	vflag=1
bval="$OPTARG"
;;
?)	printf "Usage: %s: [-n] [-n version] args\n" $(basename $0) >&2
exit 2
;;
esac
done
shift $(($OPTIND - 1))



mv qutecsound.app QuteCsound.app

if [ "$nflag" -ne 1 ]
        then
tar -czvf QuteCsound-noQt.tar.gz QuteCsound.app
fi

mkdir QuteCsound.app/Contents/Frameworks

# make version including Qt
cp -R /Library/Frameworks/QtCore.framework QuteCsound.app/Contents/Frameworks/
cp -R /Library/Frameworks/QtGui.framework QuteCsound.app/Contents/Frameworks/
cp -R /Library/Frameworks/QtXml.framework QuteCsound.app/Contents/Frameworks/

install_name_tool -change QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore QuteCsound.app/Contents/MacOS/qutecsound
install_name_tool -change QtGui.framework/Versions/4/QtGui @executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui QuteCsound.app/Contents/MacOS/qutecsound
install_name_tool -change QtXml.framework/Versions/4/QtXml @executable_path/../Frameworks/QtXml.framework/Versions/4/QtXml QuteCsound.app/Contents/MacOS/qutecsound

install_name_tool -id @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore QuteCsound.app/Contents/Frameworks/QtCore.framework/Versions/4/QtCore
install_name_tool -id @executable_path/../Frameworks/QtGui.framework/Versions/4.0/QtGui QuteCsound.app/Contents/Frameworks/QtGui.framework/Versions/4/QtGui
install_name_tool -id @executable_path/../Frameworks/QtXml.framework/Versions/4.0/QtXml QuteCsound.app/Contents/Frameworks/QtXml.framework/Versions/4/QtXml

install_name_tool -change  QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore QuteCsound.app/Contents/Frameworks/QtGui.framework/Versions/4.0/QtGui
install_name_tool -change  QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore QuteCsound.app/Contents/Frameworks/QtXml.framework/Versions/4.0/QtXml

rm QuteCsound.app/Contents/Info.plist
cp ../src/MyInfo.plist QuteCsound.app/Contents/Info.plist

otool -L QuteCsound.app/Contents/MacOS/qutecsound

if [ "$nflag"  -ne 1 ]
        then
tar -czvf QuteCsound-incQt.tar.gz QuteCsound.app
fi


# make Standalone application
cp -R /Library/Frameworks/CsoundLib.framework QuteCsound.app/Contents/Frameworks/
cp /usr/local/lib/libsndfile.1.dylib QuteCsound.app/Contents/libsndfile.dylib
cp /usr/local/lib/libportaudio.2.0.0.dylib QuteCsound.app/Contents/libportaudio.dylib
cp /usr/local/lib/libportmidi.dylib QuteCsound.app/Contents/libportmidi.dylib
cp /usr/local/lib/libmpadec.dylib QuteCsound.app/Contents/libmpadec.dylib
cp /usr/local/lib/liblo.0.6.0.dylib QuteCsound.app/Contents/liblo.dylib
cp /usr/local/lib/libfltk.1.1.dylib QuteCsound.app/Contents/libfltk.dylib
cp /usr/local/lib/libfltk_images.1.1.dylib QuteCsound.app/Contents/libfltk_images.dylib
cp /usr/local/lib/libfluidsynth.1.dylib QuteCsound.app/Contents/libfluidsynth.dylib
cp /usr/local/lib/libpng12.0.dylib QuteCsound.app/Contents/libpng12.dylib
cp /usr/local/lib/libpng12.0.dylib QuteCsound.app/Contents/libpng12.dylib

install_name_tool -id @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib QuteCsound.app/Contents/MacOS/qutecsound
install_name_tool -change  /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib QuteCsound.app/Contents/MacOS/qutecsound
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib @executable_path/../Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib QuteCsound.app/Contents/MacOS/qutecsound
install_name_tool -change /Library/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/Current/CsoundLib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib


install_name_tool -id @executable_path/../libsndfile.dylib QuteCsound.app/Contents/libsndfile.dylib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /usr/local/lib/libsndfile.1.dylib @executable_path/../libsndfile.dylib QuteCsound.app/Contents/MacOS/qutecsound

install_name_tool -id @executable_path/../libportaudio.dylib QuteCsound.app/Contents/libportaudio.dylib
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libportaudio.2.dylib @executable_path/../libportaudio.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libportmidi.dylib QuteCsound.app/Contents/libportmidi.dylib
install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libportmidi.dylib @executable_path/../libportmidi.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libmpadec.dylib QuteCsound.app/Contents/libmpadec.dylib
install_name_tool -change /usr/local/lib/libmpadec.dylib @executable_path/../libmpadec.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libmpadec.2.dylib @executable_path/../libmpadec.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../liblo.dylib QuteCsound.app/Contents/liblo.dylib
install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/liblo.0.dylib @executable_path/../liblo.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libfltk.dylib QuteCsound.app/Contents/libfltk.dylib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

install_name_tool -id @executable_path/../libfltk_images.dylib QuteCsound.app/Contents/libfltk_images.dylib
install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfltk_images.1.1.dylib @executable_path/../libfltk_images.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib
install_name_tool -change /usr/local/lib/libfltk.1.1.dylib @executable_path/../libfltk.dylib QuteCsound.app/Contents/libfltk_images.dylib
install_name_tool -change /usr/local/lib/libpng12.0.dylib @executable_path/../libpng12.dylib QuteCsound.app/Contents/libfltk_images.dylib

install_name_tool -id @executable_path/../libpng12.dylib QuteCsound.app/Contents/libpng12.dylib

install_name_tool -id @executable_path/../libfluidsynth.dylib QuteCsound.app/Contents/libfluidsynth.dylib
install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/lib_csnd.dylib
install_name_tool -change /usr/local/lib/libfluidsynth.1.dylib @executable_path/../libfluidsynth.dylib QuteCsound.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/CsoundLib

# TODO include dot and Jack installers in an optional directory.

otool -L QuteCsound.app/Contents/MacOS/qutecsound
otool -L QuteCsound.app/Contents/libsndfile.dylib
otool -L QuteCsound.app/Contents/libportaudio.dylib
otool -L QuteCsound.app/Contents/libportmidi.dylib
otool -L QuteCsound.app/Contents/libmpadec.dylib
otool -L QuteCsound.app/Contents/liblo.dylib
otool -L QuteCsound.app/Contents/libpng12.dylib
otool -L QuteCsound.app/Contents/libfltk_images.dylib
otool -L QuteCsound.app/Contents/libfluidsynth.dylib

if [ "$nflag" -ne 1 ]
        then
tar -czvf QuteCsound-full.tar.gz QuteCsound.app
fi


