require 'mkmf'

$CFLAGS += ' -std=c99 -lm'

# Don't link to libruby
$LIBRUBYARG = nil

create_makefile 'blurhash_ext'
