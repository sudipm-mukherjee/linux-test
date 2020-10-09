#!/bin/bash

NR_CPU=$(cat /proc/cpuinfo | grep ^processor | wc -l)
next_tag=`date +%Y%m%d`

make CC=clang $1
scripts/config -d CONFIG_DRM
scripts/config -d CONFIG_SOUND
scripts/config -d CONFIG_USB_SUPPORT
make CC=clang olddefconfig
make CC=clang clang-analyzer -j${NR_CPU} 2>&1 | tee report_err
source /codechecker/venv/bin/activate
export PATH=$PATH:/codechecker/CodeChecker/bin
report-converter -t clang-tidy -o report_out report_err
CodeChecker parse -e html -o ./reports_html report_out
sed -i "s/Go To Statistics<\/a>/Go To Statistics<\/a> Report for $next_tag/g" reports_html/index.html
