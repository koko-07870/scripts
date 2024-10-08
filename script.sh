#!/bin/bash

rm -rf .repo/local_manifests
rm -rf device/samsung
rm -rf kernel/samsung
rm -rf vendor/samsung
rm -rf hardware/samsung
rm -rf vendor/extra
rm -rf packages/apps/Updates

echo "----------------DELETED DIRECTORIES----------------"


repo init -u https://github.com/PixelOS-AOSP/manifest.git -b fourteen --git-lfs --depth=1

echo "--------------REPO INITIALISED---------------"


# Clone local_manifests repository
git clone https://github.com/koko-07870/local_manifests --depth 1 -b pos .repo/local_manifests
if [ ! 0 == 0 ]
    then curl -o .repo/local_manifests https://github.com/koko-07870/local_manifests.git
fi

echo "-----------------CLONED local manifest-------------------"


# Resync
/opt/crave/resync.sh

echo "---------------RESYNCED-----------------"


# Upgrade System

sudo apt update && sudo apt upgrade -y

echo "---------------SYSTEM UPGRADED-------------------"


# Clone Keys
DIRKEYS="vendor/aosp/signing/keys"
# Check if the directory exists
if [ -d "$DIRKEYS" ]; then
    echo "Directory $DIRKEYS exists. Deleting it..."
    rm -rf "$DIRKEYS"
    echo "Directory deleted."
else
    echo "Directory $DIRKEYS does not exist. No need to delete."
fi

#get keys
git clone https://github.com/koko-07870/scripts -b tmp vendor/aosp/signing/
echo "---------------CLONED KEYS-----------------"


TARGET_FILE1="vendor/aosp/build/core/main_version.mk"
# Check if exists
if [ -x "$TARGET_FILE1" ]; then
    echo "File $TARGET_FILE1 exists. Deleting it..."
    rm -rf "$TARGET_FILE1"
    echo "main_version.mk deleted."
else
    echo "Directory $TARGET_FILE1 does not exist. No need to delete."
fi

#get main_version.mk
wget https://raw.githubusercontent.com/koko-07870/scripts/refs/heads/new/main_version.mk -P vendor/aosp/build/core/

echo "--------------OTA1 CLONED--------------"


TARGET_FILE2="vendor/aosp/config/ota.mk"
# Check if exists
if [ -x "$TARGET_FILE2" ]; then
    echo "File $TARGET_FILE2 exists. Deleting it..."
    rm -rf "$TARGET_FILE2"
    echo "ota.mk deleted."
else
    echo "Directory $TARGET_FILE2 does not exist. No need to delete."
fi

#get ota.mk
wget https://github.com/koko-07870/scripts/blob/new/ota.mk -P vendor/aosp/config/

echo "--------------ota.mk cloned--------------"


# Lunch
export BUILD_USERNAME=koko-07870 
export BUILD_HOSTNAME=crave
source build/envsetup.sh
lunch aosp_a52q-ap2a-userdebug
make installclean
mka bacon

echo "--------------BUILD STARTED--------------"
