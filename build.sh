#!/bin/sh

set -e -x

openwrt_url='https://git.openwrt.org/openwrt/openwrt.git'
openwrt_tag='v23.05.0-rc3'
#openwrt_tag='origin/master'

cpus=$(nproc)
top="$PWD"

if [ ! -d "$top/openwrt" ]; then
    git clone --depth 1 "$openwrt_url" -b "$openwrt_tag" "$top/openwrt"
fi
cd "$top/openwrt"

git reset --hard "$openwrt_tag"

# TODO we only need to pull if we are building origin/master
#git pull origin master

#make dirclean
git am $top/patches/*.patch
./scripts/feeds update -a
./scripts/feeds install -a

make menuconfig

make -j"$cpus" download
make -j"$cpus" kernel_menuconfig CONFIG_TARGET=subtarget

# set all kernel modules to be built-in
find build_dir/target-mips_74kc_musl/linux-ath79_generic -name .config -type f | xargs sed -i -e "s/=m/=y/g"

make -j"$cpus"
cp bin/targets/ath79/generic/openwrt-ath79-generic-tplink_archer-c7-v2-squashfs-sysupgrade.bin "$top"
cp bin/targets/ath79/generic/sha256sums "$top"
