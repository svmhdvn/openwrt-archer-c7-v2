#!/bin/sh

openwrt_url='https://git.openwrt.org/openwrt/openwrt.git'
jobs=$(nproc)
top="$PWD"
if [ ! -d "$top/openwrt" ]; then
    git clone "$openwrt_url" "$top/openwrt"
fi
cd "$top/openwrt" || exit 1

git reset --hard origin/master
git pull
make distclean
git am "$top/patches/*.patch"
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
make download -j"$jobs"
make -j"$jobs"
