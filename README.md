# News
19/10/2024

New Cores: Jotego Super Hang On, Jotego Namco System 1 (Pacmania, Galaga '88 etc)

____
18/10/2024

Updates: SordM5

____
16/10/2024

New Cores: Ondra SPO186 (requires a 2ndary SD card slot)

____
15/10/2024

New Cores: MC1201, MultiComp, Apogee, Laser 310

____
13/10/2024

Updates: Tecmo (Audio fix, Framebuffer is back, Artifacts fix)

Version number is the same with the old one (silent update), but please replace it.

____
10/10/2024

New Cores: Vector-06C

____
9/10/2024

New Cores: Chip8, Jotego The Simpsons, Jotego Track & Field

Updates: Jotego Sly Spy (artifacts fix)

____
7/10/2024

New Cores: Jotego Sly Spy

____

# Raw binary files for Senhor FPGA board.
![image](https://github.com/user-attachments/assets/d68bc8fa-f05c-4b33-9088-9814994d0155)

**What is the Senhor board?**

It is the first attempt of a MiSTer [(DE10-Nano)](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1046) FPGA board clone by [QMTECH](https://qmtechchina.aliexpress.com/store/4486047) released in 2024.
We have named it "Senhor" as a joke, but it turned out to become a full project to port cores to it from the [MiSTer project](https://mister-devel.github.io/MkDocs_MiSTer/).

**Is it fully compatible?**

Yes and no! 

The pins where the memory module is connected are shuffled, therefore a remapping is needed and every core using the SDRAM module should be resynthesized in order to work. Although, quite often just a remap is not enough to get a stable core and more changes need to be made in the verilog code. That's where the Senhor team takes over, to fill that gap and convert this wonderful board into a cheap alternative to MiSTer. 

Hardware wise, except of the SDRAM memory modules designed for MiSTer, none of the existing MiSTer addons work on this board, since it has a different layout.

**Where can I buy it?**

https://www.aliexpress.com/item/1005006584384421.html

At the time of writing there is a new QMTECH board which is 100% core-compatible to MiSTer, therefore if you are not willing to experiment with Senhor, it is better to buy the new board instead.

https://www.aliexpress.com/item/1005007370471764.html

Another upcoming MiSTer clone is about to be released by [Taki Udon](https://twitter.com/takiudon_).

**I want to modify the cores on my own. Where are the sources?**

You can find all the forked [sources](https://github.com/turri21?tab=repositories) having the CoreName_Senhor naming scheme. For example: Minimig-AGA_Senhor, N64_Senhor, Saturn_Senhor etc

**Are you related to QMTECH?**

Absolutely not! We have bought our boards from the QMTECH store on Aliexpress for this purpose (as a cheap alternative to MiSTer).

---

**Requirements:** 

A single 32MB or higher SDRAM memory module compatible with MiSTer is required for most cores to work. (Recommended 128MB)

Dual SDRAM is not supported on Senhor (at least for the time being).

**WARNING: The memory module MUST BE connected to the inner slot, the one closer to the FPGA chip.**

**The outward side should be facing as the word describes, outwards. Please be extremely cautious about the correct orientation and proper installation of the memory module, otherwise you are risking to harm both the module and the board!!!**

![Clipboard01](https://github.com/user-attachments/assets/5d5292ab-acc2-4b75-9715-01001581ac89)

**WARNING #2: A heatsink AND a fan are required (there are demanding cores such as the Minimig, ao486 etc where the chip is getting VERY hot).**

A USB hub, so you can connect a keyboard, a mouse and a gamepad to the board's only USB port for peripherals.

Finally, you are going to need a Micro SD card of minimum 2 GB and a custom Linux distribution flashed to it, such as [Mr. Fusion](https://github.com/MiSTer-devel/mr-fusion) in order to be able to boot the system, browse the menu and load the cores.

Enjoy the ride!

Join us on Telegram: https://t.me/+fmIT1ovaOGkwNDQ0
