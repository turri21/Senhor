# News
28/3/2025

Updates: ST-V, Saturn

___
27/3/2025

Updates: Rememotech

___
26/3/2025

Updates: Minimig

___
23/3/2025

Updates: Rememotech

___
22/3/2025

Updates: Jaguar

___
20/3/2025

New Cores: Jotego Karate Champ, Jotego The Final Round, Jotego Renegade 

Updates: CDi

___
19/3/2025

New Cores: Jotego WWF Superstars, Jotego Double Dragon, Jotego Double Dragon II, Jotego Circus Charlie, Jotego Commando, Jotego Combat School, Jotego Robocop, Jotego CPS1.5, Jotego Exed Exes, Jotego Fast Lane, Jotego Gun.Smoke, Jotego Trojan, Jotego Midnight Resistance, Jotego Kicker, Jotego MX5000, Jotego Trick Trap (Labyrinth Runner)

Updates: Scramble

___
18/3/2025

New Cores: Jotego Haunted Castle, Jotego Karnov, Jotego Contra

Updates: Jotego S16b

___
15/3/2025

Updates: ST-V, Saturn, TRS-80

___
14/3/2025

Updates: Jaguar

___
7/3/2025

Updates: Intellivision

___
6/3/2025

New Cores: Gameboy2P, GameAndWatch, GBA, SNES

___
5/3/2025

New Cores: CreatiVision, GnW, Tamagotchi, MyVision, GBA2P

___
4/3/2025

New Cores: IremM107, Arcadia, ChannelF, Pokemon Mini

___
3/3/2025

Updates: NES

___
2/3/2025

Updates: Garrega

___
1/3/2025

Updates: PC88

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

On some cores the onboard buttons (OSD and RESET) have been disabled for stability purposes.
