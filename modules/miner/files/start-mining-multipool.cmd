type nul >>c:\miner49er\mining.lock & copy c:\miner49er\mining.lock +,,
C:\Users\dtaylor\Downloads\miner49er\cgminer\cgminer-3.7.2-windows\cgminer --scrypt -o stratum+tcp://pool1.us.multipool.us:7777 -u multipimpin.worker1 -p worker1 -I 19 -g 1 -w 512 --thread-concurrency 33792 --gpu-engine 1025 --gpu-fan 100 --gpu-memclock 1500 --gpu-powertune 20 --temp-cutoff 96 --temp-overheat 95 --temp-target 90
del c:\miner49er\mining.lock