D                       [0-9] 
L                       [a-zA-Z_]
H                       [a-fA-F0-9] 
E                       [Ee][+-]?{D}+ 
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
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

0[xX]{H}+{IS}?          { 
                            yylval.value = strdup(yytext);
                            return CONSTANTE; 
                        }
0{D}+{IS}?              { 
                            yylval.value = strdup(yytext);
                            return CONSTANTE; 
                        } 
{D}+{IS}?               { 
                            yylval.value = strdup(yytext);
                            return CONSTANTE; 
                        } 
{D}+{E}{FS}?            { 
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
\n                    {;}
[ \t\v\f]             {;}
.                       {
                            fprintf(stderr, "erreur lexicale ligne %d : %s.\n", yylineno, yytext);
                            exit(1);
                        }
%%

