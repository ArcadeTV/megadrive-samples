@echo off
CLS
..\_TOOLS\vasmm68k_mot_win32.exe main.asm -chklabels -nocase -rangewarnings -Dvasm=1 -L _tmp\Listing.txt -DBuildGEN=1 -Fbin -spaces -o ..\ROMS\wireframe.md
..\_TOOLS\fixheader.exe ..\ROMS\wireframe.md
echo Fixed checksum in output rom header.