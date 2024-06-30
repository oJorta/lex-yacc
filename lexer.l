%{
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
%}

%option noyywrap

%%

"PRINT"              { return PRINT; }
"BLOCO"              { return BLOCO; }
"FIM"                { return FIM; }
"NUMERO"             { return NUMERO; }
"CADEIA"             { return CADEIA; }
[a-z][a-z0-9_]*      { yylval.sval = strdup(yytext); return IDENTIFICADOR; }
"_"[a-zA-Z0-9]+"_"   { yylval.sval = strdup(yytext); return ID_BLOCO; }
[0-9]+               { yylval.dval = atof(yytext); return NUMERO; }
\"[^\"]*\"           { yylval.sval = strdup(yytext + 1);
                       yylval.sval[strlen(yylval.sval) - 1] = '\0';
                       return CADEIA; }
"+"                  { return '+'; }
";"                  { return ';'; }
"="                  { return '='; }
","                  { return ','; }
[ \t\n]+             { /* ignorar espaços em branco */ }

%%
