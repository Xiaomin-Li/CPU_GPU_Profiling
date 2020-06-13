import psutil
import datetime  
import time
import sys
import signal

print(psutil.cpu_count())

for x in range(5):
    print(psutil.cpu_percent(interval=1, percpu=False))
    #print(psutil.cpu_percent(interval=1, percpu=True))
    print(psutil.cpu_freq())
    print(psutil.virtual_memory())
    print(psutil.disk_usage('/'))
    