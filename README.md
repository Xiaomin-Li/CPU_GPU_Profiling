# AMDRyzenPower

### compile cpu power log file 
<p> cd cpu
<p> gcc -o cpuLogToFile cpuLogToFile.c -lm

### compile gpu power log file 
<p> cd gpu
<p> nvcc -I../include -O3 -w k20LoggerToFile.cu -o gpuToFIle -L/usr/lib64/nvidia -lnvidia-ml

### To run 
<p> make sure mrs readable 
<p> sudo modprobe msr
  
<p> Run cpu log file seperately:
<p> sudo ./cpu/cpuLogToFile [sampling interval] [filename] 
<p> e.g. ./cpu/cpuLogToFile 1 test      (sampling time is 1/sec, filename is test)

<p> Run gpu log file seperately 
<p> ./gpu/gpuToFIle [sampling interval] [filename]
<p> e.g. ./gpu/gpuToFIle 1 test      (sampling time is 1/sec, filename is test)

<p> Run cpu and gpu measurement together 
<p> sudo ./powerlog [sampling interval] [filename]
