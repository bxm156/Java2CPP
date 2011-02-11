%{
/*------------------------------------------------------------------
 * Copyright (C) 1996, 1997 Dmitri Bronnikov, All rights reserved.
 *
 * THIS GRAMMAR IS PROVIDED "AS IS" WITHOUT  ANY  EXPRESS  OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES  OF  MERCHANTABILITY  AND  FITNESS  FOR  A  PARTICULAR
 * PURPOSE, OR NON-INFRINGMENT.
 *
 * Bronikov@inreach.com
 *
 *------------------------------------------------------------------
 *
 * VERSION 1.03 DATE 11 NOV 1997
 *
 *------------------------------------------------------------------
 *
 * UPDATES
 *
 * 1.03 Added Java 1.1 changes:
 *      inner classes,
 *      anonymous classes,
 *      non-static initializer blocks,
 *      array initialization by new operator
 * 1.02 Corrected cast expression syntax
 * 1.01 All shift/reduce conflicts, except dangling else, resolved
 *
 *------------------------------------------------------------------
 *
 * PARSING CONFLICTS RESOLVED
 *
 * Some Shift/Reduce conflicts have been resolved at the expense of
 * the grammar defines a superset of the language. The following
 * actions have to be performed to complete program syntax checking:
 *
 * 1) Check that modifiers applied to a class, interface, field,
 *    or constructor are allowed in respectively a class, inteface,
 *    field or constructor declaration. For example, a class
 *    declaration should not allow other modifiers than abstract,
 *    final and public.
 *
 * 2) For an expression statement, check it is either increment, or
 *    decrement, or assignment expression.
 *
 * 3) Check that type expression in a cast operator indicates a type.
 *    Some of the compilers that I have tested will allow simultaneous
 *    use of identically named type and variable in the same scope
 *    depending on context.
 *
 * 4) Change lexical definition to change '[' optionally followed by
 *    any number of white-space characters immediately followed by ']'
 *    to OP_DIM token. I defined this token as [\[]{white_space}*[\]]
 *    in the lexer.
 *
 *------------------------------------------------------------------
 *
 * UNRESOLVED SHIFT/REDUCE CONFLICTS
 *
 * Dangling else in if-then-else
 *
 *------------------------------------------------------------------
 */
#include	"yystype.h"
#include	"y.tab.h"
#include	"audit2.c"
#include	"symbols.c"
#include	"functions.c"
#include 	"codegencpp.c"


%}

%token ABSTRACT
%token BOOLEAN BREAK BYTE BYVALUE
%token CASE CAST CATCH CHAR CLASS CONST CONTINUE
%token DEFAULT DO DOUBLE
%token ELSE EXTENDS
%token FINAL FINALLY FLOAT FOR FUTURE
%token GENERIC GOTO
%token IF IMPLEMENTS IMPORT INNER INSTANCEOF INT INTERFACE
%token LONG
%token NATIVE NEW JNULL
%token OPERATOR OUTER
%token PACKAGE PRIVATE PROTECTED PUBLIC
%token REST RETURN
%token SHORT STATIC SUPER SWITCH SYNCHRONIZED
%token THIS THROW THROWS TRANSIENT TRY
%token VAR VOID VOLATILE
%token WHILE
%token OP_INC OP_DEC
%token OP_SHL OP_SHR OP_SHRR
%token OP_GE OP_LE OP_EQ OP_NE
%token OP_LAND OP_LOR
%token OP_DIM
%token ASS_MUL ASS_DIV ASS_MOD ASS_ADD ASS_SUB
%token ASS_SHL ASS_SHR ASS_SHRR ASS_AND ASS_XOR ASS_OR
%token IDENTIFIER LITERAL BOOLLIT

%token UNSIGNED_CHAR UNSIGNED_INT TYPEDEF_CHAR TYPEDEF_INT UNSIGNED TYPEDEF

%start CompilationUnit

%%

TypeSpecifier
	: TypeName
	| TypeName Dims
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

TypeName
	: PrimitiveType
	| QualifiedName
	;

ClassNameList
        : QualifiedName
        | ClassNameList ',' QualifiedName
        {
        	CLIPS *c = createFromString(",");
        	$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
        }
	;

PrimitiveType
	: BOOLEAN
	  {
		$$.clips = createFromStringWithToken("bool",BOOLEAN);
	  }
	| CHAR
	{
		$$.clips = createFromStringWithToken("char",CHAR);
	}
	| BYTE
	{
		$$.clips = createFromStringWithToken("byte",BYTE);
	}
	| SHORT
	{
		$$.clips = createFromStringWithToken("short",SHORT);
	}
	| INT
	{
		$$.clips = createFromStringWithToken("int",INT);
	}
	| LONG
	{
		$$.clips = createFromStringWithToken("long",LONG);
	}
	| FLOAT
	{
		$$.clips = createFromStringWithToken("float",FLOAT);
	}
	| DOUBLE
	{
		$$.clips = createFromStringWithToken("double",DOUBLE);
	}
	| VOID
	{
		$$.clips = createFromStringWithToken("void",VOID);
	}
	;

