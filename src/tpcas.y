%{
#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
int yyerror(const char *s);
int yylex(void);
extern int lineno;
Node* root;
%}

%union {
    Node *node;
    char ident[64];
    int num;
}

%type <node> Prog DeclVars Declarateurs
DeclFoncts DeclFonct EnTeteFonct Parametres
ListTypVar Corps SuiteInstr Instr 
Exp TB FB M E T F LValue Arguments ListExp 

%token <ident>TYPE;
%token <ident>EQ;
%token <ident>ORDER;
%token <ident>DIVSTAR;
%token <ident>ADDSUB;
%token <ident>OR;
%token <ident>AND;
%token <num>NUM;
%token <ident>CHARACTER;
%token <ident>ELSE;
%token <ident>IDENT;
%token <ident>VOID;
%token <ident>WHILE;
%token <ident>RETURN;
%token <ident>IF;
%expect 1 

%%
Prog:  DeclVars DeclFoncts
    {
        root = makeNode(Prog_e);
        addChild(root, $1);
        addSibling(child1, $2);
    }

DeclVars:
       DeclVars TYPE Declarateurs ';'
    |
    ;
Declarateurs:
       Declarateurs ',' IDENT
    |  Declarateurs ',' DeclArray
    |  DeclArray
    |  IDENT
    ;
DeclArray:
        IDENT '[' NUM ']'
    ;
DeclFoncts:
       DeclFoncts DeclFonct
    |  DeclFonct
    ;
DeclFonct:
       EnTeteFonct Corps
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'
    |  VOID IDENT '(' Parametres ')'
    ;
Parametres:
       VOID
    |  ListTypVar
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT
    |  ListTypVar ',' TYPE IDENT '[' ']'
    |  TYPE IDENT
    |  TYPE IDENT '[' ']'
    ;
Corps: '{' DeclVars SuiteInstr '}'
    ;
SuiteInstr:
       SuiteInstr Instr {$$ = addSibling($1, $2);}
    |
    ;
Instr:
       LValue '=' Exp ';'
    |  IF '(' Exp ')' Instr
    |  IF '(' Exp ')' Instr ELSE Instr
    |  WHILE '(' Exp ')' Instr {
                    $$ = makeNode(WHILE_e);
                    addChild($$, $3);
                    addChild($$, $5);
                }
    |  IDENT '(' Arguments  ')' ';' {
                    $$ = makeNode(IDENT_e);
                    addChild($$, $3);
                }
    |  RETURN Exp ';' {
                $$ = makeNode(RETURN_e);
                addChild($$, $2);
            }
    |  RETURN ';' {
                $$ = makeNode(RETURN_e);
            }
    |  '{' SuiteInstr '}' {$$ = $2;}
    |  ';' {$$ = NULL;}
    ;
Exp :  Exp OR TB {
        $$ = makeNode(OR_e)
        addChild($$, $1); 
        addChild($$, $2);
    }
    |  TB {$$ = $1;}
    ;
TB  :  TB AND FB {
                $$ = makeNode(AND_e);
                addChild($$, $1);
                addChild($$, $2);
            }
    |  FB {$$ = $1;}
    ;
FB  :  FB EQ M {
                $$ = makeNode(EQ_e);
                addChild($$, $1);
                addChild($$, $2);
            }
    |  M {$$ = $1;}
    ;
M   :  M ORDER E {
                $$ = makeNode(ORDER_e);
                addChild($$, $1);
                addChild($$, $2);
            }
    |  E {$$ = $1;}
    ;
E   :  E ADDSUB T {
                $$ = makeNode(ADDSUB_e);
                addChild($$, $1);
                addChild($$, $2);
            }
    |  T {$$ = $1;}
    ;    
T   :  T DIVSTAR F {
                $$ = makeNode(DIVSTAR_e);
                addChild($$, $1);
                addChild($$, $2);
            }
    |  F {$$ = $1;}
    ;
F   :  ADDSUB F {
                $$ = makeNode(ADDSUB_UN_e);
                addChild($$, $2);
            }
    |  '!' F {
                $$ = makeNode(Negatif_e);
                addChild($$, $2);
            }
    |  '(' Exp ')' { $$ = $2;}
    |  NUM {$$ = $1;}
    |  CHARACTER {$$ = $1;}
    |  LValue {$$ = $1;}
    |  IDENT '(' Arguments ')' {
                    $$ = makeNode(IDENT_e);
                    addChild($$, $3);
                }
    ;
LValue:
       IDENT {$$ = $1;}
    |  IDENT '[' Exp ']' {
                        $$ = makeNode(IDENT_e);
                        addChild($$, $2);
                    }
    ;
Arguments:
       ListExp {$$ = $1;}
    | {$$ = NULL;}
    ;
ListExp:
       ListExp ',' Exp {$$ = addSibling($1, $3);}
    |  Exp {$$ = $1;}
    ;
%%

int main(){
    int res = yyparse();
    if (res == 0) printTree(root);

    return res;
}