. libnvl.sh

nvl_header_read
[ $? -ne 0 ] && { echo $NVL_ERRMSG >&2; exit 1; }

while nvl_rec_read; do
	echo "$NVL_NAME = $NVL_VAL"
done

if [ "$NVL_ERRMSG" ]; then
	echo "DATA:$NVL_LINENO: $NVL_ERRMSG" >&2
	exit 1
fi