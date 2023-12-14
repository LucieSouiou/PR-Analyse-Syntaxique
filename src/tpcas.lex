%{
#include "tpcas.tab.h"
int yyerror(char *errormsg);
%}
%option nounput
%option noinput

%%
(int)|(char) {return TYPE;}
(==)|(!=) {return EQ;}
[<>]=? {return ORDER;}
[*/%] {return DIVSTAR;}
[+-] {return ADDSUB;}
\|\| {return OR;}
&& {return AND;}
[0-9] {return NUM;}
[a-zA-Z] {return CHARACTER;}
\; ;
. ;

%%

int main(void){
    yyparse();
    return 0;
}

int yywrap(void)
{
    return 0;
}

int yyerror(char *errormsg)
{
    fprintf(stderr, "%s\n", errormsg);
    exit(1);
}