CompilationUnit
	: ProgramFile
	{
		code_generator_cpp($1.clips);
	}
    ;

ProgramFile
	: PackageStatement ImportStatements TypeDeclarations
	  {
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips);
	  }
	| PackageStatement ImportStatements
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	| PackageStatement                  TypeDeclarations
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	|                  ImportStatements TypeDeclarations
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	| PackageStatement
	|                  ImportStatements
	|                                   TypeDeclarations
	;

PackageStatement
	: PACKAGE QualifiedName ';'
	  {
		$$.clips = handlePackageStatement($2.clips);
	  }
	;

TypeDeclarations
	: TypeDeclaration
	| TypeDeclarations TypeDeclaration
	{
		$$.clips =  clips_tail_to_head($1.clips,$2.clips);
	}
	;

ImportStatements
	: ImportStatement
	  {
		$$.clips = handleImportStatement($1.clips,0);
	  }
	| ImportStatements ImportStatement
	{
	$$.clips = handleImportStatement($1.clips,$2.clips);
	}
	;

ImportStatement
	: IMPORT QualifiedName ';'
	  {
		CLIPS *c1 = createFromStringWithToken("import",IMPORT);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2);
	  }
	| IMPORT QualifiedName '.' '*' ';'
	{
		CLIPS *c1 = createFromStringWithToken("import",IMPORT);
		CLIPS *c2 = createFromString(".*");
		CLIPS *c3 = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2),c3);
	}
	;

QualifiedName
	: IDENTIFIER
	  {
		$$.clips = auditIdentifier($1.clips);
	  }
	| QualifiedName '.' IDENTIFIER
	{
		$$.clips = auditForArrow($1.clips,$3.clips);
	}
	
	;

TypeDeclaration
	: ClassHeader '{' FieldDeclarations '}'
	  {
		CLIPS *left = createFromString("{");
		CLIPS *right = createFromString("};");
		//$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
		$$.clips =clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),right),$3.clips);
	  }
	| ClassHeader '{' '}'
	{
		CLIPS *left = createFromString("{");
		CLIPS *right = createFromString("};");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,left),right);
	}
	;

ClassHeader
	: Modifiers ClassWord IDENTIFIER Extends Interfaces
	  {
		CLIPS *c = $3.clips;
		c->token = $2.token;
		CLIPS *c2 = createFromString(",");
		CLIPS *c3 = createFromString(":");
		$$.clips =  clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c,c3),$4.clips),c2),$5.clips);
		de_clips_list($1.clips);
		maskClips($$.clips,MASK_CLASSDEF);
	  }
	| Modifiers ClassWord IDENTIFIER Extends
	{
		CLIPS *c = $3.clips;
		c->token = $2.token;
		CLIPS *c2 = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c,c2),$4.clips);
		de_clips_list($1.clips);
		maskClips($$.clips,MASK_CLASSDEF);
		//
		//$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$4.clips);
	}
	| Modifiers ClassWord IDENTIFIER       Interfaces
	{	
		CLIPS *c = $3.clips;	
		c->token = $2.token;
		CLIPS *c2 = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c,c2),$4.clips);
		de_clips_list($1.clips);
		maskClips($$.clips,MASK_CLASSDEF);
	}
	|           ClassWord IDENTIFIER Extends Interfaces
	{
		CLIPS *c = $2.clips;
		c->token = $1.token;
		CLIPS *c2 = createFromString(",");
		CLIPS *c3 = createFromString(":");
		$$.clips =  clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c,c3),$3.clips),c2),$4.clips);
		maskClips($$.clips,MASK_CLASSDEF);
	}
	| Modifiers ClassWord IDENTIFIER
	{
		CLIPS *c = $3.clips;
		c->token = $2.token;
		//$$.clips = clips_tail_to_head($1.clips,c);
		$$.clips = c;
		de_clips_list($1.clips);
		maskClips($$.clips,MASK_CLASSDEF);
	}
	|           ClassWord IDENTIFIER Extends
	{
		CLIPS *c = $2.clips;
		c->token = $1.token;
		CLIPS *c2 = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c,c2),$3.clips);
		maskClips($$.clips,MASK_CLASSDEF);
	}
	|           ClassWord IDENTIFIER       Interfaces
	{
		CLIPS *c = $2.clips;
		c->token = $1.token;
		CLIPS *c2 = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c,c2),$3.clips);
		maskClips($$.clips,MASK_CLASSDEF);
	}
	|           ClassWord IDENTIFIER
	{
		$$.clips = $2.clips;
		$$.clips->token = $1.token;
		maskClips($$.clips,MASK_CLASSDEF);
	}
	;

