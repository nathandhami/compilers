%{
#include <stdio.h>
#include <sstream> 
#include <iostream>
#include <fstream>

using namespace std;

#define T_AND 256
#define T_ASSIGN 257
#define T_BOOL 258
#define T_BREAK 259
#define T_CHARCONSTANT 260
#define T_CLASS 261
#define T_COMMA 262
#define T_COMMENT 263
#define T_CONTINUE 264
#define T_DIV 265
#define T_DOT 266
#define T_ELSE 267
#define T_EQ 268
#define T_EXTENDS 269
#define T_EXTERN 270
#define T_FALSE 271
#define T_FOR 272
#define T_GEQ 273
#define T_GT 274
#define T_ID 275
#define T_IF 276
#define T_INTCONSTANT 277
#define T_INTTYPE 278
#define T_LCB 279
#define T_LEFTSHIFT 280
#define T_LEQ 281
#define T_LPAREN 282
#define T_LSB 283
#define T_LT 284
#define T_MINUS 285
#define T_MOD 286
#define T_MULT 287
#define T_NEQ 288
#define T_NEW 289
#define T_NOT 290
#define T_NULL 291
#define T_OR 292
#define T_PLUS 293
#define T_RCB 294
#define T_RETURN 295
#define T_RIGHTSHIFT 296
#define T_RPAREN 297
#define T_RSB 298
#define T_SEMICOLON 299
#define T_STRINGCONSTANT 300
#define T_STRINGTYPE 301
#define T_TRUE 302
#define T_VOID 303
#define T_WHILE 304
#define T_WHITESPACE 305
#define T_ERR_UNK_ESCAPE 306
#define T_ERR_NEWLINE_IN_STRING 307
#define T_ERR_CHAR_LENGTH_GREATER_THAN_ONE 308
#define T_ERR_UNT_CHAR_CONST 309
#define T_ERR_CHAR_ZERO_WIDTH 310
#define T_ERR_UNEXPECTED_CHAR 311

%}

/* token definitions */
%option yylineno

%%

"//".*|"//".*\n		{ return T_COMMENT; }
&&			{ return T_AND; }
=  			{ return T_ASSIGN; }
bool  		{ return T_BOOL; }
break  		{ return T_BREAK; }
'\\'              { return T_ERR_UNT_CHAR_CONST; }
 \'[^\/]'|\'\\[t|v|r|n|a|f|b|\\|'|"]\'        { return T_CHARCONSTANT;}
class			{ return T_CLASS; }
,			{ return T_COMMA; }
continue		{ return T_CONTINUE; }
\/			{ return T_DIV; }
\.			{ return T_DOT; }
else			{ return T_ELSE; }
==			{ return T_EQ; }
extends		{ return T_EXTENDS; }
extern		{ return T_EXTERN; }
false			{ return T_FALSE; }
for			{ return T_FOR; }
\>=			{ return T_GEQ; }
\>			{ return T_GT; }
if			{ return T_IF; }
([0-9]*[0-9])|(0x|0X)[A-F|a-f|0-9]*       { return T_INTCONSTANT; }
int			{ return T_INTTYPE; }
\{			{ return T_LCB; }
\<<			{ return T_LEFTSHIFT; }
\<=			{ return T_LEQ; }
\(			{ return T_LPAREN; }
\[			{ return T_LSB; }
\<			{ return T_LT; }
\-			{ return T_MINUS; }
\%			{ return T_MOD; }
\*			{ return T_MULT; }
\!=			{ return T_NEQ; }
new			{ return T_NEW; }
\!			{ return T_NOT; }
null			{ return T_NULL; }
\|\|			{ return T_OR; }
\+			{ return T_PLUS; }
\}			{ return T_RCB; }
return		{ return T_RETURN; }
\>>			{ return T_RIGHTSHIFT; }
\)			{ return T_RPAREN; }
\]			{ return T_RSB; }
\;			{ return T_SEMICOLON; }
\"\\[^nrtvfab\\"']                                    { return T_ERR_UNK_ESCAPE; }
\"([a-z|A-Z|0-9|_|'|\,|\.| ]|\\[nrtvfab\\"'])*\"      { return T_STRINGCONSTANT; }
string		{ return T_STRINGTYPE; }
true			{ return T_TRUE; }
void			{ return T_VOID; }
while			{ return T_WHILE; }
[a-z|A-Z|_]*[a-z|A-Z|_|0-9]               { return T_ID; }
(\n|\r|\v|\f|\t|" ")*(\n|\r|\v|\f|\t|" ") { return T_WHITESPACE; }
\"[\"\n\\]\"                              { return T_ERR_NEWLINE_IN_STRING; }
\'([^\'][^\'])[^\']*\'  { return T_ERR_CHAR_LENGTH_GREATER_THAN_ONE; }
''                                        { return T_ERR_CHAR_ZERO_WIDTH; }
.                                         { return T_ERR_UNEXPECTED_CHAR; }

%%

void createFile(string errorMessageString, int lineNumber, int position) {
  string lexicalError = "";
  string strLineNumber = "";
  string strPosition  = "";

  stringstream ss;
  stringstream ss2;

  ss << lineNumber;       
  strLineNumber = ss.str();

  ss2 << position;
  strPosition = ss2.str();

  errorMessageString = errorMessageString + "\n";
  lexicalError = "Lexical error: line " + strLineNumber + ", position " + strPosition; 

  fprintf(stderr, "%s", errorMessageString.c_str());
  fprintf(stderr, "%s", lexicalError.c_str());

}

int calcpos(char* text, int currpos) {
	for (int i = 0; i < yyleng; i++) {
		if (text[i] == '\n') {
                	// find a new line so set position back to 0
                	currpos = 0;
		} else {
			currpos++;
		}	
	}
	return currpos;
}

