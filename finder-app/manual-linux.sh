#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

export PATH=$PATH:/tmp/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p "$OUTDIR"/rootfs
cd "$OUTDIR"/rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p home/conf


echo "#debug Osama112233"
find / -name finder.sh 2>/dev/null
find / -name username.txt 2>/dev/null
find / -name assignment.txt 2>/dev/null
find / -name finder-test.sh 2>/dev/null
find / -name writer 2>/dev/null
find / -name autorun-qemu.sh 2>/dev/null
echo "#debug Osama332211"
cd /home/osama/Desktop/coursera/buildrootCourse/assignment-1-osamahariri/finder-app/



# TODO: Add library dependencies to rootfs
rtenvpath=/usr/local/arm-cross-compiler/install/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1
libmpath=/usr/local/arm-cross-compiler/install/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 
libresovpath=/usr/local/arm-cross-compiler/install/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2
libcpath=/usr/local/arm-cross-compiler/install/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6

echo ${rtenvpath}
echo ${libmpath}
echo ${libresovpath}
echo ${libcpath}

cp ${rtenvpath} "${OUTDIR}/rootfs/lib/"
cp ${libmpath} "${OUTDIR}/rootfs/lib64/"
cp ${libresovpath} "${OUTDIR}/rootfs/lib64/"
cp ${libcpath} "${OUTDIR}/rootfs/lib64/"


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    cd ${OUTDIR}/linux-stable 
    echo "#debug mrproper"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
    echo "#debug defconfig"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
    echo "#debug all"
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    echo "#debug modules"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules
    echo "#debug dtbs"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}



cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    touch ${OUTDIR}/busybox/makeLog.txt
    echo "#debug start distclean" # >> ${OUTDIR}/busybox/makeLog.txt
    make distclean #>> ${OUTDIR}/busybox/makeLog.txt
    echo "#debug start defconfig" #>> ${OUTDIR}/busybox/makeLog.txt
    make defconfig #>> ${OUTDIR}/busybox/makeLog.txt
else
    cd busybox
fi

# TODO: Make and install busybox
echo "#debug start make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} " #>> ${OUTDIR}/busybox/makeLog.txt
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} #>> ${OUTDIR}/busybox/makeLog.txt

echo "#debug start CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install" #>> ${OUTDIR}/busybox/makeLog.txt
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install >> ${OUTDIR}/busybox/makeLog.txt

cd ${OUTDIR}/rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# # TODO: Add library dependencies to rootfs
# cp "/tmp/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1" "${OUTDIR}/rootfs/lib/"
# cp "/tmp/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6" "${OUTDIR}/rootfs/lib64/"
# cp "/tmp/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2" "${OUTDIR}/rootfs/lib64/"
# cp "/tmp/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6" "${OUTDIR}/rootfs/lib64/"

# TODO: Make device nodes
sudo mknod -m 666 ./dev/null c 1 3
sudo mknod -m 666 ./dev/console c 5 1 

# TODO: Clean and build the writer utility
cd /home/osama/Desktop/coursera/buildrootCourse/assignment-1-osamahariri/finder-app/
make CROSS_COMPILE=aarch64-none-linux-gnu- clean
echo $PATH
make CROSS_COMPILE=aarch64-none-linux-gnu- all

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs

cp ./finder.sh ${OUTDIR}/rootfs/home/
cp -r ./conf/username.txt ${OUTDIR}/rootfs/home/conf/
cp -r ./conf/assignment.txt  ${OUTDIR}/rootfs/home/conf/
cp ./finder-test.sh ${OUTDIR}/rootfs/home/
cp ./writer ${OUTDIR}/rootfs/home/
cp ./autorun-qemu.sh ${OUTDIR}/rootfs/home/

# TODO: Chown the root directory

# TODO: Create initramfs.cpio.gz

cd ${OUTDIR}/rootfs
echo "change dir to : ${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
echo after create initramfs.cpio
cd ..
gzip -f initramfs.cpio

echo zip 