Modifiers
	: Modifier
	| Modifiers Modifier
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

Modifier
	: ABSTRACT
	  {
	  		$$.clips = createModifier($1.token);
	  }
	| FINAL
	{
			$$.clips = createModifier($1.token);
		}
	| PUBLIC
	{
		$$.clips = createModifier($1.token);
	}
	| PROTECTED
	{
			$$.clips = createModifier($1.token);
	}
	| PRIVATE
	{
			$$.clips = createModifier($1.token);
	}
	| STATIC
	{
			$$.clips = createModifier($1.token);
	}
	| TRANSIENT
	{
			$$.clips = createModifier($1.token);
	}
	| VOLATILE
	{
			$$.clips = createModifier($1.token);
	}
	| NATIVE
	{
			$$.clips = createModifier($1.token);
	}
	| SYNCHRONIZED
	{
			$$.clips = createModifier($1.token);
	}
	;

ClassWord
	: CLASS
	| INTERFACE
	;

Interfaces
	: IMPLEMENTS ClassNameList
	  {
		CLIPS *start = $2.clips;
		while(start)
		{
			if(strcmp(start->buffer,",") == 0)
			{
				CLIPS *c = createFromStringWithToken(" public ",IMPLEMENTS);
				c->next = start->next;
				start->next = c;
			}
			start = start->next;
		}
		CLIPS *c = createFromStringWithToken(" public ",IMPLEMENTS);
		$$.clips = clips_tail_to_head(c,$2.clips);
	  }
	;

FieldDeclarations
	: FieldDeclaration
    | FieldDeclarations FieldDeclaration
    {
		clips_tail_to_head($1.clips,$2.clips);
    }
	;

FieldDeclaration
	: FieldVariableDeclaration ';'
	  {
		CLIPS *c = createFromString(";");
		CLIPS *param = clips_tail_to_head($1.clips,c);
		addClassParam(param);
		$$.clips = createFromString("");
		de_clips_list(param);
	  }
	| MethodDeclaration
	| ConstructorDeclaration
	{
		addClassParam($1.clips);
		$$.clips = createFromString("");
		de_clips_list($1.clips);
	}
	| StaticInitializer
    | NonStaticInitializer
    | TypeDeclaration
	;

FieldVariableDeclaration
	: Modifiers TypeSpecifier VariableDeclarators
	  {
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips);
	  }
	|           TypeSpecifier VariableDeclarators
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

VariableDeclarators
	: VariableDeclarator
	| VariableDeclarators ',' VariableDeclarator
	{
		$$.clips = clips_tail_to_head($1.clips,$3.clips);
	}
	;

VariableDeclarator
	: DeclaratorName
	| DeclaratorName '=' VariableInitializer
	{
		CLIPS *declar = auditForPointer($1.clips,$3.clips);
		CLIPS *c = createFromString("= ");
		$$.clips = clips_tail_to_head(declar,clips_tail_to_head(c,$3.clips));
	}
	;

VariableInitializer
	: Expression
	| '{' '}'
	{
		CLIPS *left = createFromString("{");
		CLIPS *right = createFromString("}");
		$$.clips = clips_tail_to_head(left,right);
	}
	| '{' ArrayInitializers '}'
	{
		CLIPS *left = createFromString("{");
		CLIPS *right = createFromString("}");
		$$.clips = clips_tail_to_head(clips_tail_to_head(left,$2.clips),right);
	}
	;

ArrayInitializers
	: VariableInitializer
	| ArrayInitializers ',' VariableInitializer
	{
		$$.clips = clips_tail_to_head($1.clips,$3.clips);
	}
	| ArrayInitializers ','
	;

