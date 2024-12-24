#!/bin/bash

rm -rf .repo/local_manifests
rm -rf device/samsung
rm -rf vendor/samsung
rm -rf hardware/samsung
rm -rf packages/apps/ViPER4AndroidFX
rm -rf vendor/extra
rm -rf kernel/samsung

repo init -u https://github.com/PixelOS-Fifteen/manifest.git -b fifteen --git-lfs

# local_manifests
git clone https://github.com/koko-07870/local_manifests --depth 1 -b pos-a72 .repo/local_manifests

# sync
/opt/crave/resync.sh

# keys
rm -rf vendor/aosp/signing/keys
git clone https://github.com/koko-07870/extra -b tmp vendor/aosp/signing/keys

# huh google
rm -rf out/soong/*.glob*

# Export
export BUILD_USERNAME=koko-07870
export BUILD_HOSTNAME=crave
echo "exported hostname"

# start
source build/envsetup.sh

breakfast a72q && make installclean && mka bacon -j$(nproc --all)

# gofile-upload
rm -rf upload.sh

wget -O upload.sh https://raw.githubusercontent.com/Sushrut1101/GoFile-Upload/refs/heads/master/upload.sh

bash upload.sh out/target/product/a52q/PixelOS_a72q*.zip

echo 