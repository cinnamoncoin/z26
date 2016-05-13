
Porting work is proceeding nicely.

So far, we can build & run z26 on Windows, Linux, FreeBSD, and BeOS.
Other UNIXish systems on x86 hardware should work, so long as you've
got everything you need:

- GNU Make, recent version (I use 3.79.1, any 3.7x should work).
  You can't use BSD make or `pmake'.

- GCC, version 2.95 or 3.x (at least 3.2, 3.3.1, 3.3.2, and 3.4.0 work)

- NASM, v0.98.something (0.98.31 or better tested, others should work)

- SDL, at least version 1.2.3 (we use 1.2.7; probably any 1.2 is OK)

- Perl, for building the docs. You don't really need perl unless you're
  planning to edit the README/manpage.

If you can't build z26 for whatever reason, check the bin/ directory
for a prebuilt binary.

