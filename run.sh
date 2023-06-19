#!/bin/sh

BASE_DIR=/srv
EXTRACTED_DIR=${BASE_DIR}/extracted
MODULE_DIR=${BASE_DIR}/module_template
SHARE_DIR=${BASE_DIR}/share
CRDROID_BASE_VERSION=10
ROM_PART=product

if [ -z $1 ]; then
  echo "Specify device name as first argument"
  exit 1
fi

DEVICE_NAME=$1

if [ -z ${DEVICE_NAME} ]; then
  echo "Device name can't be empty"
  exit 1
fi

if [ ! -z $2 ]; then
  CRDROID_BASE_VERSION=$2
fi

echo "=============================="
echo "Device name:          ${DEVICE_NAME}"
echo "CrDroid base version: ${CRDROID_BASE_VERSION}"
echo "=============================="

ROM_SITE_URL=https://crdroid.net/${DEVICE_NAME}/${CRDROID_BASE_VERSION}
DEVICE_HTML_FILE=device_${DEVICE_NAME}.html

# Get download url
wget -O ${DEVICE_HTML_FILE} ${ROM_SITE_URL}

#ROM_URL=https://sourceforge.net/projects/crdroid/files/sweet/7.x/crDroidAndroid-11.0-20211114-sweet-v7.12.zip/download
ROM_URL=$(grep -Eo "(\"https://[^\"]+).+Download latest version" ${DEVICE_HTML_FILE} | sed -E "s#\"(https://[^\"]+).+#\1#")
echo ${ROM_URL}

if [ -z ${ROM_URL} ]; then
  echo "ERROR: ROM url not found. Check device name"
  exit 1
fi

ROM_FILENAME=$(echo ${ROM_URL} | sed -E 's#.+/([^/]+)/download#\1#')
ROM_VERSION=$(echo ${ROM_FILENAME} | sed -E 's/.+-v([0-9]+.[0-9]+).+/\1/')
ROM_DATE=$(echo ${ROM_FILENAME} | sed -E 's/.+-([0-9]{8})-.+/\1/')
MAGISK_MODULE_VERSION=$(echo ${ROM_DATE} | sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2})/\1-\2-\3/')
MAGISK_MODULE_ZIP=aosp-crdroid-dialer-${ROM_VERSION}-${ROM_DATE}-magisk.zip

# Download ROM
if [ ! -f ${SHARE_DIR}/${ROM_FILENAME} ]; then
  wget -O ${SHARE_DIR}/${ROM_FILENAME} ${ROM_URL}
fi

# Extract ROM files
mkdir -p ${EXTRACTED_DIR}
${BASE_DIR}/rom-part-unpack.sh ${SHARE_DIR}/${ROM_FILENAME} ${ROM_PART} ${EXTRACTED_DIR}

# Mount ROM files
cd ${EXTRACTED_DIR}
mkdir -p ${EXTRACTED_DIR}/${ROM_PART}
mount -o ro ${ROM_PART}.new.img ${EXTRACTED_DIR}/${ROM_PART}/

# Copy files from ROM
mkdir -p ${MODULE_DIR}/system/product/etc/permissions
cp ${EXTRACTED_DIR}/product/etc/permissions/privapp_whitelist_com.android.dialer-ext.xml /srv/module_template/system/product/etc/permissions/
cp ${EXTRACTED_DIR}/product/etc/permissions/com.android.dialer.xml /srv/module_template/system/product/etc/permissions/

mkdir -p ${MODULE_DIR}/system/product/priv-app/Dialer
cp ${EXTRACTED_DIR}/product/priv-app/Dialer/Dialer.apk /srv/module_template/system/product/priv-app/Dialer/

# Create Magisk module
cd ${MODULE_DIR}
sed -i -E "s/version=[0-9\-]+/version=${MAGISK_MODULE_VERSION}/" module.prop
sed -i -E "s/versionCode=[0-9]+/versionCode=${ROM_DATE}/" module.prop
sed -i -E "s/description=(.+) [0-9.]+ [0-9]+/description=\1 ${ROM_VERSION} ${ROM_DATE}/" module.prop

zip -r9 ${MAGISK_MODULE_ZIP} *
rm -f ${SHARE_DIR}/${MAGISK_MODULE_ZIP}
mv ${MAGISK_MODULE_ZIP} ${SHARE_DIR}
