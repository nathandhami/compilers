%{
#include "usingcpp-defs.h"
#include "decaf-ast.tab.h"
#include <cstring>
#include <string>
#include <sstream>
#include <iostream>

using namespace std;

int lineno = 1;
int tokenpos = 1;

string remove_newlines (string s) {
  string newstring;
  for (string::iterator i = s.begin(); i != s.end(); i++) {
    switch(*i) {
    case '\n':
      lineno += 1; tokenpos = 0;
      newstring.push_back('\\');
      newstring.push_back('n');
       printf("%s ", yytext); 
      break;
    case '(':
      newstring.push_back('\\');
      newstring.push_back('(');
      break;
    case ')':
      newstring.push_back('\\');
      newstring.push_back(')');
      break;
    default:
      newstring.push_back(*i);
    }
  }
  return newstring;
}

void process_ws() {
  tokenpos += yyleng;
  string lexeme(yytext);
  printf(" ");
  lexeme = remove_newlines(lexeme);
}



string *process_string (const char *s) {
  string *ns = new string("");
  size_t len = strlen(s);
  // remove the double quotes, use s[1..len-1]
  for (int i = 1; i < len-1; i++) {
    if (s[i] == '\\') {
      i++;
      switch(s[i]) {
      case 't': ns->push_back('\t'); break;
      case 'v': ns->push_back('\v'); break;
      case 'r': ns->push_back('\r'); break;
      case 'n': ns->push_back('\n'); break;
      case 'a': ns->push_back('\a'); break;
      case 'f': ns->push_back('\f'); break;
      case 'b': ns->push_back('\b'); break;
      case '\\': ns->push_back('\\'); break;
      case '\'': ns->push_back('\''); break;
      case '\"': ns->push_back('\"'); break;
      default: throw runtime_error("unknown char escape\n");  
      }
    } else {
      ns->push_back(s[i]);
    }
  }
  return ns;
}

int get_charconstant(const char *s) {
  if (s[1] == '\\') { // backslashed char
    switch(s[2]) {
    case 't': return (int)'\t';
    case 'v': return (int)'\v';
    case 'r': return (int)'\r';
    case 'n': return (int)'\n';
    case 'a': return (int)'\a';
    case 'f': return (int)'\f';
    case 'b': return (int)'\b';
    case '\\': return (int)'\\';
    case '\'': return (int)'\'';
    default: throw runtime_error("unknown char constant\n");
    }
  } else {
    return (int)s[1];
  }
}

int get_intconstant(const char *s) {
  if ((s[0] == '0') && (s[1] == 'x')) {
    int x;
    sscanf(s, "%x", &x);
    return x;
  } else {
    return atoi(s);
  }
}

%}

chars    [ !\"#\$%&\(\)\*\+,\-\.\/0-9:;\<=>\?\@A-Z\[\]\^\_\`a-z\{\|\}\~\t\v\r\n\a\f\b]
charesc  \\[\'tvrnafb\\]
stresc   \\[\'\"tvrnafb\\]

%%
  /*
    Pattern definitions for all tokens 
  */

&&                           { printf("%s", yytext); return T_AND; }
=                            { printf("%s", yytext);return T_ASSIGN; }
bool                         { printf("%s", yytext);return T_BOOL; }
break                        { printf("%s", yytext);return T_BREAK; }
('{chars}')|('{charesc}')    { printf("%s", yytext); yylval.number = get_charconstant(yytext); return T_CHARCONSTANT; }
class                        { printf("%s", yytext); return T_CLASS; }
,                            { printf("%s", yytext);return T_COMMA; }
"//".*|"//".*\n              { printf("%s", yytext);return T_COMMENT; }
continue                     { printf("%s", yytext);return T_CONTINUE; }
\.                           { printf("%s", yytext);return T_DOT; }
\/                           { printf("%s", yytext);return T_DIV; }
else                         { printf("%s", yytext);return T_ELSE; }
==                           { printf("%s", yytext);return T_EQ; }
extends                      { printf("%s", yytext);return T_EXTENDS; }
extern                       { printf("%s", yytext);return T_EXTERN; }
false                        { printf("%s", yytext);return T_FALSE; }
for                          { printf("%s", yytext);return T_FOR; }
\>=                          { printf("%s", yytext);return T_GEQ; }
\>                           { printf("%s", yytext);return T_GT; }
if                           { printf("%s", yytext);return T_IF; }
(0x[0-9a-fA-F]+)|([0-9]+)    { printf("%s", yytext);yylval.number = get_intconstant(yytext); return T_INTCONSTANT; }
int                          { printf("%s", yytext);return T_INTTYPE; }
\{                           { printf("%s", yytext);return T_LCB; }
\<<                          { printf("%s", yytext);return T_LEFTSHIFT; }
\<=                          { printf("%s", yytext);return T_LEQ; }
\[                           { printf("%s", yytext);return T_LSB; }
\<                           { printf("%s", yytext);return T_LT; }
\(                           { printf("%s", yytext);return T_LPAREN; }
-                            { printf("%s", yytext);return T_MINUS; }
\%                           { printf("%s", yytext);return T_MOD; }
\*                           { printf("%s", yytext);return T_MULT; }
\!=                          { printf("%s", yytext);return T_NEQ; }
new                          { printf("%s", yytext);return T_NEW; }
!                            { printf("%s", yytext);return T_NOT; }
null                         { printf("%s", yytext);return T_NULL; }
\|\|                         { printf("%s", yytext);return T_OR; }
\}                           { printf("%s", yytext);return T_RCB; }
return                       { printf("%s", yytext);return T_RETURN; }
\>>                          { printf("%s", yytext);return T_RIGHTSHIFT; }
\+                           { printf("%s", yytext);return T_PLUS; }
\)                           { printf("%s", yytext);return T_RPAREN; }
\]                           { printf("%s", yytext);return T_RSB; }
\;                           { printf("%s", yytext);return T_SEMICOLON; }
\"([^\n\"\\]*{stresc}?)*\"   { printf("%s", yytext);yylval.sval = process_string(yytext); return T_STRINGCONSTANT; }
string                       { printf("%s", yytext);return T_STRINGTYPE; }
true                         { printf("%s", yytext);return T_TRUE; }
void                         { printf("%s", yytext);return T_VOID; }
while                        { printf("%s", yytext);return T_WHILE; }
[a-zA-Z\_][a-zA-Z\_0-9]*    { printf("%s", yytext);yylval.sval = new string(yytext); return T_ID; } // note that identifier pattern must be after all keywords
[\t\r\n\a\v\b ]+             { process_ws(); } /* ignore whitespace */
.                            { cerr << "Error: unexpected character in input" << endl; return -1; }

%%


int yyerror(const char *s) {
  cerr << lineno << ": " << s << " at " << yytext << endl;
  return 1;
}

