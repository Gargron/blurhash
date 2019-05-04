require 'mkmf'

$CFLAGS += ' -std=c99 -lm'
create_makefile 'encode'
