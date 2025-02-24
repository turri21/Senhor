# News

25/2/2025

Updates: PCW

___
23/2/2025

Updates: PCW

___
20/2/2025

New Cores: Donut

___
13/2/2025

Updates: Gamate

___
12/2/2025

New Cores: TomyScramble, GBMidi, Chess

___
10/2/2025

New Cores: Game Of Life, Slug Cross, Arduboy

___
9/2/2025

New Cores: GenMidi

___
8/2/2025

New Cores: Gamate, AdventureVision

___
7/2/2025

New Cores: Casio PV-1000, Intellivision

Updates: Tecmo, Menu

___
6/2/2025

New Cores: Atari 5200

___
5/2/2025

New Cores: AY-3-8500

___
4/2/2025

New Cores: BallyAstrocade

Updates: CoCo2

___
3/2/2025

New Cores: Traverse USA

___
2/2/2025

New Cores: Asteroids Deluxe

___
1/2/2025

Updates: NES, PCXT

___
31/1/2025

New Cores: Sky Skipper, Tropical Angel, Turkey Shoot, Space Invaders, Asteroids

Updates: ao486

___
29/1/2025

New Cores: Ultratank, BattleZone, ZigZag, Bagman, Athena, AtariTetris

Updates: IremM72

___
28/1/2025

New Cores: TIAMC1, Time Pilot, IremM72, MCR3Scroll, SuperBreakout

___
27/1/2025

New Cores: Tank Battalion

___
25/1/2025

New Cores: Black Widow

___
24/1/2025

New Cores: Burger Time, Breakout, NinjaKun

Updates: Gyruss

___
23/1/2025

New Cores: Congo Bongo, Computer Space, Centipede, Crystal Castles, Canyon Bomber
___
22/1/2025

New Cores: Exidy2, DonkeyKongJunior, DonkeyKong3, Dominos, DigDug, Defender

Updates: Minimig

___
21/1/2025

New Cores: Inferno, Gyruss, Sprint1, Sprint2, IremM62, Subs

___
20/1/2025

New Cores: Galaxian, Finalizer, Frenzy, FoodFight, Gaplus

___
19/1/2025

New Cores: Moon Patrol

Updates: PC88

___
18/1/2025

Updates: MrDo, Saturn

___
17/1/2025

New Cores: Jaguar, Joust 2

___
16/1/2025

New Cores: Space Race, Iron Horse, Jackal

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

Finally, you are going to need a Micro SD card of minimum 2 GB and a custom Linux distribution flashed to it, such as [Mr. Fusion](https://github.com/MiSTer-devel/mr-fusion) in order to be able to boot the system, browse the menu and load the cores.

Enjoy the ride!

Join us on Telegram: https://t.me/+fmIT1ovaOGkwNDQ0

___

-=(Extra notes)=-

Known issues:

Exerion: It has some barely detected pixel edge artifacts and a few visual glitches in the options menu. Gameplay is not affected.

IremM90: Bomber Man World - New Dyna Blaster - Global Quest - If "ROM PO CHECK ERROR" is displayed load the "Bomber Man - Dyna Blaster" first and then while it runs load the "Bomber Man World - New Dyna Blaster - Global Quest" afterwards.
Alternatively, you can try to reset the core several times until it passes the check.

IremM92: A not good "NG" message is displayed on the initial ROM checking. Some games are stuck at the RAM/ROM verification screen such as R-Type Leo. Possible fix: Reset the core several times.
         
TimePilot84: Barely seen pixel artifacts on title screen. Gameplay is not affected.

Garegga: It has minor pixel edge artifacts.

On some cores the onboard buttons (OSD and RESET) have been disabled for stability purposes.
