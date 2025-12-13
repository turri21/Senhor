With these 2 files (Senhorize.py, sys.zip) you can convert any MiSTer core source to Senhor. 
It should work in most cases as long as the sources from MiSTer are having the proper layout of the framework.

For example, let's say that you have this core:  Amstrad_MiSTer-master.zip downloaded from git manually or if you clone it with the git clone command.
You will have to place these 2 files in the extracted source folder and all you have to do is to type the following:

python Senhorize.py

In some cases you might get crackles in audio or unstable video, this is the only time that you have to edit the sys_top.v manually 
and this is beyond the scope of the Senhorize.py script.

Finally, you should always use quartus 17.x
best if it is 17.0.2