#
# NVL CODE START
# NVL version 0, lib version 1.0
# NAME strict level 0 excluding \0
# VAL strict level 0
# Dependencies: wc, dd
#


nvl_reset()
{
	NVL_NAME=
	NVL_LEN=
	NVL_VAL=
	NVL_LINENO=1
	NVL_ERRMSG=
}
nvl_reset

nvl_header_read()
{
	local line

	nvl_reset

	if ! IFS= read -r -n5 line; then
		if [ -z "$line" ]; then
			return 1
		fi
	fi
	NVL_LINENO=$((NVL_LINENO + 1))
	if [ "$line" = "NVL0" ]; then
		return 0
	fi
	NVL_ERRMSG="NVL: there is no nvl formatted data"
	return 1
}

nvl_header_write()
{
	echo "NVL0"
}

nvl_rec_read()
{
	local cnt fname

	NVL_NAME=
	NVL_LEN=
	NVL_VAL=
	if ! IFS= read -r -d= NVL_NAME; then
		if [ "$NVL_NAME" ]; then
			NVL_ERRMSG="NVL: can't find name"
		fi
		return 1
	fi

	if ! IFS= read -r -d: NVL_LEN; then
		NVL_ERRMSG="NVL: $NVL_NAME: can't find length"
		return 1
	fi

	if [ -z "$NVL_LEN" ]; then
		IFS= read -r NVL_VAL
		NVL_LINENO=$((NVL_LINENO + 1))
		fname=`_nvl_get_keyval "$NVL_NAME" "$@"`
		if [ "$fname" ]; then
			echo -n "$NVL_VAL" > "$fname"
			NVL_VAL=""
		fi
		return 0
	fi

	if ! [ "$NVL_LEN" -ge 0 ]; then
		NVL_ERRMSG="NVL: $NVL_NAME: length should be positive integer"
		return 1
	fi
	fname=`_nvl_get_keyval "$NVL_NAME" "$@"`
	if [ "$fname" ]; then
		if ! dd of="$fname" bs=1 count=$NVL_LEN status=none; then
			NVL_ERRMSG="NVL: $NVL_NAME: can't save the value to the file '$fname'"
			return 1
		fi
		cnt=`wc -l "$fname"`
		cnt=${cnt%% *}
	else
		NVL_VAL=`dd bs=1 count=$NVL_LEN status=none; echo -n E`
		if [ $? -ne 0 ]; then
			NVL_ERRMSG="NVL: $NVL_NAME: can't read the value"
			return 1
		fi
		NVL_VAL=${NVL_VAL%E}
		cnt=`echo -n "$NVL_VAL" | wc -l`
	fi
	NVL_LINENO=$((NVL_LINENO + cnt))

	# Read the last newline
	read -r -d "" -N1 cnt
	if [ $? -ne 0 ]; then
		NVL_ERRMSG="NVL: $NVL_NAME: can't read newline after value"
		return 1
	fi
	if [ "$cnt" != "
" ]; then
		NVL_ERRMSG="NVL: $NVL_NAME: there is no newline after value"
		return 1
	fi

	NVL_LINENO=$((NVL_LINENO + 1))

	return 0
}

_nvl_get_keyval()
{
	local kv key want

	want="$1"
	shift

	for kv in "$@"; do
		key="${kv%%=*}"
		if [ "$key" = "$want" ] || [ "$key" = "*" ]; then
			echo "${kv#*=}"
			return 0
		fi
	done

	echo ""
	return 1
}

nvl_rec_write()
{
	local N=$1
	local V=$2

	if [ "${N#*=}" != $N ]; then
		NVL_ERRMSG="NVL: name shouldn't contain '=': '$N'"
		return 1
	fi

	echo "$N=`echo $V | wc -c`:$V"

	return 0
}

nvl_rec_write_from_file()
{
	local N=$1
	local V=$2

	if [ "${N#*=}" != $N ]; then
		NVL_ERRMSG="NVL: name shouldn't contain '=': '$N'"
		return 1
	fi

	echo -n "$N="`wc -c "$V"`:
	if ! cat "$V"; then
		NVL_ERRMSG="NVL: can't write a value from a file '$V'"
		return 1
	fi

	return 0
}

#
# NVL CODE END
#
