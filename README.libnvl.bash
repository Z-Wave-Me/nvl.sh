See nvl specification for description of strict levels.

libnvl.bash uses some bash features to support binary data in values.
If binary data is read into NVL_VAL (not to a file), then this data is corrupted;
but a next data read isn't broken.

* support NAME strict level 0 excluding \0
* support VAL strict level 0
