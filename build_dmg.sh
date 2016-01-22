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

rm -rf ./build

echo ""
echo "------------------------ Building Project -----------------------"
echo ""
xcodebuild -configuration Release

if [ ! -f "${TEMPLATE_DMG}" ]
then
    bunzip2 --keep ${TEMPLATE_DMG}.bz2
fi
cp ${TEMPLATE_DMG} ${WC_DMG}

echo ""
echo "------------------------ Copying to Disk Image -----------------------"
echo ""
echo "unpacking dmg template"

hdiutil attach "${WC_DMG}" -noautoopen

for i in ${SOURCE_FILES}; do
    echo "copying $i"
	rm -rf "${WC_DIR}/$(basename $i)";
	cp -pr $i ${WC_DIR}/;
done

echo ""
echo "------------------------ Compressing disk image -----------------------"
echo ""
WC_DEV=`hdiutil info | grep "${WC_DIR}" | grep "/dev/disk" | awk '{print $1}'` && \
hdiutil detach ${WC_DEV} -quiet -force
rm -f "${MASTER_DMG}"
hdiutil convert "${WC_DMG}" -quiet -format UDZO -imagekey zlib-level=9 -o "${MASTER_DMG}"
rm -rf ${WC_DIR}
rm -f ${WC_DMG}

echo ""
echo "Disk Image Built: ${MASTER_DMG}"
echo ""
