#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 2: Building cross-toolchain"

mkdir -p "$BUILD_DIR"
export PATH="$LFS/tools/bin:$PATH"

# Binutils Pass 1
build_binutils_pass1() {
    mkdir build && cd build
    ../configure --prefix=$LFS/tools \
        --with-sysroot=$LFS \
        --target=$LFS_TGT \
        --disable-nls --disable-werror
    make $MAKEFLAGS
    make install
}

build_package "binutils" "$BINUTILS_VER" build_binutils_pass1

# GCC Pass 1
build_gcc_pass1() {
    tar -xf $LFS/sources/gmp-*.tar.* && mv gmp-* gmp
    tar -xf $LFS/sources/mpfr-*.tar.* && mv mpfr-* mpfr 2>/dev/null || true
    tar -xf $LFS/sources/mpc-*.tar.* && mv mpc-* mpc 2>/dev/null || true
    
    mkdir build && cd build
    ../configure --target=$LFS_TGT \
        --prefix=$LFS/tools \
        --with-glibc-version=2.39 \
        --with-sysroot=$LFS \
        --with-newlib \
        --without-headers \
        --disable-nls --disable-shared \
        --disable-multilib --disable-threads \
        --disable-libatomic --disable-libgomp \
        --disable-libquadmath --disable-libssp \
        --disable-libvtv --disable-libstdcxx \
        --enable-languages=c,c++
    make $MAKEFLAGS
    make install
    
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/install-tools/include/limits.h
}

build_package "gcc" "$GCC_VER" build_gcc_pass1

# Linux Headers
log "Installing Linux API headers..."
cd "$BUILD_DIR"
tar -xf "$LFS/sources/linux-${LINUX_VER}.tar.xz"
cd "linux-${LINUX_VER}"
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr/
cd "$BUILD_DIR" && rm -rf "linux-${LINUX_VER}"

# Glibc
build_glibc() {
    mkdir build && cd build
    echo "rootsbindir=/usr/sbin" > configparms
    ../configure --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(../scripts/config.guess) \
        --enable-kernel=4.19 \
        --with-headers=$LFS/usr/include \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib
    make $MAKEFLAGS
    make DESTDIR=$LFS install
    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
}

build_package "glibc" "$GLIBC_VER" build_glibc

# GCC Pass 2 (libstdc++)
log "Building libstdc++..."
cd "$BUILD_DIR"
tar -xf "$LFS/sources/gcc-${GCC_VER}.tar.xz"
cd "gcc-${GCC_VER}"
mkdir build && cd build
../libstdc++-v3/configure --host=$LFS_TGT \
    --build=$(../config.guess) \
    --prefix=/usr \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/${GCC_VER}
make $MAKEFLAGS
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
cd "$BUILD_DIR" && rm -rf "gcc-${GCC_VER}"

log_success "Stage 2 completed"
