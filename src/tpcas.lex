%{
#include "tree.h"
#include "tpcas.tab.h"
#include <string.h>
int yyerror(char *errormsg);
int lineno = 1;
int charno = 0;
%}
%x commentaire
%option nounput
%option noinput

%%

\/\* {BEGIN commentaire;}
<commentaire>\*\/ {BEGIN INITIAL;}
<commentaire>.|\n ;
\/\/.*\n ;

(int)|(char) {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return TYPE;
    }

if {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return IF;
    }

else {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return ELSE;
    }

while {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return WHILE;
    }

void {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return VOID;
    }

return {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return RETURN;
    }

[!=]= {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return EQ;
    }

[<>]=? {strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return ORDER;
    }

[*/%] {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return DIVSTAR;
    }

[+-] {
    strcpy(yylval.ident, yytext);
    return ADDSUB;
    }

\|\| {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return OR;
    }

&& {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return AND;
    }

([1-9][0-9]*)|0 {
    yylval.num = atoi(yytext);
    charno += strlen(yytext);
    return NUM;
    }

\'\\[trn0]\' {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return CHARACTER;}

\'.\' {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return CHARACTER;}

[a-zA-Z_][a-zA-Z0-9_]* {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return IDENT;
    }

"\n" {
    lineno++;
    charno = 0;
    } 

[\t\r ] {
    charno += strlen(yytext);
    }

. {
    strcpy(yylval.ident, yytext);
    charno += strlen(yytext);
    return yytext[0];
    }

<<EOF>> {return 0;}

%%