#!/bin/bash

if [ "$1" == "clang" ]; then

	NR_CPU=$(cat /proc/cpuinfo | grep ^processor | wc -l)
	next_tag=`date +%Y%m%d`
	make CC=clang $2
	scripts/config -d CONFIG_DRM
	scripts/config -d CONFIG_SOUND
	scripts/config -d CONFIG_USB_SUPPORT
	make CC=clang olddefconfig
	make CC=clang clang-analyzer -j${NR_CPU} 2>&1 | tee clang_log

elif [ "$1" == "smatchdb" ]; then

	make $2
	if [ -e backup.tar.bz2 ]; then
		tar -xjvf backup.tar.bz2
		cp -r smatchbackup/smatch_data /smatch/.
		cp smatchbackup/smatch_db.sqlite .
	else
		echo "backup.tar.bz2 not found"
	fi
	scripts/config -d CONFIG_DRM
	scripts/config -d CONFIG_SOUND
	scripts/config -d CONFIG_USB_SUPPORT
	make olddefconfig
	/smatch/smatch_scripts/build_kernel_data.sh
	mkdir -p smatchbackup
	rm -rf smatchbackup/*
	cp smatch_db.sqlite smatchbackup/. || true
	cp -r /smatch/smatch_data smatchbackup/.
	tar -cjvf ./backup.tar.bz2 smatchbackup

elif [ "$1" == "smatch" ]; then

	make $2
	if [ -e backup.tar.bz2 ]; then
		tar -xjvf backup.tar.bz2
		cp -r smatchbackup/smatch_data /smatch/.
		cp smatchbackup/smatch_db.sqlite .
	else
		echo "backup.tar.bz2 not found"
	fi
	scripts/config -d CONFIG_DRM
	scripts/config -d CONFIG_SOUND
	scripts/config -d CONFIG_USB_SUPPORT
	make olddefconfig
	/smatch/smatch_scripts/test_kernel.sh
	mkdir -p smatchbackup
	rm -rf smatchbackup/*
	cp smatch_db.sqlite smatchbackup/. || true
	cp -r /smatch/smatch_data smatchbackup/.
	tar -cjvf ./backup.tar.bz2 smatchbackup

elif [ "$1" == "report" ]; then

	source /codechecker/venv/bin/activate
	export PATH=$PATH:/codechecker/CodeChecker/bin
	report-converter -t clang-tidy -o report_out clang_log
	report-converter -t smatch -o report_out smatch_warns.txt
	CodeChecker parse -e html -o ./reports_html report_out
	sed -i "s/Go To Statistics<\/a>/Go To Statistics<\/a> Report for $next_tag/g" reports_html/index.html
	cat smatch_warns.txt

fi
