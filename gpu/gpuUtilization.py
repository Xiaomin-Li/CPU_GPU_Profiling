import py3nvml.nvidia_smi as nvml
import datetime  
import time
import sys
import signal


def getGPUInfo():
    nvml.nvmlInit()
    num_gpus = nvml.nvmlDeviceGetCount()
    time_interval = float(sys.argv[1])
    filename = sys.argv[2] + '.txt' 

    file1 = open(filename,"w")

    file1.write('Number of GPUs {}\n'.format(num_gpus))
    file1.write('Time, device, gpu_util %, gpu-mem %, memory used Mib/ total Mib, power current W/ limit W, temperature C\n')
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
            file1.write('{}, gpu{}, {}%. {}%, {}Mib/{}Mib, {}W/{}W, {}C\n'.format(datetime.datetime.now().time(), i, util.gpu, util.memory, memory_info.used >> 20, memory_info.total >> 20, power, power_limit, temp))

        time.sleep(time_interval)
    file1.close()


class TimeoutException(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutException


if __name__ == '__main__':
    
    TIMEOUT = int(sys.argv[3])

    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(TIMEOUT)

    try:
        print('GPU profiling started, time now: {}'.format(datetime.datetime.now()))
        getGPUInfo()
    except TimeoutException:
        print('GPU profiling terminated, duration: {}s, time now: {}'.format(TIMEOUT, datetime.datetime.now()))