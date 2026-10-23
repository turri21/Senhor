# TI-83 Plus core for MiSTer - User guide

**TI-83 Plus core created by Lentrave.**

Core version 1.0.0. Open this guide from the core menu: **Help**.
The keyboard map, as a picture (the calculator with the PC key under each
TI key), is in `TI83P_Keyboard_Map.pdf` (same folder, also in **Help**).

---

## 1. What you need

| File | Where on the SD card |
|---|---|
| Core | `_Computer/TI83P_<date>.rbf` (or any core folder) |
| TI-83 Plus ROM (not included) | `games/TI83P/ti83plus.rom` |
| ROM auto-load (optional) | `config/TI83P.f0` |

* The ROM is copyrighted by Texas Instruments: dump it from your own
  calculator (for example with TiLP). It must be a raw dump of the whole
  Flash: **524,288 bytes** (512 KB), boot code included.
* `config/TI83P.f0` only contains the path `games/TI83P/ti83plus.rom`.
  MiSTer writes this file itself the first time you choose a ROM with
  **Load TI-83 Plus ROM**, so copying it is optional.

---

## 2. First start

1. Load the core.
2. If the ROM does not load by itself: **Load TI-83 Plus ROM**, choose
   `games/TI83P/ti83plus.rom`. MiSTer remembers it for the next starts.
3. The calculator starts. The first time, the screen shows
   **RAM cleared**: this is normal (empty memory).

At every start MiSTer then:

* loads the ROM,
* mounts the save file `saves/TI83P/ti83plus.sav`
  (it is **created automatically** if it does not exist yet:
  message *Save file created*),
* restores the calculator from it: RAM **and Flash**, so your programs,
  archived variables and applications come back (message *Memory loaded*).

---

## 3. Keyboard

Keys are given by their **position on a US QWERTY keyboard**
(on another layout, use the key at the same place).

| TI-83 Plus | PC key | TI-83 Plus | PC key |
|---|---|---|---|
| Y= WINDOW ZOOM TRACE GRAPH | F1 F2 F3 F4 F5 | ON | Esc or F11 |
| 2nd | Shift or Tab | ALPHA | Ctrl, Alt or Caps Lock |
| MODE | M | DEL | Backspace or Delete |
| X,T,θ,n | X | STAT | S |
| MATH | A | APPS | R or U |
| PRGM | P | VARS | V |
| CLEAR | C | x⁻¹ | K or F6 |
| SIN COS TAN | I O N | ^ | Y |
| x² | Q | LOG | G |
| LN | L | STO▸ | T |
| ( ) | [ ] | , | , |
| ÷ | / | × | * (keypad) |
| − | - | + | = (no Shift), keypad + |
| 0 to 9 | 0 to 9 | . | . |
| (−) | ` or \ | ENTER | Enter or Space |
| Arrows | Arrow keys | | |

* Digits, point, + − * / and Enter also work on the numeric keypad.
* **2nd functions**: press Shift, release, then the key - exactly like
  the 2nd key of the real calculator. MATRX is 2nd x⁻¹ (Shift then K).
* **Letters** (ALPHA): press Ctrl, release, then the key.
* For **+** use the **=** key without Shift: Shift + = would send
  2nd + (MEM).
* To switch the calculator off: **Shift then Esc** (2nd, ON = OFF).
  To switch it on: **Esc** (ON).

### Text mode (F9): type text directly

Press **F9** to switch the text mode on (message *Text mode ON*), again to
switch it off. In text mode the PC keyboard types text, as on a PC: the
core turns each character into the TI keys that type it, by itself (fast
typing is queued).

* Menu option **Text mode keyboard**: **US QWERTY**, **Canadian French**
  or **French AZERTY**, so that letters and symbols follow the labels of
  your keyboard.
* **Lowercase by default**; **Shift** gives capitals, **Caps Lock**
  switches to capitals (each F9 starts again in lowercase). The core
  enables the lowercase letters of the TI while text mode is on.
  TI-Basic variables and commands need **capitals** (A, B, X...).
* Accented letters type the plain letter (é → e).

| Character | TI keys pressed by the core |
|---|---|
| a ... z | ALPHA ALPHA letter |
| A ... Z | ALPHA letter |
| space " : ? | ALPHA 0, ALPHA +, ALPHA ., ALPHA (−) |
| 0-9 . , ( ) + - * / ^ | the TI key (- is the minus sign) |
| ~ | (−), the negative sign |
| { } [ ] | 2nd ( 2nd ) 2nd × 2nd − |
| = < > | 2nd TEST 1, 5, 3 |
| ! | MATH PRB 4 |
| ' | 2nd ANGLE 2 |

* Characters the TI cannot type (`@ # $ % & _ ; | \` and the backquote)
  are ignored.
* **Backspace** erases the character before the cursor (the core presses
  ← then DEL); **Delete** erases the character under the cursor (DEL).
  Both wait for the characters typed before them.
