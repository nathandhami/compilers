%{
#include <stdio.h>
#define LINE  256
#define BLOCK 257
#define NEWLINE 258
#define STRING 259
%}

%%

\"(\\.|[^"])*\"				{ return STRING; }
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]	{ return BLOCK; }
"//".*                 			{ return LINE; }
\n                      		{ return NEWLINE; }
.                			{ return -1; }

%%

printWhiteSpace (int len, char *text) {
	int i = 0;
	while(i < len) {
		if (text[i] == '\n') {
			printf("\n");
			i++;
		} else {
			printf(" ");
			i++;
		}
	}; 
}

int main () {
  int token;
  while ((token = yylex())) {
    switch (token) {
      case LINE: printWhiteSpace((int)yyleng, yytext); break;
      case BLOCK: printWhiteSpace((int)yyleng, yytext); break;
      case STRING: printf("%s", yytext); break;
      case NEWLINE: printf("\n"); break;
      default: printf("%s", yytext);
    }
  }
  exit(0);
}
