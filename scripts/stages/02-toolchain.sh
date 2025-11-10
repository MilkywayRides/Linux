#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 2: Building cross-toolchain"

SOURCES="${SCRIPT_DIR}/sources"
BUILD_DIR="${LFS}/build"

umount -R $LFS/proc 2>/dev/null || true
umount -R $LFS/sys 2>/dev/null || true
umount -R $LFS/dev 2>/dev/null || true

mkdir -p $LFS/usr/include
chmod -R 755 $SOURCES
chown -R lfs:lfs $BUILD_DIR $SOURCES 2>/dev/null || true
chown -R lfs:lfs $LFS 2>/dev/null || true

su - lfs -c "
export LFS=$LFS
export LFS_TGT=$LFS_TGT
export MAKEFLAGS='$MAKEFLAGS'
cd $BUILD_DIR
rm -rf *

tar -xf ${SOURCES}/binutils-${BINUTILS_VER}.tar.xz
mkdir binutils-build && cd binutils-build
../binutils-${BINUTILS_VER}/configure --prefix=\$LFS/tools --with-sysroot=\$LFS \
    --target=\$LFS_TGT --disable-nls --disable-werror
make \$MAKEFLAGS && make install
cd $BUILD_DIR && rm -rf binutils-*

tar -xf ${SOURCES}/gcc-${GCC_VER}.tar.xz
cd gcc-${GCC_VER}
mkdir -p ../gcc-build && cd ../gcc-build
../gcc-${GCC_VER}/configure --target=\$LFS_TGT --prefix=\$LFS/tools \
    --with-sysroot=\$LFS --without-headers --enable-languages=c,c++ \
    --disable-multilib --disable-shared
make \$MAKEFLAGS && make install
cd $BUILD_DIR && rm -rf gcc-*

tar -xf ${SOURCES}/linux-${LINUX_VER}.tar.xz
cd linux-${LINUX_VER}
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include \$LFS/usr/
cd $BUILD_DIR && rm -rf linux-*

tar -xf ${SOURCES}/glibc-${GLIBC_VER}.tar.xz
mkdir -p glibc-build && cd glibc-build
../glibc-${GLIBC_VER}/configure --prefix=/usr --host=\$LFS_TGT \
    --build=\$(../glibc-${GLIBC_VER}/scripts/config.guess) \
    --with-headers=\$LFS/usr/include --disable-nscd
make \$MAKEFLAGS && make DESTDIR=\$LFS install
cd $BUILD_DIR && rm -rf glibc-*
"

log_success "Stage 2 completed"
