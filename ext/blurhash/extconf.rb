require 'mkmf'

append_cflags(['-std=c99', '-lm'])

create_makefile 'blurhash_ext'