MethodDeclaration
	: Modifiers TypeSpecifier MethodDeclarator Throws MethodBody
	  {
			
		if(strcmp($3.clips->buffer,"main") == 0)
		{
			$$.clips = createMain($5.clips);
			de_clips_list($1.clips);
			de_clips_list($2.clips);
			de_clips_list($3.clips);
			de_clips_list($4.clips);
		} else {
			int isStatic = processMethod($1.clips,$2.clips,$3.clips,$4.clips,$5.clips);
			if(isStatic)
			{
				CLIPS *c = createFromStringWithToken("static",STATIC);
				$$.clips = clips_tail_to_head(c,clips_tail_to_head(clips_tail_to_head($2.clips,$3.clips),$5.clips));
			} else {
			$$.clips = clips_tail_to_head($2.clips,clips_tail_to_head($3.clips,$5.clips));
			}
			de_clips_list($1.clips);
			de_clips_list($4.clips);
		}
	}
	| Modifiers TypeSpecifier MethodDeclarator        MethodBody
	{
		if(strcmp($3.clips->buffer,"main") == 0)
		{
			$$.clips = createMain($4.clips);
			de_clips_list($1.clips);
			de_clips_list($2.clips);
			de_clips_list($3.clips);
		} else {
			int isStatic = processMethod($1.clips,$2.clips,$3.clips,0,$4.clips);
			if(isStatic)
			{
				CLIPS *c = createFromStringWithToken("static",STATIC);
				$$.clips = clips_tail_to_head(c,clips_tail_to_head(clips_tail_to_head($2.clips,$3.clips),$4.clips));
			} else {
				$$.clips = clips_tail_to_head(clips_tail_to_head($2.clips,$3.clips),$4.clips);
			}
			de_clips_list($1.clips);
		}
	}
	|           TypeSpecifier MethodDeclarator Throws MethodBody
	{
		if(strcmp($3.clips->buffer,"main") == 0)
		{
			$$.clips = createMain($4.clips);
			de_clips_list($1.clips);
			de_clips_list($2.clips);
			de_clips_list($3.clips);
		} else {
			int isStatic = processMethod(0,$1.clips,$2.clips,$3.clips,$4.clips);
			if(isStatic)
			{
				CLIPS *c = createFromStringWithToken("static",STATIC);
				$$.clips = clips_tail_to_head(c,clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$4.clips));
			} else {
		$$.clips = clips_tail_to_head($1.clips,clips_tail_to_head($2.clips,$4.clips));
			}
			de_clips_list($3.clips);
		}
	}
	|           TypeSpecifier MethodDeclarator        MethodBody
	{
		if(strcmp($3.clips->buffer,"main") == 0)
		{
			$$.clips = createMain($3.clips);
			de_clips_list($1.clips);
			de_clips_list($2.clips);
		} else {
			int isStatic = processMethod(0,$1.clips,$2.clips,0,$3.clips);
			if(isStatic)
			{
				CLIPS *c = createFromStringWithToken("static",STATIC);
				$$.clips = clips_tail_to_head(c,clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips));
			} else {
			$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips);
			}
		}
	}
	;

MethodDeclarator
	: DeclaratorName '(' ParameterList ')'
	  {
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
	  }
	| DeclaratorName '(' ')'
	{
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,left),right);
	}
	| MethodDeclarator OP_DIM
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

ParameterList
	: Parameter
	| ParameterList ',' Parameter
	{
		CLIPS *c = createFromString(",");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
	}
	;

Parameter
	: TypeSpecifier DeclaratorName
	  {
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	  }
	;

DeclaratorName
	: IDENTIFIER
	| DeclaratorName OP_DIM
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

Throws
	: THROWS ClassNameList
	  {
		$$.clips = $2.clips;
		$$.clips->token = THROWS;
	  }
	;

MethodBody
	: Block
	| ';'
	{
		$$.clips = createFromString(";");
	}
	;

ConstructorDeclaration
	: Modifiers ConstructorDeclarator Throws Block
	  {
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips),$4.clips);
	  }
	| Modifiers ConstructorDeclarator        Block
	{
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips);
	}
	|           ConstructorDeclarator Throws Block
	{
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips);
	}
	|           ConstructorDeclarator        Block
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

ConstructorDeclarator
	: IDENTIFIER '(' ParameterList ')'
	  {
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
	  }
	| IDENTIFIER '(' ')'
	{
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,left),right);
	}
	;

StaticInitializer
	: STATIC Block
	  {
		CLIPS *c = createFromStringWithToken("static",STATIC);
		$$.clips = clips_tail_to_head(c,$2.clips);
	  }
	;

NonStaticInitializer
        : Block
        ;

Extends
	: EXTENDS TypeName
	  {
		CLIPS *c = createFromString (" public ");
		$$.clips = clips_tail_to_head(c,$2.clips);
		/*
		$$.clips = $2.clips;
		$$.clips->token = $1.token;
	  */
	  }
	| Extends ',' TypeName
	{
		CLIPS *c = createFromString (", public ");
		$$.clips = clips_tail_to_head($1.clips,clips_tail_to_head(c,$3.clips));
		/*
		$3.clips->token = EXTENDS;
		$$.clips = clips_tail_to_head($1.clips,$3.clips);
		*/
	}
	;

Block
	: '{' LocalVariableDeclarationsAndStatements '}'
	  {
		CLIPS *left = createFromString("{");
		CLIPS *right = createFromString("}");
		$$.clips = clips_tail_to_head(clips_tail_to_head(left,$2.clips),right);
	  }
	| '{' '}'
	{
		
		CLIPS *left = createFromString("{");
		CLIPS *right = createFromString("}");
		$$.clips = clips_tail_to_head(left,right);
			
	}
    ;

LocalVariableDeclarationsAndStatements
	: LocalVariableDeclarationOrStatement
	| LocalVariableDeclarationsAndStatements LocalVariableDeclarationOrStatement
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

LocalVariableDeclarationOrStatement
	: LocalVariableDeclarationStatement
	| Statement
	;

