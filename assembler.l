%option noyywrap

%{
#include "assembler.tab.h"
extern YYSTYPE yylval;
%}

%%
0x[0-9a-fA-F]+      yylval.l = strtol(yytext, NULL, 16); return IMMEDIATE;
x[0-9]+             yylval.l = strtol(yytext + 1, NULL, 10); return REGISTER;
0b[0-1]+            yylval.l = strtol(yytext, NULL, 2); return IMMEDIATE;
0[0-7]+             yylval.l = strtol(yytext, NULL, 8); return IMMEDIATE;
[0-9]+              yylval.l = strtol(yytext, NULL, 10); return IMMEDIATE;
\r?\n               return NEWLINE;
\(                  return LEFT_PAREN;
\)                  return RIGHT_PAREN;
,                   return COMMA;
-                   return MINUS;
[ \t]+              ;
add                 return ADD;
sub                 return SUB;
addi                return ADDI;
lw                  return LW;
sw                  return SW;
beq                 return BEQ;
j                   return J;
auipc               return AUIPC;
%%
