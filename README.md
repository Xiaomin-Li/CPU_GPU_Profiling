# AMDRyzenPower

### Prerrquisite
* pip install py3nvml

### Compile
* make 

### To run 
#### make sure msr file readable 
* sudo modprobe msr

#### Run with user program 
* add user program command into powerlog file 
  * The profiling tool will be terminated if timeout or the user program returned or by keyboard 'Ctrl + C' 
  
#### Run cpu log file seperately:
* cd cpu
* sudo ./cpu/cpuLogToFile [sampling interval] [filename] [sampling time] 
  * e.g. sudo ./cpu/cpuLogToFile 1 test 10     (sampling time is 1/sec, filename is test, sample for 10 seconds)

#### Run gpu log file seperately 
1. Use CUDA C++ program as gpu profiling tool 
* ./gpu/gpuLogToFile [sampling interval] [filename]
  * e.g. ./gpu/gpuLogToFile 1 test      (sampling time is 1/sec, filename is test)
*gpuLogToFile can not measure gpu utilization on RTX GPU. Since the NVML library get device utilization api only supports fermi and quadro architrcture cards.*

2. Use python script as gpu profiling tool
* python gpuProfiling.py [sampling interval] [filename] [sampling time] 
  * e.g. python gpuProfiling.py 1 test 10     (sampling time is 1/sec, filename is test, sample for 10 seconds)
  
#### Run cpu and gpu measurement together 
* sudo ./powerlog [sampling interval] [filename] [sampling time]
  * e.g. sudo ./powerlog 1 test 10      (sampling time is 1/sec, filename is test, sample for 10 seconds)
