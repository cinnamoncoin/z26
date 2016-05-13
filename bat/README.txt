
Batch files. This is what we used to use to build the Windows version
before the current incarnation of the Makefile and conf/ directory. The
make system is elegant and complex, but violates the KISS principle.
If you have trouble with it, you can fall back on these very simple,
straightforward DOS-style batch files.

These may be useful if you have a non-standard Msys environment,
or don't feel like installing the whole UNIX-style toolchain.

mm.bat - Builds z26 if you've copied the SDL includes into the
standard include directory and the SDL libraries into the standard
lib directory.

bmm.bat - Builds z26 if you've installed SDL normally. The compiler
and linker flags came from the output of `sdl-config'.

To use these, you'll still need gcc.exe, nasm.exe, m4.exe, and strip.exe
from Msys in your PATH. You can run these from either an Msys bash prompt
or a Windows DOS (command.com or cmd.exe) prompt. nasm.exe doesn't come
with Msys, IIRC, but you can get a copy from http://nasm.sourceforge.net
(you want the `Win32 binary' release, not the DOS one).

