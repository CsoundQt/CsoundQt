#!/bin/sh

#mkdir QuteCsound.app/Contents/Resources
#cp ../src/default.csd QuteCsound.app/Contents/MacOS
#cp ../src/opcodes.xml QuteCsound.app/Contents/MacOS

mv qutecsound.app QuteCsound.app
zip -r QuteCsound-noQt QuteCsound.app
mkdir QuteCsound.app/Contents/Frameworks

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
zip -r QuteCsound-incQt QuteCsound.app
