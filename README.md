# News
8/8/2025

New Cores: Jotego Sunset Riders (BETA)

Updates: Jotego Ghosts 'n Goblins, Jotego KIWI, Jotego Black Tiger

___
7/8/2025

Updates: C128, Saturn, ST-V

___
29/7/2025

Updates: C128, Jaguar

___
28/7/2025

New Cores: Starforce

Updates: Joust2

___
22/7/2025

Updates: SVI328

___
21/7/2025

Updates: Minimig

___
19/7/2025

Updates: ZXNext

___
14/7/2025

Updates: Atari800, Atari5200

___
13/7/2025

Updates: SNES, MegaCD

___
12/7/2025

Updates: Jotego CPS1, Jotego CPS2, PET2001, NeoGeo

___
10/7/2025

Updates: Saturn

___
9/7/2025

Updates: PSX, Flappy Bird

___
8/7/2025

Updates: SNES

___
7/7/2025

Updates: TurboGrafx16

___
5/7/2025

Updates: Apple II

___
4/7/2025

Updates: CoCo2, CoCo3

___
2/7/2025

Updates: C128, MegaDrive, CDi, PCW, Amstrad CPC

___
29/6/2025

Updates: Genesis

___
# Raw binary files for Senhor FPGA board.
![image](https://github.com/user-attachments/assets/d68bc8fa-f05c-4b33-9088-9814994d0155)

**What is the Senhor board?**

It is the first attempt of a MiSTer [(DE10-Nano)](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1046) FPGA board clone by [QMTECH](https://qmtechchina.aliexpress.com/store/4486047) released in 2024.
We have named it "Senhor" as a joke, but it turned out to become a full project to port cores to it from the [MiSTer project](https://mister-devel.github.io/MkDocs_MiSTer/).

**Is it fully compatible?**

Yes and no! 

The pins where the memory module is connected are shuffled, therefore a remapping is needed and every core using the SDRAM module should be resynthesized in order to work. Although, quite often just a remap is not enough to get a stable core and more changes need to be made in the verilog code. That's where the Senhor team takes over, to fill that gap and convert this wonderful board into a cheap alternative to MiSTer. 

Hardware wise, except of the SDRAM memory modules designed for MiSTer, none of the existing MiSTer addons works on this board, since it has a different layout.

**Where can I buy it?**

https://www.aliexpress.com/item/1005006584384421.html

At the time of writing there is a new QMTECH board which is 100% core-compatible to MiSTer, therefore if you are not willing to experiment with Senhor, it is better to buy the new board instead.

https://www.aliexpress.com/item/1005007370471764.html

Another upcoming MiSTer clone is about to be released by [Taki Udon](https://twitter.com/takiudon_).

**I want to modify the cores on my own. Where are the sources?**

You can find all the forked [sources](https://github.com/turri21?tab=repositories&q=senhor&type=&language=&sort=) having the CoreName_Senhor naming scheme. For example: Minimig-AGA_Senhor, N64_Senhor, Saturn_Senhor etc

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

Finally, you are going to need a Micro SD card of minimum 2 GB and a custom Linux distribution flashed to it, such as [TWR Senhor](https://github.com/turri21/Senhor/tree/main/twr-Senhor) in order to be able to boot the system, browse the menu and load the cores.

Enjoy the ride!

Join us on Telegram: https://t.me/+fmIT1ovaOGkwNDQ0

___

-=(Extra notes)=-

Known issues:

IremM90: Bomber Man World - New Dyna Blaster - Global Quest - If "ROM PO CHECK ERROR" is displayed load the "Bomber Man - Dyna Blaster" first and then while it runs load the "Bomber Man World - New Dyna Blaster - Global Quest" afterwards.
Alternatively, you can try to reset the core several times until it passes the check.

IremM92: A not good "NG" message is displayed on the initial ROM checking. Some games are stuck at the RAM/ROM verification screen such as R-Type Leo. Possible fix: Reset the core several times.
         
TimePilot84: Barely seen pixel artifacts on title screen. Gameplay is not affected.

On some cores the onboard buttons (OSD and RESET) have been disabled for stability purposes.
