CC=nvcc
CFLAGS= -I../include -O3 -w 
LDFLAGS= -L/usr/lib64/nvidia -lnvidia-ml
SOURCES= k20LoggerToFile.cu 
OBJECTS= $(SOURCES:.cu=.o)
BINARIES= $(SOURCES:.cu=)

all: $(SOURCES) $(BINARIES)

$(BINARIES): $(OBJECTS)
	$(CC) $@.o marcher.o -o $@ $(LDFLAGS)
$(OBJECTS): $(SOURCES)
	$(CC) -c $(CFLAGS) $*.cu -o $@
	g++ -c ../include/marcher.cpp -o marcher.o
clean:
	$(RM) $(OBJECTS) $(BINARIES) marcher.o
