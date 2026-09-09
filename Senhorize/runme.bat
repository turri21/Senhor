@echo off
python Senhorize.py
E:\intelFPGA_lite\17.0\quartus\bin64\quartus_sh.exe --flow compile %1
pause