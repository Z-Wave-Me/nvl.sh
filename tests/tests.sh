#!/bin/bash

. ./tests.utils

# "What to test" specification.
# LIB_FILE_NAME TESTS_FILES_POSTFIX SHELLNAME
WTSPEC="libnvl.sh sh sh
libnvl.bash bash bash"

ECODE=0
LIBSRC=
export LIBSRC
NL='
'
IFS_OLD="$IFS"

IFS="$NL"
for spec in $WTSPEC; do
	IFS="$IFS_OLD"
	libname=${spec%% *}
	spec=${spec#* }
	postfix=${spec%% *}
	spec=${spec#* }
	shellname=$spec
	echo
	echo ${libname}:
	LIBSRC="../$libname"

	for fname in `find . -name '*.test'-$postfix | sort`; do
		echo -n "$fname: "
		$shellname "$fname"
		ret=$?
		bsstr="\b\b"
		for i in `seq 1 ${#fname}`; do
			bsstr="${bsstr}\b"
		done
		echo -en "$bsstr"
		if [ $ret -eq 0 ]; then
			echo "OK   $fname"
		else
			echo "${COLOR_RED}FAIL${COLOR_RST} $fname"
			ECODE=1
		fi
	done
	IFS="$NL"
done

echo
if [ $ECODE -eq 0 ]; then
	echo "All tests are OK"
	exit 0
fi

echo "Some tests are FAIL"
exit 1
