/*
  Copyright (c) 2013, Texas State University-San Marcos. All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted for academic, research, experimental, or personal use provided
  that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
  * Neither the name of Texas State University-San Marcos nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

  For all other uses, please contact the Office for Commercialization and Industry
  Relations at Texas State University-San Marcos <http://www.txstate.edu/ocir/>.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Author: Martin Burtscher (in collaboration with Ivan Zecena and Ziliang Zong)
*/

//compile 
//nvcc -I../include -O3 -w k20LoggerToFile.cu -o gpuToFIle -L/usr/lib64/nvidia -lnvidia-ml
//only used for rainbow-panda server which has four devices 

#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <signal.h>
#include "nvml.h"

//#include <windows.h>

//#include "marcher.h"

#define DEVICE0 0
#define DEVICE1 1
#define DEVICE2 2
#define DEVICE3 3

double secondsSince(struct timeval *startTime) {
    struct timeval currentTime;
    gettimeofday(&currentTime, NULL);
    return ((currentTime.tv_sec*1e6 + currentTime.tv_usec) - (startTime->tv_sec*1e6 + startTime->tv_usec)) / 1e6;
}


static inline double getTime()
{
    struct timeval time;
    gettimeofday(&time, NULL);
    return time.tv_sec + time.tv_usec * 0.000001;
}

static void initAndTest(nvmlDevice_t *device0, nvmlDevice_t *device1, nvmlDevice_t *device2, nvmlDevice_t *device3)
{
    nvmlReturn_t result;
    nvmlMemory_t mem;
    unsigned int power;

    result = nvmlInit();
    if (NVML_SUCCESS != result) {
        printf("failed to initialize NVML: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetHandleByIndex(DEVICE0, device0);
    if (NVML_SUCCESS != result) {
        printf("failed to get handle for device: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetHandleByIndex(DEVICE1, device1);
    if (NVML_SUCCESS != result) {
        printf("failed to get handle for device: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetHandleByIndex(DEVICE2, device2);
    if (NVML_SUCCESS != result) {
        printf("failed to get handle for device: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetHandleByIndex(DEVICE3, device3);
    if (NVML_SUCCESS != result) {
        printf("failed to get handle for device: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetPowerUsage(*device0, &power);
    if (NVML_SUCCESS != result) {
        printf("failed to read power: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetPowerUsage(*device1, &power);
    if (NVML_SUCCESS != result) {
        printf("failed to read power: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetPowerUsage(*device2, &power);
    if (NVML_SUCCESS != result) {
        printf("failed to read power: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetPowerUsage(*device3, &power);
    if (NVML_SUCCESS != result) {
        printf("failed to read power: %s\n", nvmlErrorString(result));
        exit(1);
    }
}

static inline void getInfo
    (
        nvmlDevice_t device0, nvmlDevice_t device1, nvmlDevice_t device2, nvmlDevice_t device3, 
        unsigned int *power0, unsigned int *power1, unsigned int *power2, unsigned int *power3, 
        unsigned int *temp0, unsigned int *temp1, unsigned int *temp2, unsigned int *temp3,
        nvmlUtilization_t *u0, nvmlUtilization_t *u1, nvmlUtilization_t *u2, nvmlUtilization_t *u3,
        FILE* outputFile, struct timeval *startTime
    )
{

    nvmlDeviceGetPowerUsage(device0, power0);
    *power0 *= .001;

    nvmlDeviceGetPowerUsage(device1, power1);
    *power1 *= .001;

    nvmlDeviceGetPowerUsage(device2, power2);
    *power2 *= .001;

    nvmlDeviceGetPowerUsage(device3, power3);
    *power3 *= .001;


    nvmlDeviceGetTemperature(device0, NVML_TEMPERATURE_GPU, temp0);
    nvmlDeviceGetTemperature(device1, NVML_TEMPERATURE_GPU, temp1);
    nvmlDeviceGetTemperature(device2, NVML_TEMPERATURE_GPU, temp2);
    nvmlDeviceGetTemperature(device3, NVML_TEMPERATURE_GPU, temp3);

    nvmlDeviceGetUtilizationRates(device0, u0);
    nvmlDeviceGetUtilizationRates(device1, u1);
    nvmlDeviceGetUtilizationRates(device2, u2);
    nvmlDeviceGetUtilizationRates(device3, u3);

    unsigned int total_power;
    total_power = *power0 + *power1 + *power2 + *power3;

    struct timeval currentTime;
    double time_interval;
    gettimeofday(&currentTime, NULL);
    //get device utilization api only support fermi and quadro architrcture cards.
    //for panda server, it contains RTX 2080ti cards which don't have supportion.
    //util->gpu return gpu utilization, util->memory return gpu memory utilization  
    time_interval = ((currentTime.tv_sec*1e6 + currentTime.tv_usec) - (startTime->tv_sec*1e6 + startTime->tv_usec)) / 1e6;
    fprintf(outputFile, "%f, %u, %u, %u, %u, %u, %u, %u, %u, %u, %u, %u, %u, %u\n", 
            secondsSince(startTime), total_power, 
            *power0, *temp0, u0->gpu, *power1, *temp1, u1->gpu, *power2, *temp2, u2->gpu, *power3, *temp3, u3->gpu 
            );
}

static void sigterm_hdl(int sig) {
    nvmlShutdown();
    exit(1);
}

int main(int argc, char *argv[])
{
    nvmlDevice_t device0, device1, device2, device3;
    unsigned int power0, power1, power2, power3, delay_us;
    unsigned int temp0, temp1, temp2, temp3;
    nvmlUtilization_t u0, u1, u2, u3;


    if (argc != 3 || atoi(argv[1]) <= 0) {
        fprintf(stderr, "Usage: %s [sampling rate (Hz)] [output filename]\n", argv[0]);
        return 1;
    }
	delay_us = 1e6 / atoi(argv[1]);
	char filename[512];
	char hostname[9];
	hostname[8] = NULL;
	gethostname(hostname, 8);
	snprintf(filename, 512, "%s_GPU-%s.csv", hostname, argv[2]);
	FILE *outputFile = fopen(filename, "w");
	if (outputFile == NULL) {
	   fprintf(stderr, "Unable to open output file.\n");
	   return 1;
	}
	setbuf(outputFile, NULL);
    if (delay_us <= 0) {
        fprintf(stderr, "[GPU meter]: Sampling delay must be a nonnegative integer.");
        return 1;
    }

    // SIGTERM handler
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigterm_hdl;
    if (sigaction(SIGTERM, &sa, 0)) {
        fprintf(stderr,"[GPU meter]: Sigaction failed.\n");
        exit(1);
    }

    initAndTest(&device0, &device1, &device2, &device3);

    // We write this 'Y' to STDOUT so master_meter will know that we're ready to start logging.
    // The master meter will block until this has been read. 
    char c = 'Y';
    write(STDOUT_FILENO, &c, 1);

	fprintf(outputFile, "Time(S), Total(w), power0(W), temp0(C), util0, power1(W), temp1(C), util1, power2(W), temp2(C), util1, power3(W), temp3(C), util3\n");
    // Begin power measurement.
	struct timeval start;
	gettimeofday(&start, NULL);
    do {
        usleep(delay_us);
        getInfo
            (
                device0, device1, device2, device3, 
                &power0, &power1, &power2, &power3, 
                &temp0, &temp1, &temp2, &temp3,
                &u0, &u1, &u2, &u3,
                outputFile, &start
            );
    } while(1);
}