%{
/**************************************************************/
/* This file contains a restricted lexer for java language.   */
/* The lexer will scan java programs in ASCII without unicode */
/* characters and/or unicode escape sequences.                */
/* It is provided only to enable the grammar user to test it  */
/* right away.                                                */
/**************************************************************/
#include	"yystype.h"
#include	"y.tab.h"
#include 	"tokens.h"
#include	"encoding.c"
%}

Separator	[\(\)\{\}\[\]\;\,\.]
Delimiter1	[\=\>\<\!\~\?\:\+\-\*\/\&\|\^\%]
HexDigit	[0-9a-fA-F]
Digit		[0-9]
OctalDigit	[0-7]
TetraDigit	[0-3]
NonZeroDigit	[1-9]
Letter		[a-zA-Z_]
AnyButSlash	[^\/]
AnyButAstr	[^\*]
BLK		[\b]
TAB		[\t]
FF		[\f]
ESCCHR		[\\]
CR		[\r]
LF		[\n]

Escape		[\\]([r]|[n]|[b]|[f]|[t]|[\\]|[\"]|[\'])
Identifier 	{Letter}({Letter}|{Digit})*

Comment1        [\/][\*]({AnyButAstr}|[\*]{AnyButSlash})*[\*][\/]
Comment2        [\/][\/].*
Comment		({Comment1}|{Comment2})
WhiteSpace	({CR}|{LF}|{FF}|{TAB}|{BLK}|[ ])

Dimension	[\[]({WhiteSpace}|{Comment})*[\]]

IntSuffix	([l]|[L])
DecimalNum	{NonZeroDigit}{Digit}*{IntSuffix}?
OctalNum	[0]{OctalDigit}*{IntSuffix}?
HexNum		[0]([x]|[X]){HexDigit}{HexDigit}*{IntSuffix}?
IntegerLiteral	({DecimalNum}|{OctalNum}|{HexNum})

Sign		([\+]|[\-])
FlSuffix	([f]|[F]|[d][D])
SignedInt	{Sign}?{Digit}+
Expo		([e]|[E])
ExponentPart	{Expo}{SignedInt}?
Float1          {Digit}+[\.]{Digit}+?{ExponentPart}?{FlSuffix}? 
Float2		[\.]{Digit}+{ExponentPart}?{FlSuffix}?
Float3		{Digit}+{ExponentPart}{FlSuffix}?
Float4		{Digit}+{FlSuffix}
FloatingPoint	({Float1}|{Float2}|{Float3}|{Float4})

AnyChrChr	[^\\']
AnyStrChr	[^\\"]
Character	[\']({Escape}|{AnyChrChr})[\']
String		[\"]({Escape}|{AnyStrChr})*[\"]
Numeric  	({IntegerLiteral}|{FloatingPoint})
Literal		({Numeric}|{Character}|{String})



%%

"true"		{count(); yylval.clips = string_literal( yytext, yyleng); return(LITERAL); }
"false"		{ count(); yylval.clips = string_literal( yytext, yyleng); return(LITERAL); }

{Separator}	{return yytext[0];}
{Delimiter1}	{return yytext[0];}
{Dimension}	{count(); yylval.token = OP_DIM; yylval.clips = string_literal(yytext,yyleng); return OP_DIM;}

"=="		{return OP_EQ;}
"<="		{return OP_LE;}
">="		{return OP_GE;}
"!="		{return OP_NE;}
"||"		{return OP_LOR;}
"&&"		{return OP_LAND;}
"++"		{return OP_INC;}
"--"		{return OP_DEC;}
">>"		{return OP_SHR;}
"<<"		{return OP_SHL;}
">>>"		{return OP_SHRR;}
"+="		{return ASS_ADD;}
"-="		{return ASS_SUB;}
"*="		{return ASS_MUL;}
"/="		{return ASS_DIV;}
"&="		{return ASS_AND;}
"|="		{return ASS_OR;}
"^="		{return ASS_XOR;}
"%="		{return ASS_MOD;}
"<<="		{return ASS_SHL;}
">>="		{return ASS_SHR;}
">>>="		{return ASS_SHRR;}

"abstract"	{ count(); yylval.token = ABSTRACT; return ABSTRACT;}
"do"            { count(); yylval.token = DO; return DO;}
"implements"    { count(); yylval.token = IMPLEMENTS; return IMPLEMENTS;}
"package"	{ count(); yylval.token = PACKAGE;  return PACKAGE;}
"throw"		{ count(); yylval.token = THROW;  return THROW;}
"boolean"	{ count(); yylval.token = BOOLEAN; return BOOLEAN;}
"double"	{ count(); yylval.token = DOUBLE; return DOUBLE;}
"import"	{ count(); yylval.token = IMPORT; return IMPORT;}
"private"	{ count(); yylval.token = PRIVATE;  return PRIVATE;}
"throws"	{ count(); yylval.token = THROWS;  return THROWS;}
"break"		{ count(); yylval.token = BREAK;  return BREAK;}
"else"		{ count(); yylval.token = ELSE;  return ELSE;}
"inner"		{ count(); yylval.token = INNER;   return INNER;}
"protected"	{ count(); yylval.token = PROTECTED;  return PROTECTED;}
"transient"	{ count(); yylval.token = TRANSIENT;   return TRANSIENT;}
"byte"		{ count(); yylval.token = BYTE;  return BYTE;}
"extends"	{ count(); yylval.token = EXTENDS;   return EXTENDS;}
"instanceof"	{ count(); yylval.token = INSTANCEOF;  return INSTANCEOF;}
"public"	{ count(); yylval.token = PUBLIC;  return PUBLIC;}
"try"		{ count(); yylval.token = TRY;  return TRY;}
"case"		{ count(); yylval.token = CASE; return CASE;}
"final"		{ count(); yylval.token = FINAL; return FINAL;}
"int"		{ count(); yylval.token = INT; return INT;}
"rest"		{ count(); yylval.token = REST;  return REST;}
"var"		{ count(); yylval.token = VAR;  return VAR;}
"cast"		{ count(); yylval.token = CAST; return CAST;}
"finally"	{ count(); yylval.token = FINALLY;  return FINALLY;}
"interface"	{ count(); yylval.token = INTERFACE; return INTERFACE;}
"return"	{ count(); yylval.token = RETURN;  return RETURN;}
"void"		{ count(); yylval.token = VOID;  return VOID;}
"catch"		{ count(); yylval.token = CATCH; return CATCH;}
"float"		{ count(); yylval.token = FLOAT; return FLOAT;}
"long"		{ count(); yylval.token = LONG; return LONG;}
"short"		{ count(); yylval.token = SHORT;  return SHORT;}
"volatile"	{ count(); yylval.token = VOLATILE; return VOLATILE;}
"char"		{ count(); yylval.token = CHAR;  return CHAR;}
"for"		{ count(); yylval.token = FOR;  return FOR;}
"native"	{ count(); yylval.token = NATIVE;   return NATIVE;}
"static"	{ count(); yylval.token = STATIC;  return STATIC;}
"while"		{ count(); yylval.token = WHILE;   return WHILE;}
"class"		{ count(); yylval.token = CLASS;  return CLASS;}
"future"	{ count(); yylval.token = FUTURE;  return FUTURE;}
"new"		{ count(); yylval.token = NEW;  return NEW;}
"super"		{ count(); yylval.token = SUPER;   return SUPER;}
"const"		{ count(); yylval.token = CONST; return CONST;}
"generic"	{ count(); yylval.token = GENERIC;   return GENERIC;}
"null"		{ count(); yylval.token = JNULL;  return JNULL;}
"switch"	{ count(); yylval.token = SWITCH;  return SWITCH;}
"continue"	{ count(); yylval.token = CONTINUE;  return CONTINUE;}
"goto"		{ count(); yylval.token = GOTO;   return GOTO;}
"operator"	{ count(); yylval.token = OPERATOR; return OPERATOR;}
"synchronized"	{ count(); yylval.token = SYNCHRONIZED;  return SYNCHRONIZED;}
"default"	{ count(); yylval.token = DEFAULT;   return DEFAULT;}
"if"		{ count(); yylval.token = IF;   return IF;}
"outer"		{ count(); yylval.token = OUTER;  return OUTER;}
"this"		{ count(); yylval.token =  THIS; return THIS;}



"unsigned"	{ count(); yylval.token = UNSIGNED; return UNSIGNED; }
"typedef"	{ count(); yylval.token = TYPEDEF; return TYPEDEF; }

{Identifier}	{ count(); yylval.clips = identifier( yytext, yyleng); return(check_type());}

{Literal}		{ count(); yylval.clips = string_literal( yytext, yyleng); return(LITERAL);}

{WhiteSpace}    { count(); }
{Comment}	{ }
%%

/*
 *	yywrap function
 */
int	yywrap( void)
{
	return(1);
}

/*
 *	update the current column index value
 */
void	count( void)
{
	int i;

	for( i = 0; yytext[i] != '\0'; i++)
		if( yytext[i] == '\n')
			data.column = 0;
		else if( yytext[i] == '\t')
			data.column += 8 - (data.column % 8);
		else
			data.column++;
	if( yytext[0] && IS_FLAGS_ECHO( data.flags))
	    ECHO;
}
/*
 *	c comment function
 */
void	comment( void)
{
	char c, c1;

	if( IS_FLAGS_ECHO( data.flags))
	    ECHO;
loop:
	while(( c = input()) != '*' && c != 0)
	      if( c && IS_FLAGS_ECHO( data.flags))
	      	  putchar(c);
	if( c != 0)
	      if( IS_FLAGS_ECHO( data.flags))
	      	  putchar(c);

	if(( c1 = input()) != '/' && c != 0)
	{
		unput(c1);
		goto loop;
	}
	if( c != 0)
	      if( IS_FLAGS_ECHO( data.flags))
	      	  putchar(c1);
}

int check_type()
{

/*
*	it actually will only return IDENTIFIER
*/
	CLIPS *lists;
	for (lists = data.typedef_table; lists; lists = lists->next)
	{
		if(!strcmp(lists->buffer,yytext))
		{
			de_clips(yylval.clips);
			yylval.token = lists->token;
			return (yylval.token);
		}
	}

	return(IDENTIFIER);
}

