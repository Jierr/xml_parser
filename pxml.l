%{
#include "parser.hpp"
#include <string>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

typedef struct tag_stack_elem
{ 
	char* name;
	struct tag_stack_elem* prev;
} tag_stack_elem_t;

typedef struct tag_stack
{
	int count;
	tag_stack_elem_t* top;
} tag_stack_t;

typedef struct xml_ctx {
	string curr_str;
	int line;
	tag_stack_t stack;
} xml_ctx_t;

extern "C" xml_ctx_t xctx;
%}

%%

"<?" {return PROCESSING_START;}
"?>" {return PROCESSING_END;}
"<!--" {return COMMENT_START;}
"-->" {return COMMENT_END;}
"</" {return NORMAL_END_START;}
"/>" {return EMPTY_END;}
"<" {return NORMAL_START;}
">" {return NORMAL_END;}
[a-zA-Z] {yylval.cval=yytext[0]; return LETTER;}
[0-9] {yylval.cval=yytext[0]; return DIGIT;}
"=" {yylval.cval=yytext[0]; return EQ;}
[ \t\n] {yylval.cval=yytext[0]; if(yylval.cval == '\n') xctx.line++; return WHITE;}
\" {yylval.cval=yytext[0]; return PARANTH;}
. {yylval.cval=yytext[0]; return OTHER;}


%%