LocalVariableDeclarationStatement
	: Modifiers TypeSpecifier VariableDeclarators ';'
	  {
		CLIPS *c = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips),c);
	  }
	| TypeSpecifier VariableDeclarators ';'
	{
		CLIPS *c = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),c);
	}
	;

Statement
	: EmptyStatement
	| LabeledStatement
	| ExpressionStatement ';'
	{
		CLIPS *c = createFromString(";");
		$$.clips = clips_tail_to_head($1.clips,c);
	}
        | SelectionStatement
        | IterationStatement
	| JumpStatement
	| GuardingStatement
	| Block
	;

EmptyStatement
	: ';'
	{
		$$.clips = createFromString(";");
	}
        ;

LabeledStatement
	: IDENTIFIER ':' LocalVariableDeclarationOrStatement
	  {
		CLIPS *c = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
	  }
        | CASE ConstantExpression ':' LocalVariableDeclarationOrStatement
        {
        	CLIPS *c1 = createFromStringWithToken("case",CASE);
        	CLIPS *c2 = createFromString(":");
        	$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,$1.clips),c2),$4.clips);
        }
	| DEFAULT ':' LocalVariableDeclarationOrStatement
	{
		CLIPS *c1 = createFromStringWithToken("default",DEFAULT);
		CLIPS *c2 = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,c2),$3.clips);
	}
        ;

ExpressionStatement
	: Expression
	;

SelectionStatement
	: IF '(' Expression ')' Statement
	  {
		CLIPS *c1 = createFromStringWithToken("if",IF);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),right),$5.clips);
	  }
        | IF '(' Expression ')' Statement ELSE Statement
        {
        	CLIPS *c1 = createFromStringWithToken("if",IF);
        	CLIPS *left = createFromString("(");
        	CLIPS *right = createFromString(")");
        	CLIPS *c2 = createFromStringWithToken("else",ELSE);
        	$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),right),$5.clips),c2),$7.clips);
        }
        | SWITCH '(' Expression ')' Block
        {
        	CLIPS *c1 = createFromStringWithToken("switch",SWITCH);
        	CLIPS *left = createFromString("(");
        	CLIPS *right = createFromString(")");
        	$$.clips =   clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),right),$5.clips);
        }
        ;

IterationStatement
	: WHILE '(' Expression ')' Statement
	  {
		CLIPS *c1 = createFromStringWithToken("while",WHILE);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),right),$5.clips);
	 }
	| DO Statement WHILE '(' Expression ')' ';'
	{
		CLIPS *c1 = createFromStringWithToken("do",DO);
		CLIPS *c2 = createFromStringWithToken("while",WHILE);
		CLIPS *c3 = createFromString(";");
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips =   clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2),left),$5.clips),right),c3);
	}
	| FOR '(' ForInit ForExpr ForIncr ')' Statement
	{
		CLIPS *c1 = createFromStringWithToken("for",FOR);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		maskClips($3.clips,MASK_NOLF);
		maskClips($4.clips,MASK_NOLF);
		maskClips($5.clips,MASK_NOLF);
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),$4.clips),$5.clips),right),$7.clips);
	}
	| FOR '(' ForInit ForExpr         ')' Statement
	{
		CLIPS *c1 = createFromStringWithToken("for",FOR);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		maskClips($3.clips,MASK_NOLF);
		maskClips($4.clips,MASK_NOLF);
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),$4.clips),right),$6.clips);
	}
	;

ForInit
	: ExpressionStatements ';'
	  {
		CLIPS *c = createFromString(";");
		$$.clips = clips_tail_to_head($1.clips,c);
	  }
	| LocalVariableDeclarationStatement
	| ';'
	{
		$$.clips = createFromString(";");
	}
	;

ForExpr
	: Expression ';'
	  {
		CLIPS *c = createFromString(";");
		$$.clips = clips_tail_to_head($1.clips,c);
	  }
	| ';'
	{
		$$.clips = createFromString(";");
	}
	;

ForIncr
	: ExpressionStatements
	;

ExpressionStatements
	: ExpressionStatement
	| ExpressionStatements ',' ExpressionStatement
	{
		CLIPS *c = createFromString(",");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
	}
	;

JumpStatement
	: BREAK IDENTIFIER ';'
	  {
		CLIPS *c1 = createFromStringWithToken("break",BREAK);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2);
	  }
	| BREAK            ';'
	{
		CLIPS *c1 = createFromStringWithToken("break",BREAK);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(c1,c2);
	}
    | CONTINUE IDENTIFIER ';'
    {
		CLIPS *c1 = createFromStringWithToken("continue",CONTINUE);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2);
    }
	| CONTINUE            ';'
	{
		CLIPS *c1 = createFromStringWithToken("continue",CONTINUE);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(c1,c2);
		}
	| RETURN Expression ';'
	{
		CLIPS *c1 = createFromStringWithToken("return",RETURN);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2);
	}
	| RETURN            ';'
	{
		CLIPS *c1 = createFromStringWithToken("return",RETURN);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(c1,c2);
	}
	| THROW Expression ';'
	{
		CLIPS *c1 = createFromStringWithToken("throw",THROW);
		CLIPS *c2 = createFromString(";");
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),c2);
	}
	;

