%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include "struct.h"

	void yyerror(char *s);

	extern int yylineno; 
%}

%union {
	char *type;
	char *ident;
	char *value;
	tree_t *tree;
	symbole_t *symbole;
}

%token <ident> IDENTIFICATEUR
%token <value> CONSTANTE 
%token VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL

%type <type> type

%type <tree> programme

%type <tree> liste_fonctions
%type <tree> fonction

%type <symbole> liste_declarations
%type <symbole> declaration
%type <symbole> liste_declarateurs
%type <symbole> liste_declarateurs_creator
%type <symbole> declarateur
%type <symbole> declarateur_tableaux

%type <tree> liste_parms
%type <tree> liste_parms_creator
%type <tree> parm

%type <tree> liste_instructions
%type <tree> instruction

%type <tree> iteration
%type <tree> selection
%type <tree> saut
%type <tree> affectation
%type <tree> bloc
%type <tree> appel

%type <tree> variable
%type <tree> tableau

%type <tree> liste_expressions
%type <tree> liste_expressions_creator
%type <tree> expression

%type <tree> condition
%type <tree> binary_rel
%type <tree> binary_comp

%start programme


%%

programme	:	
		liste_declarations liste_fonctions
		{
			fprintf(stdout, "programme\n");
			int *count;
			*count = 0;
			type_t node_type = NONE;
			$$ = init_tree("programme", $2, node_type);
			dot_gen($$, count);		
			//print_tree($$);
		}
;
liste_declarations	:
		liste_declarations declaration
		{
			$$ = $1;
			insert_symbole($1, $2);

		}
	|
		{
			$$ = create_head(".");
		}
;
liste_fonctions	:	
		liste_fonctions fonction 
		{
			$$ = $1;
			insert_node($1, $2);
		}
	|	fonction 
		{
			$$ = $1;
		}
;
declaration	:	
		type liste_declarateurs ';'
		{
			add_type_on_list($2, $1);
			$$ = $2;
		}
		
;
liste_declarateurs :	
		liste_declarateurs_creator
		{
			$$ = $1;
		}
	|	
		{
			$$ = NULL;
		}
		
;
liste_declarateurs_creator :
		liste_declarateurs_creator ',' declarateur 
		{
			$$ = $3;
			$$->suivant = $1;
		}
	|	declarateur
		{
			$$ = $1;
		}
;
declarateur	:	
		IDENTIFICATEUR 
		{
			$$ = insert($1);
			fprintf(stdout, "déclarateur inséré\n");
		}
		
	|	declarateur_tableaux
;
declarateur_tableaux :	
		IDENTIFICATEUR 
		
	|	declarateur_tableaux '[' CONSTANTE ']'		
;
fonction :	
		type IDENTIFICATEUR '(' liste_parms ')' bloc 
		{
			fprintf(stdout, "fonction\n");
			symbole_t *temp = research($2);
			if (temp == NULL) {
				temp = insert($2);
				add_type(temp, $1);
				type_t node_type = FONCTION;
				char *name;
				name = (char *)malloc((strlen($1 + 1) + strlen($2 + 1) + strlen("," +1)) * sizeof(char));
				strcpy(name, strcat($2, ","));
				strcpy(name, strcat(name, $1));
				$$ = init_tree(name, $6, node_type);
			} else {
				throw_error("id déjà utilisé", yylineno);
			}
		}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
		{
			fprintf(stdout, "fonction extern\n");
			symbole_t *temp = research($3);
			if (temp == NULL) {
				temp = insert($3);
				add_type(temp, $2);
				type_t node_type = EXT;
				$$ = init_tree("extern", init_tree($2, NULL, node_type), node_type);
				$$->fils->next_to = init_tree($3, NULL, node_type);
			} else {
				throw_error("id déjà utilisé", yylineno);
			}
			
		}
;
type	:
		INT 
		{
			$$ = "int";
		}
	|	VOID 
		{
			$$ = "void";
		}
;
liste_parms	:	
		liste_parms_creator 
		{ 
			$$ = $1;
		}
	| 	
		{
			$$ = NULL;
		}
