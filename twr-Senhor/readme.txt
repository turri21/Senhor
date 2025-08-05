# This is a modified version of TWiSTer Fusion for Senhor FPGA

# TWiSTer Fusion - Universal TWiSTer installation image.
(c) 2024 Roman Stolyarov AKA Vortex.

Twr. Fusion is a tiny, custom Linux distribution designed to run on the
QMTECH Cyclone V SoC FPGA board (DE10-Nano alternative) and install TWiSTer (MiSTer alternative).

It comes in the form of a compact image that you can download
and flash onto an SD card of any size with a tool like Balena Etcher or Win32 Disk Imager.

When you put this SD card into your QMTECH board and start it up, it will
expand the card to its full capacity and install a basic TWiSTer setup.
This will be familiar to anyone who's worked with a Raspberry Pi before.

From there, using the built-in scripts, you can configure WiFi.

You can provide custom WiFi and Samba configuration which Twr. Fusion will
install alongside the basic TWiSTer setup.

## Requirements

- A Micro SD card of minimum 2 GB, for example the one that came with your
  QMTECH board.
- Windows, Mac or Linux based computer with a (micro)SD card reader.
- An SD card flash utility.

## Instructions

### Step 1

Download and install an SD card flash utility for your system. Here are
a few example in no particular order:

- [Apple Pi Baker](https://www.tweaking4all.com/software/macosx-software/applepi-baker-v2/)
- [balenaEtcher](https://www.balena.io/etcher/)
- [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/)

Refer to the documentation of the SD card flash utility for more information.

### Step 2

Follow your SD card flash utility's instructions to flash the downloaded image
onto your SD card.

### Step 3

Put the SD card into the QMTECH board and power it on. After a few seconds the
red LED on the board should light up. If you have a TV or monitor connected
to the HDMI port, the screen will turn blue and then show an installation
notice splash screen:

Twr. Fusion will automatically re-partition and resize your SD card and copy all the
necessary TwiSTer files onto it. When it's done it will reboot your QMTECH board
and you will be greeted by the TWiSTer menu.

You can pair a Bluetooth controller by holding the OSD button and you can map
controller buttons by holding the "User" button.
Otherwise you can connect a USB keyboard and hit F12 to open the TWiSTer menu.

Through the Scripts section you can configure WiFi.

_Note: From powering on the QMTECH board and getting to the TWiSTer menu should not
take more than 90 seconds. If you don't see the TWiSTer menu appear after
two minutes, power off the QMTECH board, remove the SD card and start over._

## TWiSTer scripts support

This image includes the [WiFi setup script]
to quickly setup a wireless internet connection after installation.

### Adding more scripts

You can add more scripts if necessary: After you have flashed your SD card and
before you move it over to the QMTECH board, re-insert it into your computer.
A new drive called `MiSTer_Data` will appear. In it is a `Scripts` folder. Put
any script you want to have available in your TWiSTer in this folder. It will
be copied to your TWiSTer's Scripts folder automatically during the installation.

## Custom WiFi configuration (optional)

You can copy a custom `wpa_supplicant.conf` file in the root of the SD card
after flashing the Twr. Fusion image. It will automatically be copied to the
correct place during the installation of TWiSTer.
This allows you to configure your WiFi credentials before you install TWiSTer
and thus removes the need to connect a keyboard after installation.

## Custom Samba configuration (optional)

You can copy a custom `samba.sh` file in the root of the SD card
after flashing the Twr. Fusion image. It will automatically be copied to the
correct place during the installation of TWiSTer.
This allows you to enable Samba before you install and thus removes
the need to connect a keyboard to your TWiSTer or having to ssh into it.

## How is this an improvement to the TWiSTer setup process?

Having a universal flash image means we can just use _any_ SD card image
flashing tool on _any_ platform instead of a bespoke TWiSTer SD card creation
app. We no longer need to maintain such a custom made app or port it to other
platforms.

A fixed size image based approach has one caveat: We want the image to be as
small as possible to reduce the time it takes to download and to support a wide
variety of SD card capacities. We've managed to cram everything TWiSTer needs
into approximately 100 MB.
When you flash a 100 MB image onto any size SD card, you will get
only 100 MB of storage, most of which will be taken up by the TWiSTer files.
Your whopping 256 GB capacity SD card will only have a few megabytes free space.
The filesystem must be resized to match its full capacity.

TWiSTer uses the exFAT filesystem for maximum compatibility across different
platforms (Windows, macOS, Linux, ...). Linux, the operating system that TWiSTer
uses under the hood does not (yet) support resizing exFAT filesystems.
The only way to ensure maximum SD card capacity is to recreate the filesystem
with the proper size. However, we can't know in advance what that capacity
is going to be so we let the QMTECH board do the resize before installing
TWiSTer. That's what Twr. Fusion does. Because everyone has different computers
but we all have the same QMTECH board, it makes sense to do it this way.

## Acknowledgements

Thanks to Sorgelig, Rysha, Ziggurat, alanswx, r0ni, amoore2600 and Locutus73
Thanks to everyone else who contributes to the MiSTer FPGA project.

## Disclaimer

This program is free software. It comes without any warranty, to
the extent permitted by applicable law.