GuardingStatement
	: SYNCHRONIZED '(' Expression ')' Statement
	  {
		CLIPS *c1 = createFromStringWithToken("synchronized",SYNCHRONIZED);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),right),$5.clips);
	  }
	| TRY Block Finally
	{
		CLIPS *c1 = createFromStringWithToken("try",TRY);
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),$3.clips);
	}
	| TRY Block Catches
	{
		CLIPS *c1 = createFromStringWithToken("try",TRY);
		$$.clips = clips_tail_to_head(clips_tail_to_head(c1,$2.clips),$3.clips);
	}
	| TRY Block Catches Finally
	{
		CLIPS *c1 = createFromStringWithToken("try",TRY);
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,$2.clips),$3.clips),$4.clips);
	}
	;

Catches
	: Catch
	| Catches Catch
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

Catch
	: CatchHeader Block
	  {
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	  }
	;

CatchHeader
	: CATCH '(' TypeSpecifier IDENTIFIER ')'
	  {
	  		CLIPS *c1 = createFromStringWithToken("catch",CATCH);
	  		CLIPS *left = createFromString("(");
	  		CLIPS *right = createFromString(")");
	  		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),$4.clips),right);
	  	}
	| CATCH '(' TypeSpecifier ')'
	{
		CLIPS *c1 = createFromStringWithToken("catch",CATCH);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c1,left),$3.clips),right);
	}
	;

Finally
	: FINALLY Block
	  {
		CLIPS *c1 = createFromStringWithToken("finally",FINALLY);
		$$.clips = clips_tail_to_head(c1,$2.clips);
	  }
	;

PrimaryExpression
	: QualifiedName
	| NotJustName
	;

NotJustName
	: SpecialName
	| NewAllocationExpression
	| ComplexPrimary
	;

ComplexPrimary
	: '(' Expression ')'
	  {
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(left,$2.clips),right);
	  }
	| ComplexPrimaryNoParenthesis
	;

ComplexPrimaryNoParenthesis
	: LITERAL
	| BOOLLIT
	| ArrayAccess
	| FieldAccess
	| MethodCall
	;

ArrayAccess
	: QualifiedName '[' Expression ']'
	  {
		CLIPS *left = createFromString("[");
		CLIPS *right = createFromString("]");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
	  }
	| ComplexPrimary '[' Expression ']'
	{
			CLIPS *left = createFromString("[");
			CLIPS *right = createFromString("]");
			$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
		  }
	;

FieldAccess
	: NotJustName '.' IDENTIFIER
	{
		  CLIPS *c = createFromString(".");
		  $$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
		  
	}
	| RealPostfixExpression '.' IDENTIFIER
	{
		  CLIPS *c = createFromString(".");
		  $$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
	}
	;

MethodCall
	: MethodAccess '(' ArgumentList ')'
	  {
		if(strcmp($1.clips->buffer,"System.out.println") == 0 || strcmp($1.clips->buffer,"System.out.print") == 0 )
		{
			$$.clips = processPrintLine($3.clips);
			de_clips_list($1.clips);
		} else {
			CLIPS *left = createFromString("(");
			CLIPS *right = createFromString(")");
			$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
		}
	}
	| MethodAccess '(' ')'
	{
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,left),right);
	}
	;

MethodAccess
	: ComplexPrimaryNoParenthesis
	| SpecialName
	| QualifiedName
	;

SpecialName
	: THIS
	| SUPER
	| JNULL
	;

ArgumentList
	: Expression
	| ArgumentList ',' Expression
	{
		CLIPS *c = createFromString(",");
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,c),$3.clips);
	}
	;

NewAllocationExpression
    	: ArrayAllocationExpression
    	| ClassAllocationExpression
    	| ArrayAllocationExpression '{' '}'
    	{
    		CLIPS *left = createFromString("{");
    		CLIPS *right = createFromString("}");
    		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,left),right);
    	}
    	| ClassAllocationExpression '{' '}'
    	{
			CLIPS *left = createFromString("{");
			CLIPS *right = createFromString("}");
			$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,left),right);
    	}
    	| ArrayAllocationExpression '{' ArrayInitializers '}'
    	{
    		CLIPS *left = createFromString("{");
    		CLIPS *right = createFromString("}");
    		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
    	}
    	| ClassAllocationExpression '{' FieldDeclarations '}'
    	{
			CLIPS *left = createFromString("{");
			CLIPS *right = createFromString("}");
			$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,left),$3.clips),right);
    	}
    	;

