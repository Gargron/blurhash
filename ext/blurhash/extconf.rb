require 'mkmf'

$CFLAGS += ' -std=c99 -lm'

create_makefile 'blurhash_ext'
