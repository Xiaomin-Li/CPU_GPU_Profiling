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

#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <signal.h>
#include "nvml.h"

//#include <windows.h>

//#include "marcher.h"

#define DEVICE 1

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

static void initAndTest(nvmlDevice_t *device)
{
    nvmlReturn_t result;
    nvmlMemory_t mem;
    unsigned int power;

    result = nvmlInit();
    if (NVML_SUCCESS != result) {
        printf("failed to initialize NVML: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetHandleByIndex(DEVICE, devi
        ce);
    if (NVML_SUCCESS != result) {
        printf("failed to get handle for device: %s\n", nvmlErrorString(result));
        exit(1);
    }

    result = nvmlDeviceGetPowerUsage(*device, &power);
    if (NVML_SUCCESS != result) {
        printf("failed to read power: %s\n", nvmlErrorString(result));
        exit(1);
    }
}

static inline void getInfo(nvmlDevice_t device, unsigned int *power, FILE* outputFile, struct timeval *startTime)
{
    nvmlDeviceGetPowerUsage(device, power);
    *power *= .001;

    struct timeval currentTime;
    double time_interval;
    gettimeofday(&currentTime, NULL);
    time_interval = ((currentTime.tv_sec*1e6 + currentTime.tv_usec) - (startTime->tv_sec*1e6 + startTime->tv_usec)) / 1e6;
    fprintf(outputFile, "%u, %f, \n", *power, secondsSince(startTime));
    //fprintf(outputFile, "%u, %f, \n", *power, time_interval);
}

static void sigterm_hdl(int sig) {
    nvmlShutdown();
    exit(1);
}

int main(int argc, char *argv[])
{
    nvmlDevice_t device;
    unsigned int power, delay_us;

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

    initAndTest(&device);

    // We write this 'Y' to STDOUT so master_meter will know that we're ready to start logging.
    // The master meter will block until this has been read. 
    char c = 'Y';
    write(STDOUT_FILENO, &c, 1);

	fprintf(outputFile, "GPU Power (W), Time (S), \n");
    // Begin power measurement.
	struct timeval start;
	gettimeofday(&start, NULL);
    do {
        usleep(delay_us);
        getInfo(device, &power, outputFile, &start);
    } while(1);
}