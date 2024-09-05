Galaksija_PLUS_ROMD

To enter the PLUS mode you have to type in basic the following command and press enter: 
A=USR(&E000)

The PLUS games are not working yet, since the GRAPHICS mode is not working.

Similarly to activate the ROM D:
A=USR(&F000)

*ROM D should be activated first* -- To use the monitor (RAM dump) you have to type in BASIC the following command:
*A &STARTING_ADDRESS &ENDING_ADDRESS

Example:
*A &F00 &FFF

or simply
*A &F00

and then ESC to break it 


*ROM D should be activated first* -- To use the disassembler you have to type in BASIC the following command:
*D &STARTING_ADDRESS &ENDING_ADDRESS

Example: 
*D &F00 &FFF

or simply
*D &F00

and then ESC to break it

----
