%{
#include "tree.h"
#include "tpcas.tab.h"
#include <string.h>
void yyerror(char *errormsg);
int lineno = 1;
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
    return TYPE;
    }

if {
    strcpy(yylval.ident, yytext);
    return IF;
    }

else {
    strcpy(yylval.ident, yytext);
    return ELSE;
    }

while {
    strcpy(yylval.ident, yytext);
    return WHILE;
    }

void {
    strcpy(yylval.ident, yytext);
    return VOID;
    }

return {
    strcpy(yylval.ident, yytext);
    return RETURN;
    }

[!=]= {
    strcpy(yylval.ident, yytext);
    return EQ;
    }

[<>]=? {strcpy(yylval.ident, yytext);
    return ORDER;
    }

[*/%] {
    strcpy(yylval.ident, yytext);
    return DIVSTAR;
    }

[+-] {strcpy(yylval.ident, yytext);
    return ADDSUB;
    }

\|\| {
    strcpy(yylval.ident, yytext);
    return OR;
    }

&& {
    strcpy(yylval.ident, yytext);
    return AND;
    }

([1-9][0-9]*)|0 {
    yylval.num = atoi(yytext);
    return NUM;
    }

\'\\[trn0]\' {
    strcpy(yylval.ident, yytext);
    return CHARACTER;}

\'.\' {
    strcpy(yylval.ident, yytext);
    return CHARACTER;}

[(){},;!=] {return yytext[0];}

[a-zA-Z_][a-zA-Z0-9_]* {
    strcpy(yylval.ident, yytext);
    return IDENT;
    }

"\n" {lineno++;} 

. ;

<<EOF>> {return 0;}

%%

void yyerror(char *errormsg)
{
    fprintf(stderr, "%s\n", errormsg);
}

int main(void){
    return yyparse();
}