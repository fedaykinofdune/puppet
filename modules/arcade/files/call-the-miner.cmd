@echo off
C:\Windows\System32\setx GPU_MAX_ALLOC_PERCENT 100
C:\Windows\System32\setx GPU_USE_SYNC_OBJECTS 1
echo "starting to mine in 10 sec.."
ping 127.0.0.1 -n 10 > nul
start C:\Users\dtaylor\Downloads\miner49er\cgminer\cgminer-3.7.2-windows\start-mining-multipool.cmd