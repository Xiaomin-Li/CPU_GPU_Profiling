import py3nvml.nvidia_smi as smi
smi.nvmlInit()
handle = smi.nvmlDeviceGetHandleByIndex(0)

res = smi.nvmlDeviceGetUtilizationRates(handle)
print('gpu: {}%, gpu-mem: {}%'.format(res.gpu, res.memory))