nasm -f elf --prefix _ -o z26core.o z26core.asm
m4 pixcopy.m4 > pixcopy.c
gcc -c -O2 -IC:/MSYS/1.0/local/include/SDL -Dmain=SDL_main z26.c
gcc -LC:/MSYS/1.0/local/lib z26.o z26core.o -lmingw32 -lSDLmain -lSDL -mwindows -o z26.exe
strip z26.exe
