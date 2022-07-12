#!/bin/sh

set -e -x

openwrt_url='https://git.openwrt.org/openwrt/openwrt.git'
openwrt_tag='v22.03.0-rc5'

# TODO parse this from within openwrt itself
kernel_version='5.10.127'

cpus=$(nproc)
top="$PWD"

if [ ! -d "$top/openwrt" ]; then
    git clone "$openwrt_url" -b "$openwrt_tag" "$top/openwrt"
fi
cd "$top/openwrt"

git reset --hard "$openwrt_tag"

# TODO we only need to pull if we are building origin/master
# git pull

#make dirclean
git am $top/patches/*.patch
./scripts/feeds update -a
./scripts/feeds install -a
make -j"$cpus" download
make -j"$cpus" menuconfig
make -j"$cpus" kernel_menuconfig CONFIG_TARGET=subtarget

# set all kernel modules to be built-in
sed -i -e "s/=m/=y/g" "build_dir/target-mips_74kc_musl/linux-ath79_generic/linux-$kernel_version/.config"

make -j"$cpus"
cp targets/ath79/generic/openwrt-ath79-generic-tplink_archer-c7-v2-squashfs-sysupgrade.bin "$top"