;
liste_parms_creator :
		liste_parms_creator ',' parm 
		{
			$$ = $3; 
			$$->next_to = $1;
		}
	|	parm 
		{
			$$ = $1;
		}
;
parm	:	
		INT IDENTIFICATEUR 
		{
			type_t node_type = NONE;
			$$ = init_tree("int", init_tree($2, NULL, node_type), node_type);
		}
;
liste_instructions :	
		liste_instructions instruction
		{
			$$ = $1;
			insert_node($1, $2);			
		}
	|	
		{
			type_t node_type = HEAD;
			$$ = init_tree(".", NULL, node_type);
		}
;

instruction	:	
		iteration 
		{ 
			$$ = $1; 
		}
	|	selection
		{ 
			$$ = $1; 
		}
	|	saut 
		{ 
			$$ = $1; 
		}
	|	affectation ';' 
		{ 
			$$ = $1; 
		}
	|	bloc 
		{ 
			$$ = $1; 
		}
	|	appel 
		{ 
			$$ = $1; 
		}
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
		{
			type_t node_type = NONE;
			$$ = init_tree("for", $3, node_type);
			$$->fils->next_to = $5;
			$$->fils->next_to->next_to = $7;
			$$->fils->next_to->next_to->next_to = $9;
		}
	|	WHILE '(' condition ')' instruction
		{
			type_t node_type = NONE;
			$$ = init_tree("while", $3, node_type);
			$$->fils->next_to = $5;
		}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
		{
			type_t node_type = COND;
			type_t then_type = NONE;
			$$ = init_tree("if", $3, node_type);
			$$->fils->next_to = init_tree("then", $5, then_type);
		}
	|	IF '(' condition ')' instruction ELSE instruction
		{
			type_t node_type = COND;
			type_t then_type = NONE;
			type_t else_type = NONE;
			$$ = init_tree("if", $3, node_type);
			$$->fils->next_to = init_tree("then", $5, then_type);
			$$->fils->next_to->next_to = init_tree("else", $7, else_type);
		}
	|	SWITCH '(' expression ')' liste_instructions
		{
			type_t node_type = NONE;
			$$ = init_tree("switch", $3, node_type);
			$$->fils->next_to = $5;
		}
	|	CASE CONSTANTE ':' liste_instructions selection
		{
			type_t node_type = NONE;
			$$ = init_tree("case", init_tree($2, NULL, node_type), node_type);
			$$->fils->next_to = $4;
			$$->next_to = $5;
		}
	|	DEFAULT ':' instruction
		{
			type_t node_type = NONE;
			$$ = init_tree("default", $3, node_type);
		}
;
saut	:	
		BREAK ';'
		{
			type_t node_type = BRK;
			$$ = init_tree("break", NULL, node_type);
		}
	|	RETURN ';'
		{
			type_t node_type = RET;
			$$ = init_tree("return", NULL, node_type);
		}
	|	RETURN expression ';'
		{
			type_t node_type = RET;
			$$ = init_tree("return", $2, node_type);
		}
;
affectation	:	
		variable '=' expression 
		{
			type_t node_type = NONE;
			$$ = init_tree(":=", $1, node_type);
			$$->fils->next_to = $3;
		}
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
		{
			$$ = $3;
		}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
		{
			fprintf(stdout, "appel\n");
			symbole_t *temp = research($1);
			if (temp == NULL) {
				throw_error("id non déclaré", yylineno);
			} else {
				type_t node_type = APPEL;
				$$ = init_tree($1, $3, node_type);
			}
		}
;
variable	:	
		IDENTIFICATEUR 
		{
			fprintf(stdout, "variable\n");
			symbole_t *temp = research($1);
			if (temp == NULL) {
				throw_error("id non déclaré", yylineno);
			} else {
				type_t node_type = NONE;
				$$ = init_tree($1, NULL, node_type);
			}
		}
	|	tableau 
		{
			type_t node_type = NONE;
			$$ = init_tree("TAB", $1, node_type);
		}
;
tableau :
		IDENTIFICATEUR
		{
			type_t node_type = NONE;
			$$ = init_tree($1, NULL, node_type);
		}
	| 	tableau '[' expression ']'
		{
			insert_node($1, $3);
			$$ = $1;
		}
