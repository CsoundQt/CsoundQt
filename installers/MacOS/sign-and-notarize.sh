
# run the script from ints location, <source_root>/installers/MacOS, where it is located
BUILD_DIR="../../../build-cs7-qcsQt_6_5_3_for_macOS-Release/bin"
APP="CsoundQt-d-html-cs7.app"
DMG="CsoundQt-7.0.0-beta1-MacOS.dmg"

cp CsoundQt.entitlements $BUILD_DIR

cd $BUILD_DIR

#on some reason qt install script did not do it:
install_name_tool -change /Applications/Csound/CsoundLib64.framework/CsoundLib64 @rpath/CsoundLib64.framework/CsoundLib64 $APP/Contents/MacOS/CsoundQt-d-html-cs7

# NB! In Csound framework -  move libs to Versions/7.0 and use name_change_tool to set the location for CsoundLib64 or according plugin, not sure...
# the problem is for Opcodes64/libpmidi.dylib

if [ -d "$APP/Contents/Frameworks/CsoundLib64.framework/libs" ]; then
    rm -rf "$APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/libs"
    mv "$APP/Contents/Frameworks/CsoundLib64.framework/libs" "$APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/libs"
fi


# otool -L tells depency: @loader_path/../../../../libs/libportmidi.dylib shold be @loader_path/../../libs/libportmidi.dylib -- must be tested!
# run it after macdeloyqt has been executed
install_name_tool -change @loader_path/../../../../libs/libportmidi.dylib @loader_path/../../libs/libportmidi.dylib $APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/Resources/Opcodes64/libpmidi.dylib
# sign



# sign

#maybe this first:
codesign --remove-signature "$APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/CsoundLib64"

#codesign --options=runtime --timestamp  --force --deep --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)" $APP
#nb! if runtime ise used, will not plugins. Maybe signing in directories is needed. like:
find $APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/Resources/Opcodes64/ -name "*.dylib" -exec codesign --options=runtime --force  --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)" {} \;

find $APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/libs -name "*.dylib" -exec codesign --options=runtime --force  --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)" {} \;

#maybe Csound64 and macOS/CsoundQt-d must be signed separately
codesign --options=runtime --timestamp  --force --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)"  $APP/Contents/MacOS/CsoundQt-d-html-cs7

codesign --options=runtime --timestamp  --force --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)"  $APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/CsoundLib64

codesign --options=runtime --timestamp  --force --deep --sign   "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)"  --entitlements CsoundQt.entitlements $APP



# check
codesign -vvv --deep --strict $APP
#spctl -vvv --assess --type exec $APP # <- this seems to tell rejected always...

# pack
rm $DMG
hdiutil create -fs HFS+ -srcfolder $APP -volname CsoundQt7 $DMG

#notarize:
# first create an app specific password on Developer portal
# see: https://docs.digicert.com/en/software-trust-manager/threat-detection/apple-notarization/notarize-apple-binaries.html

#CsoundQt passsword, created on https://account.apple.com/account/manage is: okxd-smqi-lide-oeip

xcrun notarytool submit --apple-id "trmjhnns@gmail.com" --password "okxd-smqi-lide-oeip" --team-id "DRQ77GKK9V"  --wait $DMG


# log (use the submission ID from previous command) -  if problems...:
# xcrun notarytool log {submission-id}  --apple-id "trmjhnns@gmail.com" --password "okxd-smqi-lide-oeip" --team-id "DRQ77GKK9V"


#staple
xcrun stapler staple $DMG
xcrun stapler validate  $DMG 




