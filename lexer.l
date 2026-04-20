%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%
"MOV"       { return MOV; }
"ADD"       { return ADD; }
"SUB"       { return SUB; }
"LOOP"      { return LOOP; }
"JMP"       { return JMP; }

";".*       ;   // ignore comments

"R"[0-9]    { yylval.num = yytext[1] - '0'; return REG; }
[0-9]+      { yylval.num = atoi(yytext); return NUM; }

[a-zA-Z_][a-zA-Z0-9_]*   { strcpy(yylval.str, yytext); return LABEL; }

":"         { return COLON; }
","         { return COMMA; }

\n          { return NEWLINE; }   
[ \t]+      ;

.           { printf("Invalid: %s\n", yytext); }
%%

int yywrap() { return 1; }