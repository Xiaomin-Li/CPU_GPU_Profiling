CC=nvcc
CFLAGS= -I../include -O3 -w 
LDFLAGS= -L/usr/lib64/nvidia -lnvidia-ml
SOURCES= gpuLogToFile.cu 
OBJS= $(SOURCES:.cu=)

gpuLogToFile:
	${CC} ${CFLAGS} ${SOURCES} -o ${OBJS} ${LDFLAGS}

clean:
	-rm -f ${OBJS}
