rem ml /coff /Fl /c /Cp /Zm /Zi z26core.asm
nasm -f elf --prefix _ -o z26core.o z26core.asm
m4 pixcopy.m4 > pixcopy.c
gcc -c -O2 z26.c
gcc z26.o z26core.o -lmingw32 -lSDLmain -lSDL -mwindows -o z26.exe
strip z26.exe
