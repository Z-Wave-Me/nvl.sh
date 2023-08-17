2023.07.26

          Named-Values List, version 0

Abstract

  This document describes the format used for Named-Values List.

Introduction

  NVL is a text format for data exchanging, where data is named values. Its
  intention is to be simple enough that it can be easily parsed with some
  shell script (bash, etc) and, in the same time, can handle a binary data
  in values.

Definition of NVL format

  NVL charset is utf-8, except cases where other charset
  is agreed between communicating parties. Any singlebyte charset based on
  ASCII (like cp1251 and so on) should work with any implementation of NVL
  which conform to this document.

  Every NVL data is prepended with a header. The header consists
  of a format mark ("NVL"), a format version ("0") and a newline
  char(0x0A). The header ABNF:

  HEADER = %x4E %x56 %x4C "0" LF    ; "NVL0"

  After the header, a data begins. A data is a list of named values.
  Each name-value pair ends with newline char(0x0A) and consists of
  a name, an optional value length and a value:

  NVLIST = *(NV LF)
  NV = NAME "=" [LEN] ":" VAL

  A name of a value can consist of any character except "=". It ends at
  first equal sign (not including it).

  After the equal sign, the optional length (in bytes) of the value begins.
  It is a string representation of a decimal number of bytes. I.e. for the
  length of 4 bytes there must be a character with code 52 ("4"). The length
  ends at first ":" character. The length of the value does not include colon
  character between length and value fields and does not include a newline
  character that terminates a name-value pair.

  After the colon character, the value begins. If the length of the value is
  ommited, then the value is one line long up to (but not including) the
  first newline character.

Example

  ~$ cat test.data
  NVL0
  USER=:name
  PASS=4:pass
  ~$ cat test.data  | od -Ad -tau1
  0000000   N   V   L   0  nl   U   S   E   R   =   :   n   a   m   e  nl
           78  86  76  48  10  85  83  69  82  61  58 110  97 109 101  10
  0000016   P   A   S   S   =   4   :   p   a   s   s  nl
           80  65  83  83  61  52  58 112  97 115 115  10
  0000028
  ~$

Recomendations

  Though NVL format don't insist that NAME must be handled in case-sensitive
  manner, this is a recomended way of NAME processing. But see implementation
  docs. May be some of it handle NAME in case-insensitive manner.

  NVL format doesn't impose any restrictions on NAME and VAL,
  besides that NAME mustn't include "=" char. Nevertheless it's better to
  use only a printable subset of utf-8 characters for NAME, if you want to
  use shell NVL implementations to process your data.

  Every NVL implementation is recomended to specify what characters is
  supported in NAME and in VAL. E.g.:

  * support NAME strict level 0 excluding \0 and newline
  * support VAL strict level 0 excluding \0

  Or:

  * support NAME strict level 1
  * support VAL strict level 1 including newline

  See Appendix A for strict levels definitions.

Appendix A. ABNF of NVL

  NVL general format (NAME strict level 0):

  DATA = HEADER NVLIST
  HEADER = %x4E %x56 %x4C "0" LF    ; "NVL0"
  NVLIST = *(NV LF)
  NV = NAME "=" [LEN] ":" VAL
  NAME = *(%x00-3C / %x3E-FF)    ; any char except "="
  LEN = 1*("0" / "1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9")
  VAL = *(%x00-FF)
  LF = %x0A

  NAME strict level 1:

  NAME = *(%x20-3C / %x3E-7E / %x80-FF)    ; any printable char except "="

  NAME strict level 2:

  NAME = *(%x20-3C / %x3E-7E)    ; any printable char from Basic Latin set
                                 ; except "="

  NAME strict level 3:

  NAME = (%x41-5A / %x64-7A) *(%x41-5A / %x64-7A / %x30-39 / %x5F )
         ; any of A-Z or a-z or 0-9 or "_" and started with a letter

Author's contacts

  Oleg Nemanov
  Email: lego12239@yandex.ru
  Git: https://github.com/lego12239/nvl.spec
