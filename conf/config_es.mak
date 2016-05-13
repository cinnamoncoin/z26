# Eckhard's config.mak, based on mm.bat


## rem ml /coff /Fl /c /Cp /Zm /Zi z26core.asm
## nasm -f elf --prefix _ -o z26core.o z26core.asm
## m4 pixcopy.m4 > pixcopy.c
## gcc -c -O2 z26.c
## gcc z26.o z26core.o -lmingw32 -lSDLmain -lSDL -mwindows -o z26.exe
## strip z26.exe

# Name of this configuration. Generally the name of the OS.
CONFIG=es


# C compiler, flags
CC=gcc
CFLAGS=-O2

# NASM
NASM=nasm
NASMFLAGS=-f elf --prefix _



# What the binary is called on this platform. Windows uses z26.exe,
# everybody else uses z26 (or z26-static). No other values are allowed.
EXE=z26.exe

# Normally, we use the sdl-config script to set cflags/ldflags for us.
# You can set these manually if you need to.
#SDLCONFIG=sdl-config

SDLLIBS=-lmingw32 -lSDLmain -lSDL -mwindows

# Yes, we give -O2 twice, it won't hurt anything and it'll keep the
# main Makefile from griping about SDLCFLAGS not being set
SDLCFLAGS=-O2

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

Z26OPTS=-DNEW_KEYBOARD -DWINDOWS

# C core options. We're in the middle of porting the x86 asm code
# to C, and at any given time the C code may or may not be working.
sinclude conf/c_core.mak

