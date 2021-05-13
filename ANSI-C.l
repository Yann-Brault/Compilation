D                       [0-9] 
L                       [a-zA-Z_] 
MULTI_COMM              [/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]

%{
#include <stdlib.h>
#include <stdio.h>
#include "struct.h"
#include "y.tab.h"
%}

%option yylineno

%%

"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"else"                  { return ELSE; }
"extern"                { return EXTERN; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"switch"                { return SWITCH; }
"void"                  { return VOID; }
"while"                 { return WHILE; }


"//".*                  {;}
{MULTI_COMM}            {;}
{L}({L}|{D})*           {  
                            yylval.ident = strdup(yytext);
                            return IDENTIFICATEUR; 
                        } 

{D}+                    { 
                            yylval.value = strdup(yytext);
                            return CONSTANTE; 
                        } 

">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT;}
"&&"                    { return LAND; }
"&"                     { return BAND; }
"||"                    { return LOR; }
"|"                     { return BOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"<"                     { return LT; }
">"                     { return GT; }
"+"                     { return PLUS; }
"-"                     { return MOINS; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"("                     { return '('; }
")"                     { return ')'; }
"{"                     { return '{'; }
"}"                     { return '}'; }
"["                     { return '['; }                   
"]"                     { return ']'; }   
";"                     { return ';'; }
","                     { return ','; }
"="                     { return '='; }
":"                     { return ':'; }

[ \t\v\n\f]             {}
.                       {
                            fprintf(stderr, "erreur lexicale ligne %d : %s.\n", yylineno, yytext);
                            exit(1);
                        }
%%

int main()
{
	while (yyparse());
	return 0;
}