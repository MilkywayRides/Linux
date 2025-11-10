#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 3: Building temporary system"

BUILD_DIR="${LFS}/build"

su - lfs -c "
export LFS=$LFS
export MAKEFLAGS='$MAKEFLAGS'
cd $BUILD_DIR
rm -rf *

tar -xf $LFS/sources/bash-${BASH_VER}.tar.gz
cd bash-${BASH_VER}
./configure --prefix=/usr --host=\$LFS_TGT --without-bash-malloc
make \$MAKEFLAGS && make DESTDIR=\$LFS install
ln -sf bash \$LFS/usr/bin/sh
ln -sf ../usr/bin/bash \$LFS/bin/bash
ln -sf bash \$LFS/bin/sh
cd $BUILD_DIR && rm -rf bash-*

tar -xf $LFS/sources/coreutils-${COREUTILS_VER}.tar.xz
cd coreutils-${COREUTILS_VER}
./configure --prefix=/usr --host=\$LFS_TGT --enable-install-program=hostname
make \$MAKEFLAGS
make DESTDIR=\$LFS install
mv -v \$LFS/usr/bin/chroot \$LFS/usr/sbin/ 2>/dev/null || true
cd $BUILD_DIR && rm -rf coreutils-*

tar -xf $LFS/sources/findutils-4.9.0.tar.xz
cd findutils-4.9.0
./configure --prefix=/usr --host=\$LFS_TGT
make \$MAKEFLAGS && make DESTDIR=\$LFS install
cd $BUILD_DIR && rm -rf findutils-*

tar -xf $LFS/sources/grep-3.11.tar.xz
cd grep-3.11
./configure --prefix=/usr --host=\$LFS_TGT
make \$MAKEFLAGS && make DESTDIR=\$LFS install
cd $BUILD_DIR && rm -rf grep-*

tar -xf $LFS/sources/tar-1.35.tar.xz
cd tar-1.35
./configure --prefix=/usr --host=\$LFS_TGT
make \$MAKEFLAGS && make DESTDIR=\$LFS install
cd $BUILD_DIR && rm -rf tar-*
"

log_success "Stage 3 completed"