* Keys that are not characters keep their TI function: Enter, arrows, Esc (ON), F1-F5, the numeric keypad, Tab (2nd),
  Ctrl / Left Alt (ALPHA). In text mode Shift is no longer 2nd and Right
  Alt is AltGr.
* Do not press ALPHA or 2nd yourself while typing in text mode (an ALPHA
  or 2nd already active changes the automatic keys). Use it where the TI
  expects text (home screen, program editor, Input): in a menu the keys
  choose menu items.

### Gamepad

D-pad = arrows. Buttons: **Enter, 2nd, Alpha, Clear, Mode, ON, Zoom,
Graph**. Assign them once in the MiSTer menu
(*Define joystick buttons*).

---

## 4. Saving the calculator (save file)

The save file holds the 32 KB of RAM and the 512 KB of Flash (operating
system, archive, applications). To keep your work:

1. Open the menu, choose **Save memory (then 2nd+OFF)**.
2. Switch the calculator **off**: Shift then Esc (2nd, OFF).
   You can also switch it off first, then choose Save memory.
3. Close the menu: the message *Memory saved* appears.

Why the calculator must be off: this is the state of a real TI-83 Plus
when its batteries are removed. When it starts again, the operating
system keeps the RAM only if it is valid.

* Archived variables and applications are in the Flash: they are always
  restored, even if the RAM is not.
* *Saving when the TI is off (2nd+OFF)*: the save is armed and will run
  as soon as the calculator is off (it waits up to 30 seconds).
* *Switch the TI off first (2nd+OFF)*: 30 seconds passed, nothing was
  saved. Try again.
* If the calculator shows **RAM cleared** after a restart, the save was
  taken while it was on: save again the correct way. Archived variables
  are still there (2nd MEM, Archive).

**Other ROM name**: the save file is named after the ROM
(`saves/TI83P/<rom name>.sav`).

**Manual mounting**: **Mount save file** lets you load another `.sav`
(557,056 bytes; a 32 KB file only restores the RAM). Saving then writes
to that file.

---

## 5. Sending programs to the calculator

1. Menu: **Load TI file**, choose a TI-83 Plus file
   (`.8xp .8xg .8xn .8xl .8xm .8xy .8xi .8xd .8xw .8xz .8xt .8xs .8xc .8xv`).
2. That's all: the transfer starts by itself half a second later, as
   long as the calculator is **on** and waiting for a key (home screen or
   a menu). This is the "silent" transfer used by TiLP: no need to open
   the LINK menu. Menu message: *Transfer OK*.

* A file saved as *archived* (TiLP option) goes straight to the Flash
  archive.
* **Send again** the same file: menu **Send file to calculator**.
* Choosing **Send file to calculator** during a transfer cancels it.
* Not supported: Flash applications (`.8xk`), operating systems
  (`.8xu`) and backups (`.8xb`). Install applications through TiLP with
  the external link cable (see 8), or keep them in your save file.

### Several files at once (games in several files)

The MiSTer menu selects one file at a time. To send a whole game
(main program, sub-programs, pictures, AppVars...) in one go, gather its
files into a **group file** (`.8xg`):

* copy the game folder into `games/TI83P/` (for example
  `games/TI83P/MyGame/`);
* in the MiSTer main menu choose **Scripts > ti83p_make_groups**. Every
  sub-folder of `games/TI83P/` becomes a group next to it
  (`games/TI83P/MyGame.8xg`); groups already up to date are left alone;
* in the core: **Load TI file**, choose that `.8xg`: every variable is
  sent, one after the other, in a single transfer.

A group made on a PC (for example with TI Connect or TiLP) works too.

Up to 64 KB per group; `.8xk`, `.8xu` and `.8xb` files in the folder are
skipped. Archived variables stay archived.

### Programs written as text (.txt)

A `.txt` file cannot simply be renamed: a `.8xp` is a tokenized binary
file. Copy the text into `games/TI83P/` (sub-folders allowed), then in the
MiSTer main menu choose **Scripts > ti83p_text_to_8xp** and pick the
file: `NAME.8xp` is created next to it. Then **Load TI file** in the core.

* One instruction per line; `:` at the start of lines is accepted.
* A first line `PROGRAM:NAME` gives the program name, otherwise the file
  name is used (8 characters, letters and digits).
