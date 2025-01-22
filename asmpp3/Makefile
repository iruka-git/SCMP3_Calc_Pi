#################################################################
#	コンパイラは MinGw gccを使用します。
#################################################################
# REMOVE DEFAULT MAKE RULE
MAKEFLAGS = -r

.SUFFIXES:

.SUFFIXES:	.c .o


#============================
# DOSかどうかチェック.
 ifdef ComSpec
MSDOS=1
 endif

 ifdef COMSPEC
MSDOS=1
 endif
#============================

 ifdef MSDOS
DOSFLAGS = -D_MSDOS_
EXE = .exe
WIN32LIB= -lkernel32 -luser32 -lgdi32 -lsetupapi 
 else
DOSFLAGS = -D_LINUX_
EXE =
WIN32LIB= 
 endif

#CFLAGS	= -g $(DOSFLAGS) $(CDEFS) -O2 -Wall
CFLAGS	= -s $(DOSFLAGS) $(CDEFS) -O2 -Wall
CFLAGS	+= -Wno-multichar
LIBS	=

TARGET  = asmpp3.exe
#TARGET  = asmpp3$(EXE)
#
#
#

CC = gcc
RC = windres

.c.o:
	$(CC) $(CFLAGS) -c $<
#
#
files	= asmpp3.o
#files	= main.o opcode.o disasm.o gr.o led.o debug.o linux.o
#
#
#
#
$(TARGET) : $(files)
	$(CC) $(CFLAGS) -o $@ $(files) $(WIN32LIB) -lm $(LIBS)
#	cp $(TARGET) ..
#
t1:	$(TARGET)
	./asmpp3.exe -r -S a.m
	cat a.asm
	asl -L a.asm
	cat a.lst
#
test:	$(TARGET)
	./asmpp3.exe -r -S infile.m
	cat infile.asm
	asl -L infile.asm
	cat infile.lst

#
test2:	$(TARGET)
	./asmpp3.exe -S infile.c
	cat infile.asm
#
#
clean:
	-rm *.o
	-rm *~
	-rm $(TARGET)
#
#
