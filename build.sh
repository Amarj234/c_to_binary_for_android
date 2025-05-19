#!/bin/bash

set -e

# --- Configuration ---
PHP_SRC="$(pwd)/php-src"
INSTALL_DIR="$(pwd)/out"
NDK_PATH="$(pwd)/ndk"
API=24
ARCH=aarch64
HOST=aarch64-linux-android
HOST_TAG=darwin-aarch64  # ✅ Apple Silicon (M1/M2) uses this
TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_TAG"
SYSROOT="$TOOLCHAIN/sysroot"

# --- Environment ---
export PATH="$TOOLCHAIN/bin:$PATH"
export CC="$TOOLCHAIN/bin/${HOST}${API}-clang"
export CXX="$TOOLCHAIN/bin/${HOST}${API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export AS="$TOOLCHAIN/bin/llvm-as"
export LD="$TOOLCHAIN/bin/ld.lld"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"
export NM="$TOOLCHAIN/bin/llvm-nm"
export OBJDUMP="$TOOLCHAIN/bin/llvm-objdump"
export READELF="$TOOLCHAIN/bin/llvm-readelf"

export CFLAGS="--sysroot=$SYSROOT -fPIE -fPIC"
export LDFLAGS="--sysroot=$SYSROOT -pie -fPIE"

# --- Prepare PHP source ---
cd "$PHP_SRC"
make clean || true
make distclean || true
rm -f config.cache configure

./buildconf --force
BUILD=$(uname -m)-apple-darwin

# --- Configure ---
./configure \
  --prefix="$INSTALL_DIR" \
  --host="$HOST" \
  --build="$BUILD" \
  --disable-all \
  --enable-cgi \
  --enable-mbstring \
  --enable-session \
  --enable-tokenizer \
  --enable-ctype \
  --without-iconv \
  --disable-dns \
  ac_cv_func_malloc_0_nonnull=yes \
  ac_cv_func_realloc_0_nonnull=yes \
  ac_cv_file__dev_zero=yes \
  ac_cv_func_mmap_fixed_mapped=yes \
  ac_cv_func_memcmp_working=yes \
  ac_cv_have_long_long_format=yes

# --- Build ---
make -j$(sysctl -n hw.ncpu)
make install
