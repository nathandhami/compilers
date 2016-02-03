%%


a    { printf("T_A:%s\n", yytext);}
abb   { printf("T_B:%s\n", yytext);}
a*b+  { printf("T_C:%s\n", yytext);}
. { printf("ERROR %s\n", yytext);}
