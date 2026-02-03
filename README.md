# News
1/2/2026

Updates: PSX

___
31/1/2026

Updates: CDi

___
28/1/2026

Updates: SlapFight, Atari800VBXE, Atari800

___
26/1/2026

Updates: CrazyKong, CrazyClimber, Cosmic, MSX, PSX, ComputerSpace, CongoBongo, Chameleon

___
25/1/2026

Updates: BurgerTime

___
24/1/2026

Updates: Bosconian, BurningRubber, BombJack, Berzerk, BattleZone, Athena

___
23/1/2026

Updates: IIgs, AtariTetris, Bagman, CDi, SNES

___
22/1/2026

Updates: Atarisys1, Astrocade, Arkanoid
___
21/1/2026

Updates: Odyssey2, EpochGalaxyII, CosmicGuerilla, CrazyBalloon, SlapFight
___
20/1/2026

New Cores: SegaChannelRevival

Updates: TropicalAngel, Inferno, S32X, N64, Joust2

___
19/1/2026

Updates: BankPanic, PSX, Cave, SNK_TripleZ80, IremM92, IremM107
___
18/1/2026

Updates: NaughtyBoy, SegaVICZ80, MrJong, Pacman, IkariWarriors, Performan, SVI328

___
17/1/2026

Updates: TraverseUSA, TaitoSJ

___
16/1/2026

Updates: CDi, SNES

___
15/1/2026

Updates: Gameboy, GnW, MegaDrive

___
14/1/2026

Updates: RX78, TatungEinstein

___
13/1/2026

Updates: BBCBridgeCompanion, Donut, PokemonMini, SGB, ZXNext

___
12/1/2026

Updates: CoCo3, VT52
___
10/1/2026

Updates: SordM5

___
9/1/2026

Updates: ORAO

___
8/1/2026

Updates: AtariST, ORAO, Oric

___
7/1/2026

Updates: Altair8800, TSConf, C16, ZX81, PCW, VIC20

___
6/1/2026

Updates: PCXT

___
5/1/2026

Updates: BBCMicro, Atari800, IIgs

___
4/1/2026

Updates: SNES, Vectrex, Aquarius, PET2001, Archie, QL, IIgs

___
3/1/2026

New Cores: IIgs

Updates: MSX, Specialist

___
2/1/2026

Updates: BK0011M

___
1/1/2026

Updates: SAMCoupe, Minimig
___
31/12/2025

Updates: Vector-06C

___
29/12/2025

Updates: PCXT, Saturn, CDi, Apogee

___
27/12/2025

Updates: Homelab

___
25/12/2025

Updates: MyVision, PMD85, SNES

___
23/12/2025

Updates: NES, S32X

___
19/12/2025

Updates: Super_Vision_8000, Casio_PV-1000, Casio_PV-2000

___
16/12/2025

Updates: ColecoAdam, TomyTutor, Lynx48, AcornElectron

___
15/12/2025

Updates: Interact, NeoGeo, AcornAtom, N64

___
14/12/2025

New Cores: Laser500, Sorcerer

Updates: Laser310, Arduboy, AY-3-8500, Chip8, Ti994a, Jupiter, S32X, SMS

___
13/12/2025

Updates: GBA, PSX, Atari5200, Atari800, TRS-80, MacPlus

___
12/12/2025

New Cores: mc-2g-1024, TeleStrat

Updates: PMD85, ao486

___
11/12/2025

Updates: MegaCD, ZX-Spectrum, MacPlus

___
10/12/2025

Updates: X68000, Amstrad CPC, C64, IremM92, Minimig

___
9/12/2025

Updates: SNES

___
8/12/2025

Updates: PC88, CDi, AliceMC10, FlappyBird

___
7/12/2025

Updates: PSX

___
5/12/2025

Updates: Ti994a

___
4/12/2025

Updates: Jaguar

___
1/12/2025

Updates: PSX

___
30/11/2025

Updates: ao486

___
28/11/2025

Update: Minimig

___
27/11/2025

Updates: Enterprise

___
25/11/2025

New Cores: TK2000

___
23/11/2025

Updates: PSX

___
# Raw binary files for Senhor FPGA board.
![photo_github](https://github.com/user-attachments/assets/1f032576-412e-4b5e-9090-e6818393007a)

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
**Community:**

**Contributors in alphabetical order**

Anderson Vulczak -> for his update_senhor.sh network fix for people from Brazil. You have saved the day!

Edson & Gerson Pedro -> for their enjoyable to watch youtube videos about Senhor (and not only).

Fred Chrono Plays -> for his project's mascot editing. Now it is looking even more cooler ;)

Gerson Pedro -> for his great all-in-one Gerson's archive. 

Herbert K. -> for his design of a 3D printed case for Senhor & for spreading the word about the board in Vintage Computer Festival - Munich.

Renan -> for his assistance on setting up Retroarch for ARM!

Ron -> for his all purpose valuable assistance about Home micros, his throughout testing and his Retrocrypta live shows on Twitch!

Everyone in the Senhor community for their suggestions as well as their help in testing and reporting issues.

Last but not least Sorgelig the creator of MiSTer FPGA project, you are the firestarter!

Thank you!

The Senhor team: Luis & turri21
___

-=(Extra notes)=-

Known issues:

IremM90: Bomber Man World - New Dyna Blaster - Global Quest - If "ROM PO CHECK ERROR" is displayed load the "Bomber Man - Dyna Blaster" first and then while it runs load the "Bomber Man World - New Dyna Blaster - Global Quest" afterwards.
Alternatively, you can try to reset the core several times until it passes the check.

IremM92: A not good "NG" message is displayed on the initial ROM checking. Some games are stuck at the RAM/ROM verification screen such as R-Type Leo. Possible fix: Reset the core several times.
         
TimePilot84: Barely seen pixel artifacts on title screen. Gameplay is not affected.

On some cores the onboard buttons (OSD and RESET) have been disabled for stability purposes.
