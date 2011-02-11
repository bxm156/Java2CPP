#-----------------------------------------------------------------------------
#	Makefile
#	Fall 2010
#	by caseid
#-----------------------------------------------------------------------------
.KEEP_STATE:
SHELL=/bin/bash

#
#	define version of c compiler, linker and lex
#
GCC=	gcc
GPP=	g++
LEX=	flex
#
#	define yacc lex and compiler flags
#
YFLAGS	= -dv
LFLAGS	=
CFLAGS	= -g 

#
#	to make all
#
all:		Test0 Test0c Test1 Test1c Test2 Test2c Test3 Test3c

SRC_TEST0	= Test0.cpp
OBJ_TEST0	= Test0.o

Test0 :	$(OBJ_TEST0)
	$(GPP) $(CFLAGS) -S $(OBJ_TEST0) 

SRC_TEST0C	= Test0c.c
OBJ_TEST0C	= Test0c.o

Test0c :	$(OBJ_TEST0C)
	$(GCC) $(CFLAGS) -S $(OBJ_TEST0C) 

SRC_TEST1	= Test1.cpp
OBJ_TEST1	= Test1.o

Test1 :	$(OBJ_TEST1)
	$(GPP) $(CFLAGS) $(OBJ_TEST1) -o Test1

SRC_TEST1C	= Test1c.c
OBJ_TEST1C	= Test1c.o

Test1c :	$(OBJ_TEST1C)
	$(GCC) $(CFLAGS) $(OBJ_TEST1C) -o Test1c

SRC_TEST2	= Test2.cpp
OBJ_TEST2	= Test2.o

Test2 :	$(OBJ_TEST2)
	$(GPP) $(CFLAGS) $(OBJ_TEST2) -o Test2

SRC_TEST2C	= Test2c.c
OBJ_TEST2C	= Test2c.o

Test2c :	$(OBJ_TEST2C)
	$(GCC) $(CFLAGS) $(OBJ_TEST2C) -o Test2c

SRC_TEST3	= Test3.cpp
OBJ_TEST3	= Test3.o

Test3 :	$(OBJ_TEST3)
	$(GPP) $(CFLAGS) $(OBJ_TEST3) -o Test3

SRC_TEST3C	= Test3c.c
OBJ_TEST3C	= Test3c.o

Test3c :	$(OBJ_TEST3C)
	$(GCC) $(CFLAGS) $(OBJ_TEST3C) -o Test3c

clean	:
	rm -f *.o
