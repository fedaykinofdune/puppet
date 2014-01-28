C:\Windows\System32\setx GPU_MAX_ALLOC_PERCENT 100
C:\Windows\System32\setx GPU_USE_SYNC_OBJECTS 1
type nul >>c:\miner49er\mining.lock & copy c:\miner49er\mining.lock +,,
C:\Users\dtaylor\Downloads\miner49er\cgminer\cgminer-3.7.2-windows\cgminer --scrypt -o stratum+tcp://pool1.us.multipool.us:7777 -u changeme -p worker1 -I 20 -g 1 -w 512 --thread-concurrency 33792 --gpu-engine 1025 --gpu-fan 40-100 --gpu-memclock 1500 --gpu-powertune 20 --temp-cutoff 99 --temp-overheat 95 --temp-target 90
del c:\miner49er\mining.lock
del c:\miner49er\miner.lock