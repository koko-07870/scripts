#!/bin/bash
function compile()
{
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 20G
TANGGAL=$(date +"%Y%m%d-%H")
export ARCH=arm64
export KBUILD_BUILD_HOST=linux-build
export KBUILD_BUILD_USER="koko"
clangbin=clang/bin/clang
if ! [ -a $clangbin ]; then
wget -O toolchain.tar.gz https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r530567.tar.gz
mkdir -p ${PWD}/clang
tar -xzf toolchain.tar.gz -C ${PWD}/clang
rm -rf toolchain.tar.gz
fi
rm -rf anykernel
make O=out ARCH=arm64 vendor/pixelos-a72q_defconfig
PATH="${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      AR=llvm-ar \
                      NM=llvm-nm \
                      STRIP=llvm-strip \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump\
                      CROSS_COMPILE=aarch64-linux-gnu-\
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      LD=ld.lld \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}
function zupload()
{
zimage=out/arch/arm64/boot/Image.gz
if ! [ -a $zimage ];
then
echo  " Failed To Compile Kernel"
else
echo -e " Kernel Compile Successful"
git clone --depth=1 https://github.com/koko-07870/AnyKernel3.git -b master anykernel
cp out/arch/arm64/boot/Image.gz anykernel
cd anykernel
zip -r9 Spark-2.0-a72q-${TANGGAL}.zip *
cd ../
fi
}
compile
zupload
