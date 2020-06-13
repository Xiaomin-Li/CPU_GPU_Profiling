# AMDRyzenPower

### Prerrquisite
<p> pip install py3nvml

### Compile
<p> make 

### To run 
#### make sure msr file readable 
<p> sudo modprobe msr
  
#### Run cpu log file seperately:
<p> cd cpu
<p> sudo ./cpu/cpuLogToFile [sampling interval] [filename] [sampling time] 
<p> e.g. sudo ./cpu/cpuLogToFile 1 test 10     (sampling time is 1/sec, filename is test, sample for 10 seconds)

#### Run gpu log file seperately 
<p> ./gpu/gpuLogToFile [sampling interval] [filename]
<p> e.g. ./gpu/gpuLogToFile 1 test      (sampling time is 1/sec, filename is test)
** gpuLogToFile can not measure gpu utilization on RTX GPU. Since the NVML library get device utilization api only supports fermi and quadro architrcture cards.
** The python script provided here can also serve as gpu profiling tool
<p> python gpuProfiling.py [sampling interval] [filename] [sampling time] 
<p> e.g. python gpuProfiling.py 1 test 10     (sampling time is 1/sec, filename is test, sample for 10 seconds)
  
#### Run cpu and gpu measurement together 
<p> sudo ./powerlog [sampling interval] [filename] [sampling time]
<p> e.g. sudo ./powerlog 1 test 10      (sampling time is 1/sec, filename is test, sample for 10 seconds)