;
liste_expressions	:	
		liste_expressions_creator
		{
			$$ = $1;
		}
	|	
		{
			$$ = NULL;
		}
;
liste_expressions_creator :
		liste_expressions_creator ',' expression
		{
			$$ = $3;
			$$->next_to = $1;
		}
	| expression
		{
			$$ = $1;
		}
;
expression	:	
		'(' expression ')'
		{
			$$ = $2;
		}
	| 	expression PLUS expression 
		{
			type_t node_type = NONE;
			$$ = init_tree("+", $1, node_type);
			$$->fils->next_to = $3;
		}
	| 	expression MOINS expression
		{
			type_t node_type = NONE;
			$$ = init_tree("-", $1, node_type);
			$$->fils->next_to = $3;
		} 
	| 	expression DIV expression 
		{
			type_t node_type = NONE;
			$$ = init_tree("/", $1, node_type);
			$$->fils->next_to = $3;
		}
	| 	expression MUL expression 
		{
			type_t node_type = NONE;
			$$ = init_tree("*", $1, node_type);
			$$->fils->next_to = $3;
		}
	| 	expression RSHIFT expression 
		{
			type_t node_type = NONE;
			$$ = init_tree(">>", $1, node_type);
			$$->fils->next_to = $3;
		}
	| 	expression LSHIFT expression 
		{
			type_t node_type = NONE;
			$$ = init_tree("<<", $1, node_type);
			$$->fils->next_to = $3;
		}
	| 	expression BAND expression 
		{
			type_t node_type = NONE;
			$$ = init_tree("&", $1, node_type);
			$$->fils->next_to = $3;
		}
	| 	expression BOR expression
		{
			type_t node_type = NONE;
			$$ = init_tree("|", $1, node_type);
			$$->fils->next_to = $3;
		}
	|	MOINS expression
		{
			type_t node_type = NONE;
			$$ = init_tree("-", $2, node_type);
		}
	|	CONSTANTE
		{
			type_t node_type = NONE;
			$$ = init_tree($1, NULL,node_type);
		}
	|	variable
		{
			$$ = $1;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')'
		{
			type_t node_type = NONE;
			$$ = init_tree($1, $3, node_type);
		}
;
condition	:	
		NOT '(' condition ')'
		{
			type_t node_type = NONE;
			$$ = init_tree("!", $3, node_type);
		}
	|	condition binary_rel condition %prec REL
		{
			type_t node_type = NONE;
			$$ = init_tree($2->node_name, $1, node_type);
			$$->fils->next_to = $3;
		}
	|	'(' condition ')'
		{
			$$ = $2;
		}
	|	expression binary_comp expression
		{
			type_t node_type = NONE;
			$$ = init_tree($2->node_name, $1, node_type);
			$$->fils->next_to = $3;
		}
;
binary_op	:	
		PLUS
	|   MOINS
	|	MUL
	|	DIV
	|   LSHIFT
	|   RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:	
		LAND 
		{
			type_t node_type = NONE;
			$$ = init_tree("&&", NULL, node_type);
		}
	|	LOR
		{
			type_t node_type = NONE;
			$$ = init_tree("||", NULL, node_type);

		}
;
binary_comp	:	
		LT
		{
			type_t node_type = NONE;
			$$ = init_tree("<", NULL, node_type);
		}
	|	GT
		{
			type_t node_type = NONE;
			$$ = init_tree(">", NULL, node_type);
		}
	|	GEQ
		{
			type_t node_type = NONE;
			$$ = init_tree(">=", NULL, node_type);
		}
	|	LEQ
		{
			type_t node_type = NONE;
			$$ = init_tree("<=", NULL, node_type);
		}
	|	EQ
		{
			type_t node_type = NONE;
			$$ = init_tree("==", NULL, node_type);
		}
	|	NEQ
		{
			type_t node_type = NONE;
			$$ = init_tree("!=", NULL, node_type);
		}
;

%%

void yyerror(char *s)
{
	fprintf(stderr, "le code a produit une erreur : %s\n", s);
	exit(1);
}

int main()
{
	table_reset();
	while (yyparse());
	return 0;
}