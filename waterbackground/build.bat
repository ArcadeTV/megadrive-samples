@echo off
CLS
.\TOOLS\vasmm68k_mot_win32.exe main.asm -chklabels -nocase -rangewarnings -Dvasm=1 -L _tmp\Listing.txt -DBuildGEN=1 -Fbin -spaces -o .\ROMS\out.md
.\TOOLS\fixheader.exe ROMS\out.md
echo Fixed checksum in output rom header.