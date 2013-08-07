rm -rf ./CsoundQt-d-cs6.app
cp -rf "/Users/cristina/Documents/src/build-qcs-Desktop_Qt_5_1_0_clang_64bit-Release/bin/CsoundQt-d-cs6.app" ./

~/Qt/5.1.0/clang_64/bin/macdeployqt CsoundQt-d-cs6.app/

rm -rf CsoundQt-d-cs6.app/Contents/Frameworks/CsoundLib64.framework

rm -rf CsoundQt-d-cs6.app/Contents/Frameworks/*.dylib

mkdir CsoundQt-d-cs6.app/Contents/Resources
cp -r ../src/Examples/McCurdy\ Collection CsoundQt-d-cs6.app/Contents/Resources/McCurdy\ Collection

tar -czvf CsoundQt-cs6-oSX10.8-0.8.0.tar.gz CsoundQt-d-cs6.app &>/dev/null