int main() {

  int token;
  int position = 0;
  int lineNumber = 0;
  string message = "";

  while ((token = yylex())) {
    lineNumber = yylineno;
    position = calcpos(yytext, position);
    
    switch (token) {
      case T_AND: printf("T_AND %s\n", yytext); break;
      case T_ASSIGN: printf("T_ASSIGN %s\n", yytext); break;
      case T_BOOL: printf("T_BOOL %s\n", yytext); break;
      case T_BREAK: printf("T_BREAK %s\n", yytext); break;
      case T_CHARCONSTANT: printf("T_CHARCONSTANT %s\n", yytext); break;
      case T_CLASS: printf("T_CLASS %s\n", yytext); break;
      case T_COMMA: printf("T_COMMA %s\n", yytext); break;
      case T_CONTINUE: printf("T_CONTINUE %s\n", yytext); break;
      case T_DIV: printf("T_DIV %s\n", yytext); break;
      case T_DOT: printf("T_DOT %s\n", yytext); break;
      case T_ELSE: printf("T_ELSE %s\n", yytext); break;
      case T_EQ: printf("T_EQ %s\n", yytext); break;
      case T_EXTENDS: printf("T_EXTENDS %s\n", yytext); break;
      case T_EXTERN: printf("T_EXTERN %s\n", yytext); break;
      case T_FALSE: printf("T_FALSE %s\n", yytext); break;
      case T_FOR: printf("T_FOR %s\n", yytext); break;
      case T_GEQ: printf("T_GEQ %s\n", yytext); break;
      case T_GT: printf("T_GT %s\n", yytext); break;
      case T_ID: printf("T_ID %s\n", yytext); break;
      case T_IF: printf("T_IF %s\n", yytext); break;
      case T_INTCONSTANT: printf("T_INTCONSTANT %s\n", yytext); break;
      case T_INTTYPE: printf("T_INTTYPE %s\n", yytext); break;
      case T_LCB: printf("T_LCB %s\n", yytext); break;
      case T_LEFTSHIFT: printf("T_LEFTSHIFT %s\n", yytext); break;
      case T_LEQ: printf("T_LEQ %s\n", yytext); break;
      case T_LPAREN: printf("T_LPAREN %s\n", yytext); break;
      case T_LSB: printf("T_LSB %s\n", yytext); break;
      case T_LT: printf("T_LT %s\n", yytext); break;
      case T_MINUS: printf("T_MINUS %s\n", yytext); break;
      case T_MOD: printf("T_MOD %s\n", yytext); break;
      case T_MULT: printf("T_MULT %s\n", yytext); break;
      case T_NEQ: printf("T_NEQ %s\n", yytext); break;
      case T_NEW: printf("T_NEW %s\n", yytext); break;
      case T_NOT: printf("T_NOT %s\n", yytext); break;
      case T_NULL: printf("T_NULL %s\n", yytext); break;
      case T_OR: printf("T_OR %s\n", yytext); break;
      case T_PLUS: printf("T_PLUS %s\n", yytext); break;
      case T_RCB: printf("T_RCB %s\n", yytext); break;
      case T_RETURN: printf("T_RETURN %s\n", yytext); break;
      case T_RIGHTSHIFT: printf("T_RIGHTSHIFT %s\n", yytext); break;
      case T_RPAREN: printf("T_RPAREN %s\n", yytext); break;
      case T_RSB: printf("T_RSB %s\n", yytext); break;
      case T_SEMICOLON: printf("T_SEMICOLON %s\n", yytext); break;
      case T_STRINGCONSTANT: printf("T_STRINGCONSTANT %s\n", yytext); break;
      case T_STRINGTYPE: printf("T_STRINGTYPE %s\n", yytext); break;
      case T_TRUE: printf("T_TRUE %s\n", yytext); break;
      case T_VOID: printf("T_VOID %s\n", yytext); break;
      case T_WHILE: printf("T_WHILE %s\n", yytext); break;

      case T_COMMENT:
		printf("T_COMMENT ");
		for (int i = 0; i < yyleng; i++) {
			if (yytext[i] == '\n') {
				printf("%s", "\\n");
			} else {
				printf("%c", yytext[i]);
			}	
		}
		printf("\n");
		break;

      case T_WHITESPACE: 
		printf("T_WHITESPACE ");
		for (int i = 0; i < yyleng; i++) {
			if (yytext[i] == '\n') {
				printf("%s", "\\n");
			} else {
				printf("%c", yytext[i]);
			}	
		}
		printf("\n");
		break;

      // errors
      case T_ERR_UNK_ESCAPE:                    
	position = position - (yyleng - 1); 
	createFile("Error: unknown escape sequence in string constant", lineNumber, position); 		yytext; 
	exit(1);
      case T_ERR_NEWLINE_IN_STRING:              
	createFile("Error: newline in string constant", lineNumber, position);
	 yytext;
	 exit(1);
      case T_ERR_CHAR_LENGTH_GREATER_THAN_ONE:  
	position = position - (yyleng - 1); 
	createFile("Error: char constant length is greater than one", lineNumber, position); 		yytext; 
	exit(1);
      case T_ERR_UNT_CHAR_CONST:
	position = position - (yyleng - 1);                
	createFile("Error: unterminated char constant", lineNumber, position); 
	yytext; 
	exit(1);
      case T_ERR_CHAR_ZERO_WIDTH:               
	position = position - (yyleng - 1); 
	createFile("Error: char constant has zero width", lineNumber, position); 
	yytext; 
	exit(1);
      default:                                  
	createFile("Error: unexpected character in input", lineNumber, position); 
	yytext; 
	exit(1);
    }
  }

  exit(0);
}
