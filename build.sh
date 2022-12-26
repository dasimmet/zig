#!/usr/bin/env bash

set -ex

LLVM_VERSION="15.0.6"
LLVM_FILENAME="clang+llvm-$LLVM_VERSION-x86_64-linux-gnu-ubuntu-18.04"

DIR="$(dirname $0)"
mkdir -p "$DIR/zig-cache"
[ -f $DIR/zig-cache/$LLVM_FILENAME.tar.xz ] || (
    cd "$DIR/zig-cache/"
    curl -OL "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/$LLVM_FILENAME.tar.xz"
)

[ -d "$DIR/zig-cache/$LLVM_FILENAME" ] || (
    cd "$DIR/zig-cache/"
    tar -xvf $LLVM_FILENAME.tar.xz
)
#     -Denable-llvm \
#     -freference-trace \
#     -Dtarget="x86_64-linux-gnu" \
#     -Dcpu=native \
#     -Drelease \
#     -Dstrip \
#     --search-prefix /usr/lib/llvm-15 \

time zig build \
    --search-prefix "$PWD/zig-cache/$LLVM_FILENAME" \
    --zig-lib-dir lib \
    -Dstatic-llvm \
    -Drelease \
