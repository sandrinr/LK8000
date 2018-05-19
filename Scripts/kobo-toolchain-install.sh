#!/bin/sh
#
# File:   arm-tool-install.sh
# Author: Bruno de Lacheisserie
#
# Created on Jan 1, 2015, 6:39:30 PM
#

set -ex

[ -z "$TC"] && TC=arm-unknown-linux-gnueabi
[ -z "$BUILD_DIR" ] && BUILD_DIR=$HOME/tmp
[ -z "$TARGET_DIR" ] && TARGET_DIR=/opt/kobo/arm-unknown-linux-gnueabi

USER_PATH=$PATH

mkdir "$BUILD_DIR"
cd "$BUILD_DIR"

# install toolchain
#wget http://max.kellermann.name/download/xcsoar/devel/x-tools/x-tools-arm-i386-2013-12-11.tar.xz
#tar xJfC x-tools-arm-i386-2013-12-11.tar.xz /home/user
#export PATH=/home/user/x-tools/arm-unknown-linux-gnueabi/bin:$PATH

# install glibc
wget http://mirror.netcologne.de/gnu/libc/glibc-2.23.tar.gz
tar -xf glibc-2.23.tar.gz
mkdir glibcbuild
cd glibcbuild
../glibc-2.23/configure --host=$TC --target=$TC --prefix=$TARGET_DIR --enable-static-nss --enable-kernel=2.6.35 --disable-werror --disable-build-nscd --disable-nscd
make
sudo make install
cd ..
# Fix headers
sed -i 's%// .*%%' /opt/kobo/arm-unknown-linux-gnueabi/include/bits/string3.h

# install zlib ( 1.2.11 - 2017-01-15)
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -xvzf zlib-1.2.11.tar.gz 
cd zlib-1.2.11
CC=$TC-gcc CFLAGS="-O3 -march=armv7-a -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -funsafe-math-optimizations -funsafe-loop-optimizations" \
./configure --prefix=$TARGET_DIR
make all
sudo make install
cd ..

# install zziplib ( 0.13.62 - 2012-03-11)
wget http://liquidtelecom.dl.sourceforge.net/project/zziplib/zziplib13/0.13.62/zziplib-0.13.62.tar.bz2
tar xvjf zziplib-0.13.62.tar.bz2
mkdir zzipbuild
cd zzipbuild
CFLAGS="-O3 -march=armv7-a -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -funsafe-math-optimizations -funsafe-loop-optimizations" \
# Do not build docs
sed -i 's/ docs//g' ../zziplib-0.13.62/Makefile.in
../zziplib-0.13.62/configure --host=$TC --target=$TC --prefix=$TARGET_DIR --with-zlib
make all
sudo PATH=$USER_PATH:$PATH \
    make install
cd ..

# install boostlib ( 1.64.0 - 2017-04-19 )
wget https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz
tar xzf boost_1_64_0.tar.gz
cd boost_1_64_0
./bootstrap.sh
echo "using gcc : arm : $TC-g++ : cxxflags=-O3 -march=armv7-a -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -funsafe-math-optimizations -funsafe-loop-optimizations ;" > user-config.jam
set +e
sudo PATH=$USER_PATH:$PATH \
    ./bjam toolset=gcc \
           variant=release \
           link=shared \
           runtime-link=shared \
           --prefix=$TARGET_DIR \
           --without-python \
           --without-context \
           --without-coroutine \
           --without-coroutine2 \
           --user-config=user-config.jam \
           install
set -e
cd ..

# install libpng ( 1.6.34 - 2017-09-29 )
wget http://sourceforge.net/projects/libpng/files/libpng16/1.6.34/libpng-1.6.34.tar.gz
tar xzf libpng-1.6.34.tar.gz
mkdir libpng-build
cd libpng-build
../libpng-1.6.34/configure \
    --host=$TC \
    CC=$TC-gcc \
    AR=$TC-ar \
    STRIP=$TC-strip \
    RANLIB=$TC-ranlib \
    CPPFLAGS="-O3 -march=armv7-a -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -funsafe-math-optimizations -funsafe-loop-optimizations -I$TARGET_DIR/include" \
    LDFLAGS="-L$TARGET_DIR/lib"  \
    --prefix=$TARGET_DIR 
make
sudo PATH=$USER_PATH:$PATH \
    make install
cd ..

# install freetype2 ( 2.7.1 - 2016-12-30 )
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.7.1.tar.gz
tar xzf freetype-2.7.1.tar.gz
mkdir freetype-build
cd freetype-build
CFLAGS="-O3 -march=armv7-a -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -funsafe-math-optimizations -funsafe-loop-optimizations" \
LDFLAGS="-L$TARGET_DIR/lib"  \
../freetype-2.7.1/configure \
    --host=$TC \
    --target=$TC \
    --prefix=$TARGET_DIR \
    --without-harfbuzz \
    PKG_CONFIG_LIBDIR=$TARGET_DIR/lib/pkgconfig
make
sudo PATH=$USER_PATH:$PATH \
    make install
cd ..

# install Geographiclib ( 1.48 - 2017-04-09 )
wget https://netcologne.dl.sourceforge.net/project/geographiclib/distrib/GeographicLib-1.48.tar.gz
tar xzf GeographicLib-1.48.tar.gz
mkdir GeographicLib-build
cd GeographicLib-build
CFLAGS="-O3 -march=armv7-a -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -funsafe-math-optimizations -funsafe-loop-optimizations" \
LDFLAGS="-L$TARGET_DIR/lib"  \
../GeographicLib-1.48/configure \
    --host=$TC \
    --prefix=$TARGET_DIR \
    PKG_CONFIG_LIBDIR=$TARGET_DIR/lib/pkgconfig
make
sudo PATH=$USER_PATH:$PATH \
    make install
cd ..
