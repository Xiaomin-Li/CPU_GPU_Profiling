import py3nvml.nvidia_smi as smi
import datetime  
import time

smi.nvmlInit()

handle0 = smi.nvmlDeviceGetHandleByIndex(0)
handle1 = smi.nvmlDeviceGetHandleByIndex(1)
handle2 = smi.nvmlDeviceGetHandleByIndex(2)
handle3 = smi.nvmlDeviceGetHandleByIndex(3)

current_time = datetime.datetime.now()
print(current_time + 'start gpu measurement')
time_count = 0
while True:
    print('Time:{}s'.format(time_count))
    res0 = smi.nvmlDeviceGetUtilizationRates(handle0)
    res1 = smi.nvmlDeviceGetUtilizationRates(handle1)
    res2 = smi.nvmlDeviceGetUtilizationRates(handle2)
    res3 = smi.nvmlDeviceGetUtilizationRates(handle3)

    print('gpu: {}%, gpu-mem: {}%'.format(res0.gpu, res0.memory))
    print('gpu: {}%, gpu-mem: {}%'.format(res1.gpu, res1.memory))
    print('gpu: {}%, gpu-mem: {}%'.format(res2.gpu, res2.memory))
    print('gpu: {}%, gpu-mem: {}%'.format(res3.gpu, res3.memory))
    time_count += 1
    sleep(1)
