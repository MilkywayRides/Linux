#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 3: Building temporary system"

mkdir -p "$BUILD_DIR"
export PATH="$LFS/tools/bin:$PATH"

# Fix header errors before building
find $LFS/usr/include -name '*.h' -exec sed -i '/# error "Assumed value of MB_LEN_MAX wrong"/d' {} \; 2>/dev/null || true

# Ensure _POSIX_ARG_MAX is defined
if ! grep -q '_POSIX_ARG_MAX' $LFS/usr/include/limits.h 2>/dev/null; then
    cat >> $LFS/usr/include/limits.h << 'EOF'
#ifndef _POSIX_ARG_MAX
#define _POSIX_ARG_MAX 4096
#endif
EOF
fi

# Bash
build_bash() {
    ./configure --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(sh support/config.guess) \
        --without-bash-malloc
    make $MAKEFLAGS
    make DESTDIR=$LFS install
    ln -svf bash $LFS/usr/bin/sh
}

build_package "bash" "5.2.21" build_bash

# Coreutils
build_coreutils() {
    # Apply workarounds for cross-compilation
    cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
gl_cv_func_working_utimes=yes
EOF
    
    ./configure --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) \
        --enable-install-program=hostname \
        --enable-no-install-program=kill,uptime \
        --cache-file=config.cache \
        gl_cv_macro_MB_LEN_MAX_good=y
    make $MAKEFLAGS || make -j1
    make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/chroot $LFS/usr/sbin 2>/dev/null || true
}

build_package "coreutils" "9.4" build_coreutils

# Findutils
build_findutils() {
    cat > config.cache << EOF
gl_cv_func_working_mktime=yes
gl_cv_func_wcwidth_works=yes
EOF
    ./configure --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) \
        --cache-file=config.cache
    make $MAKEFLAGS || make -j1
    make DESTDIR=$LFS install
}

build_package "findutils" "4.9.0" build_findutils

# Grep
build_grep() {
    ./configure --prefix=/usr --host=$LFS_TGT
    make $MAKEFLAGS || make -j1
    make DESTDIR=$LFS install
}

build_package "grep" "3.11" build_grep

# Gzip
build_gzip() {
    ./configure --prefix=/usr --host=$LFS_TGT
    make $MAKEFLAGS || make -j1
    make DESTDIR=$LFS install
}

build_package "gzip" "1.13" build_gzip

# Tar
build_tar() {
    cat > config.cache << EOF
gl_cv_func_working_mktime=yes
EOF
    ./configure --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) \
        --cache-file=config.cache
    make $MAKEFLAGS || make -j1
    make DESTDIR=$LFS install
}

build_package "tar" "1.35" build_tar

# XZ
build_xz() {
    ./configure --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) \
        --disable-static \
        --docdir=/usr/share/doc/xz-5.4.6
    make $MAKEFLAGS || make -j1
    make DESTDIR=$LFS install
    rm -fv $LFS/usr/lib/liblzma.la
}

build_package "xz" "5.4.6" build_xz

log_success "Stage 3 completed"
