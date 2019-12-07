#!/bin/bash
#set -e
#set -x

TEMPLATE_DMG=dist/template.dmg

# "working copy" names for the intermediate dmgs
WC_DMG=wc.dmg
WC_DIR=/Volumes/Meteorologist
VERSION=`cat VERSION2`
SOURCE_FILES="build/Release/Meteorologist.app dist/Readme.rtf"
MASTER_DMG="build/Meteorologist-${VERSION}.dmg"
dev_account=$(cat ~/.altoolid)
export ALPW=$(cat ~/.altoolpw)

# functions
requeststatus() { # $1: requestUUID
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun altool --notarization-info "$requestUUID" \
                              --username "$dev_account" \
                              --password "@env:ALPW" 2>&1 \
                 | awk -F ': ' '/Status:/ { print $2; }' )
    echo "$req_status"
}



rm -rf ./build

# https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow
# https://scriptingosx.com/2019/09/notarize-a-command-line-tool/

echo
echo "------------------------ Building Project -----------------------"
echo
echo xcodebuild -configuration Release
     xcodebuild -configuration Release > xcodebuild.log
	 exit_status=$?
     if [ "${exit_status}" != "0" ]
     then
     	cat xcodebuild.log
        exit 1
     fi
     rm xcodebuild.log

echo
echo codesign -s "Developer ID Application: Edward Danley" --timestamp --options runtime -f --entitlements ./Meteorologist/Meteorologist.entitlements --deep ./build/Release/Meteorologist.app
     codesign -s "Developer ID Application: Edward Danley" \
              --timestamp --options runtime -f --entitlements ./Meteorologist/Meteorologist.entitlements \
              --deep ./build/Release/Meteorologist.app
	 exit_status=$?
     if [ "${exit_status}" != "0" ]
     then
	 echo codesign -d -vvvv ./build/Release/Meteorologist.app
          codesign -d -vvvv ./build/Release/Meteorologist.app
     break
     fi
echo
echo /usr/bin/ditto -c -k --keepParent ./build/Release/Meteorologist.app ./build/Release/Meteorologist.zip
     /usr/bin/ditto -c -k --keepParent ./build/Release/Meteorologist.app ./build/Release/Meteorologist.zip
echo
     # altool requires an App Specific password
     # hide your App Specific in ~/.altoolpw
echo xcrun altool --notarize-app --primary-bundle-id "com.heat.Meteorologist" --username "$dev_account" --password "@env:ALPW" --file ./build/Release/Meteorologist.zip
     requestUUID=$(xcrun altool --notarize-app --primary-bundle-id "com.heat.Meteorologist" \
                                --username "$dev_account" --password "@env:ALPW" \
                               --file ./build/Release/Meteorologist.zip 2>&1 \
                  | awk '/RequestUUID/ { print $NF; }')
     echo "Notarization RequestUUID: $requestUUID"

     # wait for status to be not "in progress" any more
     request_status="in progress"
     while [[ "$request_status" == "in progress" ]]; do
        echo "waiting... "
        sleep 10
        request_status=$(requeststatus "$requestUUID")
        echo "$request_status"
     done
    
     echo notarization information:
     xcrun altool --notarization-info "$requestUUID" \
                 --username "$dev_account" \
                 --password "@env:ALPW"
     echo 
    
     if [[ $request_status != "success" ]]; then
        echo "## could not notarize $filepath"
        unset ALPW
        exit 1
     fi
     unset ALPW
echo
echo xcrun stapler staple "./build/Release/Meteorologist.app"
     xcrun stapler staple "./build/Release/Meteorologist.app"
echo
rm ./build/Release/Meteorologist.zip

if [ ! -f "${TEMPLATE_DMG}" ]
then
    echo bunzip2 --keep ${TEMPLATE_DMG}.bz2
         bunzip2 --keep ${TEMPLATE_DMG}.bz2
fi
cp ${TEMPLATE_DMG} ${WC_DMG}

echo
echo "------------------------ Copying to Disk Image -----------------------"
echo
echo "unpacking dmg template"

hdiutil attach "${WC_DMG}" -noautoopen

for i in ${SOURCE_FILES}; do
    echo "copying $i"
	rm -rf "${WC_DIR}/$(basename $i)";
	# read --password "Press [Enter] to continue..."
	cp -pr $i ${WC_DIR}/;
done

echo
echo "------------------------ Compressing disk image -----------------------"
echo
WC_DEV=`hdiutil info | grep "${WC_DIR}" | grep "/dev/disk" | awk '{print $1}'` && \
hdiutil detach ${WC_DEV} -quiet -force
rm -f "${MASTER_DMG}"
hdiutil convert "${WC_DMG}" -quiet -format UDZO -imagekey zlib-level=9 -o "${MASTER_DMG}"
rm -rf ${WC_DIR}
rm -f ${WC_DMG}

echo
echo "Disk Image Built: ${MASTER_DMG}"
echo
