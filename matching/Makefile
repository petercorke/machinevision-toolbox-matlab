# for Matlab R11 and earlier use the following line
#MEX = cmex
# for Matlab R12 use the following line
MEX = mex
MODULES =  SAD.o SSD.o NCC.o ZSAD.o ZSSD.o ZNCC.o RANK_TX.o CENSUS.o LEFT_RIGHT.o

CC = gcc

CFLAGS = -DSTANDALONE -O2

all:	mex match

mex:
	$(MEX) CENSUS.c
	$(MEX) NCC.c
	$(MEX) SAD.c
	$(MEX) ZNCC.c
	$(MEX) ZSSD.c
	$(MEX) LEFT_RIGHT.c
	$(MEX) RANK_TX.c
	$(MEX) SSD.c
	$(MEX) ZSAD.c

match:	match.o $(MODULES) pgm.o
	$(CC) -o match match.o $(MODULES) pgm.o -lm

clean:
	/bin/rm *.o match *.mex*
