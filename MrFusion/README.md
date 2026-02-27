# Mr. Fusion - Universal Senhor installation image

Mr. Fusion is a tiny, custom Linux distribution designed to run on the QMTech CycloneV SoC and install Senhor FPGA.

It comes in the form of a compact image that you can download and flash onto an SD card of any size with a tool like [Apple Pi Baker](https://www.tweaking4all.com/software/macosx-software/applepi-baker-v2/), [balenaEtcher](https://www.balena.io/etcher/), [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) or even [dd](https://en.wikipedia.org/wiki/Dd_%28Unix%29).

When you put this SD card into your QMTech CycloneV SoC and start it up, it will expand the card to its full capacity and install a basic Senhor FPGA setup. This will be familiar to anyone who's worked with a Raspberry Pi before.

From there, using the built-in scripts, you can configure WiFi (or use Ethernet out of the box) and run the standard [Senhor Downloader script](https://github.com/turri21/Senhor/raw/refs/heads/main/Scripts/update_senhor.sh) to get an up to date Senhor installation.

You can provide custom WiFi and Samba configuration which Mr. Fusion will install alongside the basic Senhor setup.

## Requirements

- A Micro SD card of minimum 2 GB, for example the one that came with your QMTech CycloneV SoC kit.
- Windows, Mac or Linux based computer with a (micro)SD card reader.
- An SD card flash utility.

## Instructions

### Step 1

Download the latest version from the [MrFusion](https://github.com/turri21/Senhor/tree/main/MrFusion) page.

### Step 2

Download and install an SD card flash utility for your system. Here are
a few example in no particular order:

- [Apple Pi Baker](https://www.tweaking4all.com/software/macosx-software/applepi-baker-v2/)
- [balenaEtcher](https://www.balena.io/etcher/)
- [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/)

Refer to the documentation of the SD card flash utility for more information.

### Step 3

Follow your SD card flash utility's instructions to flash the downloaded image onto your SD card.

_Note: Extract the downloaded SD card image zip file if your SD card flash utility does not support flashing zip files!_

### Step 4

Put the SD card into the QMTech CycloneV SoC and power it on. After a few seconds the orange LED on the board should light up. If you have a TV or monitor connected to the HDMI port, the screen will turn blue and then show an installation notice splash screen:

<img src="https://github.com/CoreRasurae/mr-fusion_Senhor/raw/master/vendor/support/splash.png" alt="Senhor installation splash screen" width="50%">

Mr. Fusion will automatically re-partition and resize your SD card and copy all the necessary Senhor files onto it. When it's done it will reboot your QMTech CycloneV SoC and you will be greeted by the Senhor menu.

If you have a Bluetooth USB dongle, you can pair a Bluetooth controller by holding the OSD button and you can map controller buttons by holding the "User" button. Otherwise you can connect a USB keyboard and hit F12 to open the Senhor menu.

Through the Scripts section you can configure WiFi and update your Senhor. Please refer to the [MiSTer documentation](https://mister-devel.github.io/MkDocs_MiSTer/setup/software/) for more information.

_Note: From powering on the QMTech Cyclone V and getting to the Senhor menu should not take more than 90 seconds. If the Senhor menu does not appear after two minutes, power off the QMTech CycloneV SoC, remove the SD card and start over._

## Senhor scripts support

The [Senhor Downloader script](https://github.com/turri21/Senhor/raw/refs/heads/main/Scripts/update_senhor.sh) is included by default in every Senhor installation. This image also includes the [WiFi setup script](https://github.com/MiSTer-devel/Scripts_MiSTer/blob/master/other_authors/wifi.sh) to allow you to quickly setup a wireless internet connection after installation.

### Adding more scripts

You can add more scripts if necessary: After you have flashed your SD card and before you move it over to the QMTech CycloneV SoC, re-insert it into your computer. A new drive called `MRFUSION` will appear. In it is a `Scripts` folder. Put any script you want to have available in your Senhor in this folder. It will be copied to your Senhor's Scripts folder automatically during the installation.

## Custom WiFi configuration (optional)

You can copy a custom `wpa_supplicant.conf` file in the root of the SD card after flashing the Mr. Fusion image. It will automatically be copied to the correct place during the installation of Senhor. This allows you to configure your WiFi credentials before you install MiSTer and thus removes the need to connect a keyboard after installation.

## Custom Samba configuration (optional)

You can copy a custom `samba.sh` file in the root of the SD card after flashing the Mr. Fusion image. It will automatically be copied to the correct place during the installation of Senhor. This allows you to enable Samba before you install and thus removes the need to connect a keyboard to your Senhor or having to ssh into it.

## How is this an improvement to the Senhor setup process?

Having a universal flash image means we can just use _any_ SD card image flashing tool on _any_ platform instead of a bespoke Senhor SD card creation app. We no longer need to maintain such a custom made app or port it to other platforms.

A fixed size image based approach has one caveat: We want the image to be as small as possible to reduce the time it takes to download and to support a wide variety of SD card capacities. We've managed to cram everything Senhor needs
into approximately 100 MB. When you flash a 100 MB image onto any size SD card, you will get only 100 MB of storage, most of which will be taken up by the Senhor files. Your whopping 256 GB capacity SD card will only have a few megabytes free space. The filesystem must be resized to match its full capacity.

Senhor uses the exFAT or ext4 filesystem. exFAT allows for maximum compatibility across different platforms (Windows, macOS, Linux, ...), however it is not as reliable as ext4. Linux, the operating system that Senhor uses under the hood does not (yet) support resizing exFAT filesystems. The only way to ensure maximum SD card capacity is to recreate the filesystem with the proper size. However, we can't know in advance what that capacity is going to be so we let the QMTech CycloneV SoC do the resize before installing Senhor. That's what Mr. Fusion does. Because everyone has different computers but we all have the same QMTech CycloneV SoC board, it makes sense to do it this way.

## Getting help

If you need help, come find us in the #help channel on the [Senhor FPGA Telegram Channel](https://t.me/c/2188679091/1).

## Reporting issues

If you think you found a bug or you have an idea for an improvement, [please open an issue](https://github.com/CoreRasurae/mr-fusion_Senhor/issues).

## Building it yourself

The Mr. Fusion SD card image can be built using a Docker container from a Docker image that contains the necessary tools ([cross compilation toolchain and initramfs targetting the QMTech CycloneV SoC](https://buildroot.org/) and [custom MiSTer Linux kernel](https://github.com/michaelshmitty/linux-socfpga)). First build the Docker image, then use a container based on that image to build the SD card image.

### Build the Mr. Fusion builder Docker image

```sh
docker build -t mr-fusion-builder .
```

### Create the Mr. Fusion SD card image

See https://github.com/CoreRasurae/SD-Installer-Win64_Senhor for a list of Senhor releases and set the Docker container environment variable below appropriately.

```sh
docker run --privileged \
  -e SENHOR_RELEASE="release_Senhor_2026022.7z" -e FUSION_FS_CONFIG="exfat" \
  -v /dev:/dev \
  -v .:/files \
  --rm -it \
  mr-fusion-builder
```

or, for ext4 filesystem, use:

```sh
docker run --privileged \
  -e SENHOR_RELEASE="release_Senhor_2026022.7z" -e FUSION_FS_CONFIG="ext4" \
  -v /dev:/dev \
  -v .:/files \
  --rm -it \
  mr-fusion-builder
```


The result should be a compressed image file in the `./images` directory that you can flash to an SD card.

## Acknowledgements

Thanks to Sorgelig, Rysha, Ziggurat, alanswx, r0ni and Locutus73 for their insights.
Thanks to amoore2600 for pushing me to create this.
Thanks to everyone else who contributes to the MiSTer FPGA project.

## Disclaimer

This program is free software. It comes without any warranty, to the extent permitted by applicable law.
See [LICENSE](https://github.com/CoreRasurae/mr-fusion_Senhor/blob/master/LICENSE) for more details.
