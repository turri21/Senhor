# Killer Instinct MiSTer core

MiSTer FPGA implementation of the Midway Killer Instinct arcade hardware used
by Killer Instinct (1994) and Killer Instinct 2 (1996).

## Current status

Both KI1 and KI2 boot and are fully playable on DE10-Nano hardware. The core
implements:

- R4600-compatible MIPS III CPU execution, caches, exceptions and interrupts.
- Midway DCS Audio with an ADSP-2105-compatible HDL engine and all eight sound
  ROM banks.
- Original 320 x 240 video, framebuffer page flipping and BGR555 output.
- Native/60 Hz CRT timing modes.
- ATA PIO access to raw disk images through MiSTer's mounted-image interface.
- Controls, coins, Start, Service, Test and MAME-compatible keyboard mappings.
- Game DIP switches.

### Known issue

Game slowdown - CPU is ~85 MHz and should be 100 MHz

## Media

ROM and disk data are not included. MRAs are supplied for the dumped KI and
KI2 revisions and use the unmodified MAME ZIP names. Match the MRA, ROM ZIP and
disk image from the same game set.

MAME merged kinst.zip and kinst2.zip should be placed in ```games/mame/```

MiSTer's image interface needs a raw sector image rather than a CHD. Prepare
them with:

```text
chdman extracthd -i kinst.chd -o kinst.img
chdman extracthd -i kinst2.chd -o kinst2.img
```

Place the resulting image files in their respective folders ```games/kinst/``` or ```games/kinst2/```.


## Credits

R4300i CPU adapted from the [N64](https://github.com/MiSTer-devel/N64_MiSTer) MiSTer core

`adsp2105.sv` and `dcs_mem.sv` are adapted from the [Wolf Unit](https://github.com/blahm1d/wolf-unit) MiSTer core

[MAME](https://github.com/mamedev/mame) kinst driver as a reference