#-----------------------------------------------------------------------------
#	Makefile
#	EECS 337 Compilers Fall 2010
#	by caseid
#
# REVISION HISTORY
#
#-----------------------------------------------------------------------------
.KEEP_STATE:
SHELL=/bin/bash

#
#	define version of c compiler, linker and lex
#
CC=	gcc
LINK=	gcc
LEX=	flex
#
#	define yacc lex and compiler flags
#
YFLAGS	= -dv
LFLAGS	=
CFLAGS	= -g

SRC	= java11.y java.l main.c
OBJ	= java11.o java.o main.o

ansi_c :	$(OBJ)
	$(LINK) $(CFLAGS) $(OBJ) -o java2cpp

java.o	: y.tab.h

clean	:
	rm -f java.c java11.c y.tab.h y.output *.o

fromtar	:
	tar xvf project_caseid.tar 

totar	:
	tar cvf project_caseid.tar Makefile java11.y java.l main.c