ClassAllocationExpression
	: NEW TypeName '(' ArgumentList ')'
	  {
		CLIPS *c = createFromStringWithToken("new",NEW);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c,$2.clips),left),$4.clips),right);
	  }
	| NEW TypeName '('              ')'
	{
		CLIPS *c = createFromStringWithToken("new",NEW);
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c,$2.clips),left),right);
	}
        ;

ArrayAllocationExpression
	: NEW TypeName DimExprs Dims
	  {
		CLIPS *c = createFromStringWithToken("new",NEW);
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(c,$2.clips),$3.clips),$4.clips);
	  }
	| NEW TypeName DimExprs
	{
		CLIPS *c = createFromStringWithToken("new",NEW);
		$$.clips = clips_tail_to_head(clips_tail_to_head(c,$2.clips),$3.clips);
	}
        | NEW TypeName Dims
        {
        	CLIPS *c = createFromStringWithToken("new",NEW);
        	$$.clips = clips_tail_to_head(clips_tail_to_head(c,$2.clips),$3.clips);
        }
	;

DimExprs
	: DimExpr
	| DimExprs DimExpr
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

DimExpr
	: '[' Expression ']'
	  {
		CLIPS *left = createFromString("[");
		CLIPS *right = createFromString("]");
		$$.clips = clips_tail_to_head(clips_tail_to_head(left,$2.clips),right);
	  }
	;

Dims
	: OP_DIM
	  {
		$$.clips = $1.clips;
		$$.clips->token = OP_DIM;
	  }
	| Dims OP_DIM
	{
		CLIPS *c = $2.clips;
		c->token = OP_DIM;
		$$.clips = clips_tail_to_head($1.clips,c);
	}
	;

PostfixExpression
	: PrimaryExpression
	| RealPostfixExpression
	;

RealPostfixExpression
	: PostfixExpression OP_INC
	  {
		CLIPS *c = createFromStringWithToken("++",OP_INC);
		$$.clips = clips_tail_to_head($1.clips,c);
	  }
	| PostfixExpression OP_DEC
	{
		CLIPS *c = createFromStringWithToken("--",OP_DEC);
		$$.clips = clips_tail_to_head($1.clips,c);
	}
	;

UnaryExpression
	: OP_INC UnaryExpression
	  {
		CLIPS *c = createFromStringWithToken("++",OP_INC);
		$$.clips = clips_tail_to_head(c,$2.clips);
	  }
	| OP_DEC UnaryExpression
	{
		CLIPS *c = createFromStringWithToken("--",OP_DEC);
		$$.clips = clips_tail_to_head(c,$2.clips);
	}
	| ArithmeticUnaryOperator CastExpression
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	| LogicalUnaryExpression
	;

LogicalUnaryExpression
	: PostfixExpression
	| LogicalUnaryOperator UnaryExpression
	{
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	}
	;

LogicalUnaryOperator
	: '~'
	{
		$$.clips = createFromString("~");
	}	
	| '!'
	{
		$$.clips = createFromString("!");
	}
	;

ArithmeticUnaryOperator
	: '+'
	{
		$$.clips = createFromString("+");
	}	
	| '-'
	{
		$$.clips = createFromString("-");
	}
	;

CastExpression
	: UnaryExpression
	| '(' PrimitiveTypeExpression ')' CastExpression
	{
		CLIPS *left = createFromString("(");
		CLIPS *right = createFromString(")");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(left,$2.clips),right),$4.clips);
	}
	| '(' ClassTypeExpression ')' CastExpression
	{
			CLIPS *left = createFromString("(");
			CLIPS *right = createFromString(")");
			$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(left,$2.clips),right),$4.clips);
		}
	| '(' Expression ')' LogicalUnaryExpression
	{
			CLIPS *left = createFromString("(");
			CLIPS *right = createFromString(")");
			$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(left,$2.clips),right),$4.clips);
		}
	;

PrimitiveTypeExpression
	: PrimitiveType
        | PrimitiveType Dims
        {
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
        }
        ;

ClassTypeExpression
	: QualifiedName Dims
	  {
		$$.clips = clips_tail_to_head($1.clips,$2.clips);
	  }
    ;