* Special symbols as the real characters (→ ² ≠ ≤ ≥ √( π θ L₁ Y₁...) or in
  ASCII: `->`, `^^2`, `!=`, `<=`, `>=`, `sqrt(`, `pi`, `theta`, `L1`, `Y1`.
* `-` in front of a number or a variable becomes the negative sign (−).
* Any unknown character is reported with its line and column, and nothing
  is created.

---

## 6. Screenshots

1. Copy `TI83P_SCREEN.bmp` (1024 bytes, provided with the core) to the
   SD card, for example in `games/TI83P/`.
2. Menu: **Mount screenshot file**, choose it.
3. Menu: **Take screenshot**. The file now contains the 96x64 screen
   (black and white BMP). Message: *Screenshot saved*.

Each screenshot **overwrites** the file: rename it on your PC to keep it.

---

## 7. Menu reference

| Entry | Effect |
|---|---|
| Load TI-83 Plus ROM | Loads the ROM (remembered, reloaded at every start) |
| Load TI file | Loads a program or variable and sends it (see 5) |
| Send file to calculator | Sends it again / cancels a transfer |
| Mount save file | Uses another save file |
| Save memory | Saves RAM and Flash (see 4) |
| Mount screenshot file / Take screenshot | See 6 |
| Link port | External cable (see 8) |
| Aspect ratio | 4:3, 16:9 or Original |
| Palette | LCD colours: Classic LCD, B&W, Amber, Cyan backlight |
| Pixel Grid | Gaps between LCD pixels, like a real STN screen |
| Bezel Overlay | **On**: the real TI-83 Plus face at its real proportions (screen frame, brand, STAT PLOT F1 ... labels and Y= ... GRAPH keys), screen x4. **Off**: biggest screen (x6), black border |
| 15kHz CRT Mode | 240p output for CRT TVs |
| Text mode keyboard (F9) | Keyboard layout of the text mode: US QWERTY, Canadian French or French AZERTY (see 3) |
| CPU Speed | 6 MHz (real speed), 12 or 24 MHz (faster graphs and programs) |
| Audio Mode | Sound from the link port (programs that play music): Stereo, Mono, Tip only, Mute |
| Debug Overlay | Link and Flash diagnostics on the LCD (for developers) |
| Reset (keep memory) | Restarts the calculator; RAM and archive are kept |
| Reset (clear RAM) | Erases the RAM, like removing all batteries (the archive in Flash is kept) |

Loading a new ROM also clears the RAM, then restores the save file that
belongs to that ROM.

---

## 8. External link cable (Link port)

| Setting | Use |
|---|---|
| None | No external cable |
| PC (USER serial) | TiLP on a PC, through a **3.3 V** USB-serial adapter on the USER port |
| Real cable (USER) | Link with a real TI calculator |
| PC (MiSTer UART) | Through the MiSTer serial port (`/dev/ttyS1`, Linux side; experimental) |

**PC (USER serial)**: USER_IO 0 = RX (to the adapter TX),
USER_IO 1 = TX (to the adapter RX), common ground. In TiLP choose the
**GrayLink** cable on the adapter COM port, calculator **TI-83 Plus**.

**Real cable**: USER_IO 0 = tip, USER_IO 1 = ring. A **5 V / 3.3 V level
shifter is required** (for example BSS138 modules): never connect the
calculator directly to the FPGA.

---

## 9. Menu messages

Messages appear when the menu is **closed**.

| Message | Meaning |
|---|---|
| Transfer OK | File received by the calculator |
| Not a TI-83 Plus file / Unsupported file | The file cannot be sent (wrong model, application, backup) |
| TI not responding (switched on?) | The TI is off or busy running a program |
| Link protocol error / Checksum error | Transfer error, try again |
| Cancelled on the TI | The calculator refused or stopped the transfer |
| TI memory full | Not enough free memory on the TI |
| Memory saved / Memory loaded | Save or restore done |
| Saving when the TI is off (2nd+OFF) | Save armed, switch the TI off |
| Switch the TI off first (2nd+OFF) | Save not done (TI stayed on) |
| No file mounted | No save file: load the ROM again or use Mount save file |
| File too small | The save file is smaller than 32 KB |
| File is read-only | The file cannot be written |
| RAM loaded (short file) | Old 32 KB file: only the RAM was restored |
| Save file created (saves/TI83P) | First start with this ROM: save file created |
| Screenshot saved | Screenshot written |

---

## 10. Troubleshooting

* **Black screen**: the ROM is not loaded (Load TI-83 Plus ROM), or the
  calculator is off (press Esc = ON).
* **RAM cleared after a restart**: the last save was taken while the
  calculator was on. See 4.
* **TI not responding**: switch the calculator on, go back to the home
  screen (2nd MODE = QUIT), then **Send file to calculator**.
* **Letters or 2nd functions do not work**: press Shift or Ctrl,
  release, then press the key (do not hold them together).
* **Nothing happens with Help**: `fb_terminal=1` is needed in
  `MiSTer.ini` (it is the default).

---

## Credits

TI-83 Plus core for MiSTer created by **Lentrave**, derived from his
TI-82 core. Hardware behaviour (memory map, ports, timers, Flash chip)
follows the TilEm emulator and WikiTI documentation. Z80 CPU: TV80 by
Guy Hutchison (based on the T80 by Daniel Wallner). MiSTer framework by
Alexey Melnikov (Sorgelig) and contributors. Token table of the text to
.8xp script: TI-Toolkit. Full credits: `CREDITS.md` in the source code.

TI-83 Plus, TI and the Texas Instruments logo are trademarks of Texas
Instruments; the logo appears in the bezel image. This project is not
affiliated with or endorsed by Texas Instruments. The ROM is not
provided: use a dump of your own calculator.
