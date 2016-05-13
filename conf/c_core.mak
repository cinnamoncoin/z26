
# Normal users shouldn't touch this file. Release versions of z26
# are currently built with C_CORE empty. Enabling these options is
# only recommended if you're actually going to help debug them when
# they do broken things :)

# Use the experimental C core?
# So far, only a few routines have been ported to C. 95% of
# the z26 core code is still x86 asm, so this option is only useful
# to z26 developers.

# To use C versions of all functions:
# C_CORE=-DC_INITDATA -DC_INITSERV -DC_TIAGRAPH -DC_SQVARS -DC_INITSQ -DC_SQSTORE -DC_QSBYTES -DC_QSBYTE -DC_SQTEST -DC_TIAPROC -DC_RANDRIOT -DC_POSGAME -DC_TIASND -DC_BANKVARS -DC_INITCPUH -DC_INITSPATH -DC_SETUPBANKS

# NOTE: -DC_TIASND doesn't fully work yet
# NOTE: -DC_SETUPBANKS doesn't work at all yet

# To use asm versions, no c_core.c code at all:
# C_CORE=

# You can pick & choose individual functions (see c_core.c)
C_CORE=
