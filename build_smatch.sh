#!/bin/bash

make $1
scripts/config -d CONFIG_DRM
scripts/config -d CONFIG_SOUND
scripts/config -d CONFIG_USB_SUPPORT
make olddefconfig
/smatch/smatch_scripts/build_kernel_data.sh
mkdir backup
cp smatch_db.sqlite backup/.
cp -r /smatch/smatch_data backup/.
tar -cjvf backup.tar.bz2 backup
ls -lh backup.tar.bz2
