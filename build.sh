#!/bin/bash

set -e

# --- Configuration ---
PHP_SRC="$(pwd)/php-src"
INSTALL_DIR="$(pwd)/out"
NDK_PATH="$HOME/Library/Android/sdk/ndk/27.0.12077973"  # Update to your NDK path
API=24
ARCH=aarch64
HOST=aarch64-linux-android
HOST_TAG=darwin-x86_64  # Works better than darwin-aarch64 for some toolchains
TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_TAG"
SYSROOT="$TOOLCHAIN/sysroot"

# --- Environment ---
export PATH="$TOOLCHAIN/bin:$PATH"
export CC="$TOOLCHAIN/bin/${HOST}${API}-clang"
export CXX="$TOOLCHAIN/bin/${HOST}${API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export LD="$TOOLCHAIN/bin/ld.lld"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"

export CFLAGS="--sysroot=$SYSROOT -target $HOST$API -fPIE -fPIC"
export CPPFLAGS="--sysroot=$SYSROOT -target $HOST$API"
export LDFLAGS="--sysroot=$SYSROOT -target $HOST$API -pie -fPIE"

# --- Prepare PHP source ---
cd "$PHP_SRC"

# Clean only if Makefile exists
if [ -f Makefile ]; then
    make clean || true
    make distclean || true
fi

# Ensure buildconf exists
if [ ! -f buildconf ]; then
    ./buildconf --force
fi

# --- Configure ---
./configure \
    --prefix="$INSTALL_DIR" \
    --host="$HOST" \
    --disable-all \
    --enable-cgi \
    --enable-mbstring \
    --enable-session \
    --enable-tokenizer \
    --enable-ctype \
    --without-iconv \
    --without-pcre-jit \
    --with-sysroot="$SYSROOT" \
    ac_cv_func_malloc_0_nonnull=yes \
    ac_cv_func_realloc_0_nonnull=yes \
    ac_cv_file__dev_zero=yes \
    ac_cv_func_mmap_fixed_mapped=yes \
    ac_cv_func_memcmp_working=yes \
    ac_cv_have_long_long_format=yes

# --- Build ---
make -j$(sysctl -n hw.ncpu)
make install
