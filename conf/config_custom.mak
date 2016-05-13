
# Name of this configuration. Generally the name of the OS.
CONFIG=custom


# C compiler, flags
CC=gcc
CFLAGS=-O2

# NASM
NASM=nasm
NASMFLAGS=-f elf



# What the binary is called on this platform. Windows uses z26.exe,
# everybody else uses z26 (or z26-static). No other values are allowed.
EXE=z26

# Normally, we use the sdl-config script to set cflags/ldflags for us.
# You can set these manually if you need to.
SDLCONFIG=sdl-config
SDLLIBS=`$(SDLCONFIG) --libs`
SDLCFLAGS=`$(SDLCONFIG) --cflags`

# What z26-specific options shall we use for this platform?
# You can choose from:

#	-DLINUX_RTC_TIMING
# Most stable timing method (-T4), only works on Linux, requires
# -DUNIX_TIMING also.

#	-DWINDOWS
# Needed for platform support on Windows. Don't define on other OSes.

#	-DNEW_KEYBOARD
# You should always define this, except maybe on Windows (it only works
# there). Actually, you should always define it there, too.

#	-DUNIX_TIMING
# You should define this if you're using a UNIX-like platform that supports
# the select() function. This includes BeOS, but not Windows (even though
# we use a UNIX-like build environment on Windows). This allows you to
# use the -T2 and -T3 options, and is required for -T4 (along with
# the -DLINUX_RTC_TIMING option above).


#	-DDEBUG_AUDIO_SPEC
# Only define this if you're trying to debug z26's audio system.

# List all your options on the same line, like so:

Z26OPTS=-DNEW_KEYBOARD -DUNIX_TIMING

# C core options. We're in the middle of porting the x86 asm code
# to C, and at any given time the C code may or may not be working.
sinclude conf/c_core.mak


