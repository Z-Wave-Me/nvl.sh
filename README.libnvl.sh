See nvl specification for description of strict levels.

libnvl.sh uses as small set of shell features as possible and tries to be
compatible with any POSIX shell, but don't support binary data in a
value("VAL strict level 0 excluding \0"). If binary data is read, then this
data is corrupted and all data after it is corrupted too. This can happen
at nvl_header_read call too.

* support NAME strict level 0 excluding \0 and newline
* support VAL strict level 0 excluding \0

Shortly, use this implementation only for text-only data.

Dependencies: wc.