MultiplicativeExpression
	: CastExpression
	| MultiplicativeExpression '*' CastExpression
	{
		CLIPS *c1 = createFromString("*");
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	| MultiplicativeExpression '/' CastExpression
	{
		CLIPS *c1 = createFromString("/");
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	| MultiplicativeExpression '%' CastExpression
	{
		CLIPS *c1 = createFromString("%");
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	;

AdditiveExpression
	: MultiplicativeExpression
        | AdditiveExpression '+' MultiplicativeExpression
        {
			CLIPS *c1 = createFromString("+");
			$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        | AdditiveExpression '-' MultiplicativeExpression
        {
        	CLIPS *c1 = createFromString("-");
        	$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        ;

ShiftExpression
	: AdditiveExpression
        | ShiftExpression OP_SHL AdditiveExpression
        {
		CLIPS *c1 = createFromStringWithToken("<<=",OP_SHL);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        | ShiftExpression OP_SHR AdditiveExpression
        {
		CLIPS *c1 = createFromStringWithToken(">>=",OP_SHR);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        | ShiftExpression OP_SHRR AdditiveExpression
        {
			CLIPS *c1 = createFromStringWithToken(">>>=",OP_SHRR);
			$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
	;

RelationalExpression
	: ShiftExpression
        | RelationalExpression '<' ShiftExpression
        {
		CLIPS *c1 = createFromString("<");
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
	| RelationalExpression '>' ShiftExpression
	{
		CLIPS *c1 = createFromString(">");
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	| RelationalExpression OP_LE ShiftExpression
	{
		CLIPS *c1 = createFromStringWithToken("<=",OP_LE);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	| RelationalExpression OP_GE ShiftExpression
	{
		CLIPS *c1 = createFromStringWithToken(">=",OP_GE);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	| RelationalExpression INSTANCEOF TypeSpecifier
	{
		CLIPS *c1 = createFromStringWithToken("instanceof",INSTANCEOF);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	;

EqualityExpression
	: RelationalExpression
        | EqualityExpression OP_EQ RelationalExpression
        {
			CLIPS *c1 = createFromStringWithToken("==",OP_EQ);
			$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        | EqualityExpression OP_NE RelationalExpression
        {
        	CLIPS *c1 = createFromStringWithToken("!=",OP_NE);
        	$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        ;

AndExpression
	: EqualityExpression
        | AndExpression '&' EqualityExpression
        {
			CLIPS *c1 = createFromString("&");
			$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
        }
        ;

ExclusiveOrExpression
	: AndExpression
	| ExclusiveOrExpression '^' AndExpression
	{
		CLIPS *c1 = createFromString("^");
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	;

InclusiveOrExpression
	: ExclusiveOrExpression
	| InclusiveOrExpression '|' ExclusiveOrExpression
	{
	CLIPS *c1 = createFromString("|");
	$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	;

ConditionalAndExpression
	: InclusiveOrExpression
	| ConditionalAndExpression OP_LAND InclusiveOrExpression
	{
		CLIPS *c1 = createFromStringWithToken("&&",OP_LAND);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	;

ConditionalOrExpression
	: ConditionalAndExpression
	| ConditionalOrExpression OP_LOR ConditionalAndExpression
	{
		CLIPS *c1 = createFromStringWithToken("||",OP_LOR);
		$$.clips =  clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips);
	}
	;

ConditionalExpression
	: ConditionalOrExpression
	| ConditionalOrExpression '?' Expression ':' ConditionalExpression
	{
		CLIPS *c1 = createFromString("?");
		CLIPS *c2 = createFromString(":");
		$$.clips = clips_tail_to_head(clips_tail_to_head(clips_tail_to_head(clips_tail_to_head($1.clips,c1),$3.clips),c2),$5.clips);
	}
	;

AssignmentExpression
	: ConditionalExpression
	| UnaryExpression AssignmentOperator AssignmentExpression
	{
		$$.clips = clips_tail_to_head(clips_tail_to_head($1.clips,$2.clips),$3.clips);
	}
	;

AssignmentOperator
	: '='
	{
		$$.clips = createFromString("=");
	}	
	| ASS_MUL
	{
		$$.clips = createFromStringWithToken("*=",ASS_MUL);
	}
	| ASS_DIV
	{
		$$.clips = createFromStringWithToken("/=",ASS_DIV);
	}
	| ASS_MOD
	{
		$$.clips = createFromStringWithToken("%=",ASS_MOD);
	}
	| ASS_ADD
	{
		$$.clips = createFromStringWithToken("+=",ASS_ADD);
	}
	| ASS_SUB
	{
		$$.clips = createFromStringWithToken("-=",ASS_SUB);
	}
	| ASS_SHL
	{
		$$.clips = createFromStringWithToken("<<=",ASS_SHL);
	}
	| ASS_SHR
	{
		$$.clips = createFromStringWithToken(">>=",ASS_SHR);
	}
	| ASS_SHRR
	{
		$$.clips = createFromStringWithToken(">>>=",ASS_SHRR);
	}
	| ASS_AND
	{
		$$.clips = createFromStringWithToken("&=",ASS_AND);
	}
	| ASS_XOR
	{
		$$.clips = createFromStringWithToken("^=",ASS_XOR);
	}
	| ASS_OR
	{
		$$.clips = createFromStringWithToken("|=",ASS_OR);
	}
	;

Expression
	: AssignmentExpression
    ;

ConstantExpression
	: ConditionalExpression
	;

%%

void	yyerror( char *s)
{
	printf("\n%*s\n%*s\n", data.column, "^", data.column, s);
}

