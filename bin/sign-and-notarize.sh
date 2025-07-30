BUILD_DIR="../build-cs7-qcsQt_6_5_3_for_macOS-Release/bin"
APP="CsoundQt-d-cs7.app"
DMG="CsoundQt-7.0.0-MacOS.dmg"

# sign

cd $BUILD_DIR

# sign
codesign --options=runtime --timestamp  --force --deep --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)" $APP
#nb! if runtime ise used, will not plugins. Maybe signing in directories is needed. like:
find $APP/Contents/Frameworks/CsoundLib64.framework/Versions/7.0/Resources/Opcodes64/ -name "*.dylib" -exec codesign --force  --sign "Developer ID Application: Tarmo Johannes (DRQ77GKK9V)" {} \;

#maybe Csound64 and macOS/CsoundQt-d must be signed separately

# check
codesign -vvv --deep --strict $APP

# pack
hdiutil create -fs HFS+ -srcfolder $APP -volname CsoundQt7 $DMG

#notarize:
# first create an app specific password on Developer portal
# see: https://docs.digicert.com/en/software-trust-manager/threat-detection/apple-notarization/notarize-apple-binaries.html


# log:
xcrun notarytool log 2a65e696-aef7-4609-a958-941ae0b9914e  --apple-id "trmjhnns@gmail.com" --password "vnqy-lwpd-lplp-hqiz" --team-id "DRQ77GKK9V"

# error at this point: Error: HTTP status code: 403. Invalid or inaccessible developer team ID for the provided Apple ID. Ensure the Team ID is correct and that you are a member of that team.

#staple
xcrun stapler staple $DMG




