/*******************************************************************************
*
* FILE:		yystype.h for universe compiler
*
* DESC:		EECS 337 Assignment 3
*
* AUTHOR:	caseid
*
* DATE:		September 14, 2010
*
* EDIT HISTORY:	
*
*******************************************************************************/
#ifndef	YYSTYPE_H
#define	YYSTYPE_H	1

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<time.h>



/*
 *	define a clips structure
 *	supports: CONSTANT STRING_LITERAL IDENTIFIER types
 */
#define	CLIPS	struct clips
CLIPS
{
	CLIPS		*next;
	int		token;
	unsigned char	value;

#define MASK_METHOD 	(1<<0)
#define	MASK_CLASSDEF	(1<<1)
#define	MASK_NOLF	(1<<2)
/*
#define	MASK_BUFFER	(1<<3)
#define MASK_VALUE 	(1<<4)
#define MASK_VALUE 	(1<<5)
#define MASK_VALUE 	(1<<6)
#define MASK_VALUE 	(1<<7)
#define MASK_VALUE 	(1<<8)
#define MASK_VALUE 	(1<<9)
#define MASK_VALUE 	(1<<10)*/
	//10
	//20
	//40
	//80

	int		mask;
	char		*buffer;
	int		length;
	int		level;
};

/*
 *	define yystype
 */
#define YYSTYPE struct yyansi_c
YYSTYPE
{
	int	token;
	CLIPS	*clips;
};


/*
 *	define a global data structure
 */
#define	DATA	struct data
DATA
{
	int	column;
	int	flags;
	int errors;
	int warnings;
	int memory;
	CLIPS *typedef_table;
	int level;
	CLIPS *symbol_table;
	
#define	FLAGS_ECHO	0x0001
#define	FLAGS_DEBUG	0x0002
#define	FLAGS_PARSE	0x0004
#define FLAGS_SYMBOL 0x0008
#define FLAGS_MAIN 0x0010
#define IS_FLAGS_MAIN(a) (a & FLAGS_MAIN)
#define SET_FLAGS_MAIN(a) (a |= FLAGS_MAIN)
#define CLR_FLAGS_MAIN(a) (a &= ~FLAGS_MAIN)

#define	IS_FLAGS_ECHO(a)	(a & FLAGS_ECHO)	
#define	SET_FLAGS_ECHO(a)	(a |= FLAGS_ECHO)
#define	CLR_FLAGS_ECHO(a)	(a &= ~FLAGS_ECHO)
#define	IS_FLAGS_DEBUG(a)	(a & FLAGS_DEBUG)	
#define	SET_FLAGS_DEBUG(a)	(a |= FLAGS_DEBUG)
#define	CLR_FLAGS_DEBUG(a)	(a &= ~FLAGS_DEBUG)
#define	IS_FLAGS_PARSE(a)	(a & FLAGS_PARSE)	
#define	SET_FLAGS_PARSE(a)	(a |= FLAGS_PARSE)
#define	CLR_FLAGS_PARSE(a)	(a &= ~FLAGS_PARSE)
#define IS_FLAGS_SYMBOL(a)	(a & FLAGS_SYMBOL)
#define SET_FLAGS_SYMBOL(a) (a |= FLAGS_SYMBOL)
#define CLR_FLAGS_SYMBOL(a) (a &= ~FLAGS_SYMBOL)

};

/*
 *	define for yyparser debugging
 */
#define	YYDEBUG	1
/*
 *	external variables and functions from scan.l
 */
extern FILE	*yyin;
extern FILE	*yyout;
extern	char	*yytext;
extern	int	yyleng;
extern	int	yynerrs;
extern	YYSTYPE	yylval;		/* YYSTYPE */
extern	int	yywrap( void);
extern	void	pdefine( void);
extern	void	comment( void);
extern	void	count( void);
extern	int	check_type( void);

extern	char	*tokens[];
extern	char	*instr_table[];
extern	void	al_error( int length);
extern	char	*al_buffer( char *text, int length);
extern	void	de_buffer( char *buffer, int length);
extern	CLIPS	*al_clips( int token, unsigned char value, int mask, char *buffer, int length);
extern	void	de_clips( CLIPS *clips);
extern	void	de_clips_list( CLIPS *clips);
extern	CLIPS	*end_clips( CLIPS *clips);
extern	void	print_clips( CLIPS *clips);
extern	void	print_clips_list( CLIPS *clips);


/*
 *	external variables and functions from gram.y
 */
extern	int	yydebug;
extern	int	yyparse( void);
extern	void	yyerror( char *s);
/*
 *	external variables and functions from main.c
 */
extern	DATA	data;
extern	int	main( int argc, char *argv[]);

#endif
