#!/bin/sh

set -e -x

openwrt_url='https://git.openwrt.org/openwrt/openwrt.git'
openwrt_tag='v21.02.2'
cpus=$(nproc)
top="$PWD"

if [ ! -d "$top/openwrt" ]; then
    git clone "$openwrt_url" -b "$openwrt_tag" "$top/openwrt"
fi
cd "$top/openwrt"

git reset --hard "$openwrt_tag"

# TODO we only need to pull if we are building origin/master
# git pull

make dirclean
git am $top/patches/*.patch
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
make download -j"$cpus"
make -j"$cpus"
