# AMDRyzenPower

### compile cpu power log file 
<p> cd cpu
<p> gcc -o cpuLogToFile cpuLogToFile.c -lm

### compile gpu power log file 
<p> cd gpu
<p> nvcc -I../include -O3 -w k20LoggerToFile.cu -o gpuToFIle -L/usr/lib64/nvidia -lnvidia-ml

### To run 
<1> make sure mrs readable 
  sudo modprobe msr 
<2> Run cpu log file seperately:
    sudo ./cpu/cpuLogToFile [sampling interval] [filename] 
    e.g. ./cpu/cpuLogToFile 1 test      (sampling time is 1/sec, filename is test)
<3> Run gpu log file seperately 
    ./gpu/gpuToFIle [sampling interval] [filename]
    e.g. ./gpu/gpuToFIle 1 test      (sampling time is 1/sec, filename is test)
<4> Run cpu and gpu measurement together 
    sudo ./powerlog [sampling interval] [filename]
