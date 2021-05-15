## Adventures in Mega Drive coding

_Please note: These are only experiments, I'm not a M68K assembly pro!_

---

"On my journey from buying a Mega Drive 1991 to starting to learn assembly for the Motorola 68000 around 2020 I always felt that I wanted to do this. God knows why it took so long.

This repository is intended to be filled with commented code for Mega Drive enthusiasts. Following the path of great tutors I want to give something back because I appreciate the time and effort they took to teach n00bs like me about how to write code, use debuggers and disassemblers, understanding the hardware and have a real good time with an old friend - the Sega Mega Drive."

---

### How to use

On Windows/x64 just execute the `build.bat` file that is provided with each example.

There's a [WIKI page](https://github.com/ArcadeTV/megadrive-samples/wiki/waterbackground) for every example.

---

### Tools included

* [VASM](http://sun.hasenbraten.de/vasm/) (**[vasmm68k_mot_win32.exe](http://www.alphatron.co.uk/vasm/)**) <- Win-compiled by Rob
* **[fixheader.exe](https://github.com/sonicretro/s2disasm/raw/master/win32/fixheader.exe)** which fixes the ROM’ internal checksum in the header and prevents red-screen lockups
* furrtek's [rompadder](http://furrtek.free.fr/noclass/neogeo/pad.c)
* [krikzz' megalink](http://krikzz.com/pub/support/mega-everdrive/pro-series/usb-tool/) for sending roms directly to your Everdrive via USB

---

### Optional Tools (for coding and asset creation)

* [Visual Studio Code](https://code.visualstudio.com/)
  * [Motorola 68000 Assembly Extension](https://marketplace.visualstudio.com/items?itemName=clcxce.motorola-68k-assembly)
* [Imagenesis4000](http://devster.monkeeh.com/sega/imagenesis/)
* Adobe Photoshop (*CS2 is available for free)

---

### Thanks _in no particular order_

Big Evil Corporation, Hugues Johnson, Markey Jester, Dustin O'Dell, Infinest, SonicRetro, ValleyBell, krikzz