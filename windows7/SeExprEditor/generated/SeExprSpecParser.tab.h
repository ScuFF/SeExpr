
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef SeExprSpecYYTOKENTYPE
# define SeExprSpecYYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum SeExprSpectokentype {
     IF = 258,
     ELSE = 259,
     NAME = 260,
     VAR = 261,
     STR = 262,
     NUMBER = 263,
     AddEq = 264,
     SubEq = 265,
     MultEq = 266,
     DivEq = 267,
     ExpEq = 268,
     ModEq = 269,
     ARROW = 270,
     OR = 271,
     AND = 272,
     NE = 273,
     EQ = 274,
     GE = 275,
     LE = 276,
     UNARY = 277
   };
#endif
/* Tokens.  */
#define IF 258
#define ELSE 259
#define NAME 260
#define VAR 261
#define STR 262
#define NUMBER 263
#define AddEq 264
#define SubEq 265
#define MultEq 266
#define DivEq 267
#define ExpEq 268
#define ModEq 269
#define ARROW 270
#define OR 271
#define AND 272
#define NE 273
#define EQ 274
#define GE 275
#define LE 276
#define UNARY 277




#if ! defined SeExprSpecYYSTYPE && ! defined SeExprSpecYYSTYPE_IS_DECLARED
typedef union SeExprSpecYYSTYPE
{

/* Line 1676 of yacc.c  */
#line 224 "/home/fahome/jberlin/projects/SeExpr.linux/src/SeExprEditor/SeExprSpecParser.y"

    SeExprSpecNode* n;
    double d;      // return value for number tokens
    char* s;       /* return value for name tokens.  Note: UNLIKE the regular parser, this is not strdup()'dthe string */



/* Line 1676 of yacc.c  */
#line 104 "y.tab.h"
} SeExprSpecYYSTYPE;
# define SeExprSpecYYSTYPE_IS_TRIVIAL 1
# define SeExprSpecstype SeExprSpecYYSTYPE /* obsolescent; will be withdrawn */
# define SeExprSpecYYSTYPE_IS_DECLARED 1
#endif

extern SeExprSpecYYSTYPE SeExprSpeclval;

#if ! defined SeExprSpecYYLTYPE && ! defined SeExprSpecYYLTYPE_IS_DECLARED
typedef struct SeExprSpecYYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} SeExprSpecYYLTYPE;
# define SeExprSpecltype SeExprSpecYYLTYPE /* obsolescent; will be withdrawn */
# define SeExprSpecYYLTYPE_IS_DECLARED 1
# define SeExprSpecYYLTYPE_IS_TRIVIAL 1
#endif

extern SeExprSpecYYLTYPE SeExprSpeclloc;

