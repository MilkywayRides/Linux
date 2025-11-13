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
    # GCC dependencies are built separately in real LFS
    # For minimal build, we skip GMP/MPFR/MPC and use system versions
    
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
    make $MAKEFLAGS || make -j1
    make install
    
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/install-tools/include/limits.h 2>/dev/null || true
}

build_package "gcc" "$GCC_VER" build_gcc_pass1

# Linux Headers
log "Installing Linux API headers..."
cd "$BUILD_DIR"

# Find Linux source
linux_src=""
if [ -f "$LFS/sources/linux-${LINUX_VER}.tar.xz" ]; then
    linux_src="$LFS/sources/linux-${LINUX_VER}.tar.xz"
elif [ -f "${SOURCES_DIR}/linux-${LINUX_VER}.tar.xz" ]; then
    linux_src="${SOURCES_DIR}/linux-${LINUX_VER}.tar.xz"
else
    die "Linux source not found"
fi

tar -xf "$linux_src"
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
    
    # Fix MB_LEN_MAX in all glibc headers
    sed -i 's/#if __GLIBC_USE (FORTIFY_LEVEL) > 0/#if 0/' $LFS/usr/include/bits/wchar2.h
    sed -i 's/#if __GLIBC_USE (FORTIFY_LEVEL) > 0/#if 0/' $LFS/usr/include/bits/stdlib.h
}

build_package "glibc" "$GLIBC_VER" build_glibc

# GCC Pass 2 (libstdc++)
log "Building libstdc++..."
cd "$BUILD_DIR"

# Find GCC source
gcc_src=""
if [ -f "$LFS/sources/gcc-${GCC_VER}.tar.xz" ]; then
    gcc_src="$LFS/sources/gcc-${GCC_VER}.tar.xz"
elif [ -f "${SOURCES_DIR}/gcc-${GCC_VER}.tar.xz" ]; then
    gcc_src="${SOURCES_DIR}/gcc-${GCC_VER}.tar.xz"
else
    die "GCC source not found"
fi

tar -xf "$gcc_src"
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
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la 2>/dev/null || true
cd "$BUILD_DIR" && rm -rf "gcc-${GCC_VER}"

log_success "Stage 2 completed"
