#!/bin/sh

set -x
set -e

# Script assumes the presence of the following:
# s3cmd

ZIGDIR="$PWD"
TARGET="$ARCH-macos-none"
MCPU="baseline"
CACHE_BASENAME="zig+llvm+lld+clang-$TARGET-0.15.0-dev.233+7c85dc460"
PREFIX="$HOME/$CACHE_BASENAME"
ZIG="$PREFIX/bin/zig"

if [ ! -d "$PREFIX" ]; then
  cd $HOME
  curl -L -O "https://ziglang.org/deps/$CACHE_BASENAME.tar.xz"
  tar xf "$CACHE_BASENAME.tar.xz"
fi

cd $ZIGDIR

# Make the `zig version` number consistent.
# This will affect the cmake command below.
git fetch --unshallow || true
git fetch --tags

# Override the cache directories because they won't actually help other CI runs
# which will be testing alternate versions of zig, and ultimately would just
# fill up space on the hard drive for no reason.
export ZIG_GLOBAL_CACHE_DIR="$PWD/zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="$PWD/zig-local-cache"

mkdir build-debug
cd build-debug

PATH="$HOME/local/bin:$PATH" cmake .. \
  -DCMAKE_INSTALL_PREFIX="stage3-debug" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER="$ZIG;cc;-target;$TARGET;-mcpu=$MCPU" \
  -DCMAKE_CXX_COMPILER="$ZIG;c++;-target;$TARGET;-mcpu=$MCPU" \
  -DZIG_TARGET_TRIPLE="$TARGET" \
  -DZIG_TARGET_MCPU="$MCPU" \
  -DZIG_STATIC=ON \
  -DZIG_NO_LIB=ON \
  -GNinja

$HOME/local/bin/ninja install

stage3-debug/bin/zig build test docs \
  --zig-lib-dir "$PWD/../lib" \
  -Denable-macos-sdk \
  -Dstatic-llvm \
  -Dskip-non-native \
  --search-prefix "$PREFIX"
