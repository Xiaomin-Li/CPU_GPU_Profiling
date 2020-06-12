# 
import py3nvml.nvidia_smi as nvml
import datetime  
import time

nvml.nvmlInit()
num_gpus = nvml.nvmlDeviceGetCount()
print('Number of GPUs {}'.format(num_gpus))
print('Time, device, gpu_util %, gpu-mem %, memory used Mib/ total Mib, power current W/ limit W, temperature C')
while True:
    for i in range(num_gpus):
        handle = nvml.nvmlDeviceGetHandleByIndex(i)
        util = nvml.nvmlDeviceGetUtilizationRates(handle)
        power = nvml.nvmlDeviceGetPowerUsage(handle)
        power *= 0.001
        power_limit = nvml.nvmlDeviceGetPowerManagementLimit(handle)
        power_limit *= 0.001
        memory_info = nvml.nvmlDeviceGetMemoryInfo(handle)
        temp = nvml.nvmlDeviceGetTemperature(handle, nvml.NVML_TEMPERATURE_GPU)
        print('{}, gpu{}, {}%. {}%, {}Mib/{}Mib, {}W/{}W, {}C'.format(datetime.datetime.now().time(), i, util.gpu, util.memory, memory_info.used >> 20, memory_info.total >> 20, power, power_limit, temp))

    time.sleep(1)
