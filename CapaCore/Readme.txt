-=(CapaCore)=-

This is a an OSD per-game preview.
Based on MiSTer binary, modified by Renan.

How to use:

Back up your current MiSTer Main first.
Copy the CapaCore MiSTer binary from MiSTer.zip to /media/fat/
Add the following line to your mister.ini file:

; [Senhor FPGA BEGIN] - game wallpapers (OSD per-game preview)
; 0 (default) - normal OSD background behaviour.
; 1           - show a per-game preview image as the OSD background while
;               browsing. Place images in the "wallpapers" folder named after
;               the entry (e.g. <name>.png / <name>.jpg); add a "default.png"
;               (or .jpg) for entries without a specific image. Optional
;               per-alt-config folders "wallpapers_alt_<N>" / "wallpapers_alt"
;               are used when an alternate MiSTer_*.ini config is active.
game_wallpapers=1
; [Senhor FPGA END]


Note:
The image filename must match the .mgl, .mra, etc., file exactly.
Name one image default so it shows up when a game doesn't have its own box art.

Note 2:
I’ve only tested this on CRT TVs and monitors. You need to keep the images at 640x480p resolution 
to avoid any slowdowns. If possible, use a tool to optimize the images, like OMR 
(Otimizador de Mídias Retro) or any online image optimizer.

Put the images into the wallpapers directory in the root of your microSD card.
