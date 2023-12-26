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

%type <node> Prog DeclVars Declarateurs DeclArray
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
        addChild(root, $2);
    }
    ;

DeclVars:
       DeclVars TYPE Declarateurs ';' {
        Node* type = makeNode(TYPE_e);
        addChild($1, type);
        addChild(type, $3);
       }
    | {$$ = makeNode(DeclVars_e);}
    ;
Declarateurs:
       Declarateurs ',' IDENT {
        $$ = $1;
        addSibling($1, makeNode(IDENT_e));
       }
    |  Declarateurs ',' DeclArray {
        $$ = $1;
        addSibling($1, $3);
    }
    |  DeclArray {
        $$ = $1;
    }
    |  IDENT {
        $$ = makeNode(IDENT_e);
    }
    ;
DeclArray:
        IDENT '[' NUM ']' {
            $$ = makeNode(ARRAY_e);
            addChild($$, makeNode(IDENT_e));
            addChild($$, makeNode(NUM_e));
        }
    ;
DeclFoncts:
       DeclFoncts DeclFonct {
        $$ = $1;
        addSibling($$, $2);
       }
    |  DeclFonct {$$ = $1;}
    ;
DeclFonct:
       EnTeteFonct Corps {
        $$ = makeNode(DeclFoncts_e);
        addChild($$, $1);
        addChild($$, $2);
       }
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')' {
        $$ = makeNode(EnTeteFonct_e);
        addChild($$, makeNode(TYPE_e));
        addChild($$, makeNode(IDENT_e));
        addChild($$, $4);
    }
    |  VOID IDENT '(' Parametres ')' {
        $$ = makeNode(EnTeteFonct_e);
        addChild($$, makeNode(VOID_e));
        addChild($$, makeNode(IDENT_e));
        addChild($$, $4);
    }
    ;
Parametres:
       VOID {$$ = makeNode(Parametres_e);
       addChild($$, makeNode(VOID_e));}
    |  ListTypVar {
        $$ = makeNode(Parametres_e);
        addChild($$, $1);
    }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT {
        $$ = $1;
        Node* type = makeNode(TYPE_e);
        addChild(type, makeNode(IDENT_e));
        addChild($$, type);
       }
    |  ListTypVar ',' TYPE IDENT '[' ']' {
        $$ = $1;
        Node* type = makeNode(TYPE_e);
        addChild(type, makeNode(IDENT_e));
        addChild($$, type);
    }
    |  TYPE IDENT {
        $$ = makeNode(TYPE_e);
        addChild($$, makeNode(IDENT_e));
    }
    |  TYPE IDENT '[' ']' {
        $$ = makeNode(TYPE_e);
        addChild($$, makeNode(IDENT_e));
    }
    ;
Corps: '{' DeclVars SuiteInstr '}' {
        $$ = makeNode(Corps_e);
        addChild($$, $2);
        addChild($$, $3);
    }
    ;
SuiteInstr:
       SuiteInstr Instr {
        if ($1 == NULL){
            $$ = $2;
        }
        else {
            $$ = $1;
            addSibling($$, $2);
        }
       }
    | {$$ = NULL;}
    ;
Instr:
       LValue '=' Exp ';' {
        $$ = makeNode(Assign_e);
        addChild($$, $1);
        addChild($$, $3);
       }
    |  IF '(' Exp ')' Instr {
        $$ = makeNode(IF_e);
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IF '(' Exp ')' Instr ELSE Instr {
        $$ = makeNode(IF_e);
        addChild($$, $3);
        addChild($$, $5);
        addChild($$, $7);
    }
    |  WHILE '(' Exp ')' Instr {
        $$ = makeNode(WHILE_e);
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IDENT '(' Arguments  ')' ';' {
        $$ = makeNode(AppelFonc_e);
        addChild($$, makeNode(IDENT_e));
        addChild($$, $3);
    }
    |  RETURN Exp ';' {
        $$ = makeNode(RETURN_e);
        addChild($$, $2);
    }
    |  RETURN ';' {$$ = makeNode(RETURN_e);}
    |  '{' SuiteInstr '}' {$$ = $2;}
    |  ';' {$$ = NULL;}
    ;
Exp :  Exp OR TB {
        $$ = makeNode(OR_e);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  TB {
        $$ = $1;
    }
    ;
TB  :  TB AND FB {
        $$ = makeNode(AND_e);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  FB {
        $$ = $1;
    }
    ;
FB  :  FB EQ M {
        $$ = makeNode(EQ_e);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  M {
        $$ = $1;
    }
    ;
M   :  M ORDER E {
        $$ = makeNode(ORDER_e);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  E {
        $$ = $1;
    }
    ;
E   :  E ADDSUB T {
        $$ = makeNode(ADDSUB_e);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  T {
        $$ = $1;
    }
    ;    
T   :  T DIVSTAR F {
        $$ = makeNode(DIVSTAR_e);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  F {
        $$ = $1;
    }
    ;
F   :  ADDSUB F {
        $$ = makeNode(ADDSUB_UN_e);
        addChild($$, $2);
    }
    |  '!' F {
        $$ = makeNode(Negatif_e);
        addChild($$, $2);
    }
    |  '(' Exp ')' {
        $$ = $2;
    }
    |  NUM {$$ = makeNode(NUM_e);}
    |  CHARACTER {$$ = makeNode(CHARACTER_e);}
    |  LValue {$$ = $1;}
    |  IDENT '(' Arguments ')' {
        $$ = makeNode(AppelFonc_e);
        addChild($$, makeNode(IDENT_e));
        addChild($$, $3);
    } 
    ;
LValue:
       IDENT {$$ = makeNode(IDENT_e);}
    |  IDENT '[' Exp ']' {
        $$ = makeNode(IDENT_e);
        addChild($$, $3);
    } 
    ;
Arguments:
       ListExp {
        $$ = makeNode(Arguments_e);
        addChild($$, $1);
       }
    | {$$ = NULL;}
    ;
ListExp:
       ListExp ',' Exp {
        $$ = $1;
        addSibling($$, $3);
       }
    |  Exp {
        $$ = $1;
    }
    ;
%%

int yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    return 1;
}

int main(){
    int res = yyparse();
    if (res == 0) printTree(root);

    return res;
}