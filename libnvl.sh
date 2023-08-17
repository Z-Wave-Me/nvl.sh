#
# NVL CODE START
# NVL version 0, lib version 1.0
# NAME strict level 0 excluding \0 and newline
# VAL strict level 0 excluding \0
# Dependencies: wc
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

	if ! IFS= read -r line; then
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
	local line state len total_len

	state=0
	NVL_NAME=
	NVL_LEN=
	NVL_VAL=
	while IFS= read -r line; do
		NVL_LINENO=$((NVL_LINENO + 1))
		case $state in
		0)
			NVL_NAME=${line%%=*}
			if [ "$NVL_NAME" = "$line" ]; then
				NVL_ERRMSG="NVL: can't find name"
				return 1
			fi
			line="${line#*=}"
			NVL_LEN=${line%%:*}
			if [ "$NVL_LEN" = "$line" ]; then
				NVL_ERRMSG="NVL: can't find length"
				return 1
			fi
			NVL_VAL="${line#*:}"
			if [ -z "$NVL_LEN" ]; then
				return 0
			fi
			if ! [ "$NVL_LEN" -ge 0 ]; then
				NVL_ERRMSG="NVL: length should be positive integer"
				return 1
			fi
			len=`echo -n "$NVL_VAL" | wc -c`
			if [ "$len" -eq "$NVL_LEN" ]; then
				return 0
			fi
			total_len=$len
			state=1
			;;
		1)
			NVL_VAL="$NVL_VAL
$line"
			len=`echo -n "$line" | wc -c`
			total_len=$((total_len + len + 1))
			if [ "$total_len" -eq "$NVL_LEN" ]; then
				return 0
			fi
			;;
		esac
	done

	if [ "$NVL_LEN" ]; then
		NVL_ERRMSG="NVL: data is end before value is read(need $NVL_LEN, read $total_len)"
	fi

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
