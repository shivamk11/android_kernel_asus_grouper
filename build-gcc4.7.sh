#!/bin/bash
TOOLCHAIN="/home/shivam/development/arm-linux-androideabi-4.7/bin/arm-linux-androideabi"
MODULES_DIR="/home/shivam/development/modules"
ZIMAGE="/home/shivam/development/android_kernel_asus_grouper/arch/arm/boot/zImage"
KERNEL_DIR="/home/shivam/development/android_kernel_asus_grouper"
MKBOOTIMG="/home/shivam/boot-tools-falcon/tools/mkbootimg"
MKBOOTFS="/home/shivam/boot-tools-falcon/tools/mkbootfs"
DTBTOOL="/home/shivam/boot-tools-falcon/tools/dtbTool"
BUILD_START=$(date +"%s")
if [ -a $ZIMAGE ];
then
rm $ZIMAGE
rm $MODULES_DIR/*
fi
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN- tegra3_android_defconfig
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN- -j8
if [ -a $ZIMAGE ];
then
echo "Copying modules"
rm $MODULES_DIR/*
find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
echo "Stripping modules for size"
$TOOLCHAIN-strip --strip-unneeded *.ko
cd $KERNEL_DIR
$MKBOOTFS ramdisk/ > $KERNEL_DIR/ramdisk.cpio
cat $KERNEL_DIR/ramdisk.cpio | gzip > $KERNEL_DIR/root.fs
$MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs --base 0x10000000 --pagesize 2048 -o $KERNEL_DIR/boot.img
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
else
echo "Compilation failed! Fix the errors!"
fi
