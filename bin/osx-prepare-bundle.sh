#!/bin/sh

#mkdir qutecsound.app/Contents/Resources
#cp ../src/default.csd qutecsound.app/Contents/MacOS
#cp ../src/opcodes.xml qutecsound.app/Contents/MacOS

zip -r QuteCsound-noQt qutecsound.app
mkdir qutecsound.app/Contents/Frameworks

cp -R /Library/Frameworks/QtCore.framework qutecsound.app/Contents/Frameworks/
cp -R /Library/Frameworks/QtGui.framework qutecsound.app/Contents/Frameworks/
cp -R /Library/Frameworks/QtXml.framework qutecsound.app/Contents/Frameworks/

install_name_tool -change QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore qutecsound.app/Contents/MacOS/qutecsound 
install_name_tool -change QtGui.framework/Versions/4/QtGui @executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui qutecsound.app/Contents/MacOS/qutecsound
install_name_tool -change QtXml.framework/Versions/4/QtXml @executable_path/../Frameworks/QtXml.framework/Versions/4/QtXml qutecsound.app/Contents/MacOS/qutecsound

install_name_tool -id @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore qutecsound.app/Contents/Frameworks/QtCore.framework/Versions/4/QtCore
install_name_tool -id @executable_path/../Frameworks/QtGui.framework/Versions/4.0/QtGui qutecsound.app/Contents/Frameworks/QtGui.framework/Versions/4/QtGui
install_name_tool -id @executable_path/../Frameworks/QtXml.framework/Versions/4.0/QtXml qutecsound.app/Contents/Frameworks/QtXml.framework/Versions/4/QtXml

install_name_tool -change  QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore qutecsound.app/Contents/Frameworks/QtGui.framework/Versions/4.0/QtGui
install_name_tool -change  QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4.0/QtCore qutecsound.app/Contents/Frameworks/QtXml.framework/Versions/4.0/QtXml

rm qutecsound.app/Contents/Info.plist
cp ../src/MyInfo.plist qutecsound.app/Contents/Info.plist

otool -L qutecsound.app/Contents/MacOS/qutecsound
zip -r QuteCsound-incQt qutecsound.app
