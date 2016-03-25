/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

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

#ifndef YY_YY_EXPR_CODEGEN_TAB_H_INCLUDED
# define YY_YY_EXPR_CODEGEN_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_AND = 258,
    T_OR = 259,
    T_ASSIGN = 260,
    T_CLASS = 261,
    T_COMMA = 262,
    T_DIV = 263,
    T_PLUS = 264,
    T_MINUS = 265,
    T_MULT = 266,
    T_MOD = 267,
    T_LEFTSHIFT = 268,
    T_RIGHTSHIFT = 269,
    T_LPAREN = 270,
    T_RPAREN = 271,
    T_SEMICOLON = 272,
    T_EXTERN = 273,
    T_LCB = 274,
    T_RCB = 275,
    T_INTTYPE = 276,
    T_STRINGTYPE = 277,
    T_BOOL = 278,
    T_VOID = 279,
    T_EQ = 280,
    T_NEQ = 281,
    T_LT = 282,
    T_LEQ = 283,
    T_GT = 284,
    T_GEQ = 285,
    T_NOT = 286,
    T_INTCONSTANT = 287,
    T_CHARCONSTANT = 288,
    T_FALSE = 289,
    T_TRUE = 290,
    T_ID = 291,
    UMINUS = 292
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 134 "expr-codegen.y" /* yacc.c:1909  */

  class decafAST *ast;
  int number;
  std::string *sval;
  int decaftype;

#line 99 "expr-codegen.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_EXPR_CODEGEN_TAB_H_INCLUDED  */
