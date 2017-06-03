%{
#include <iostream>
#include <string>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "parser.hpp"  // to get the token types that we return
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

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

void init_stack(tag_stack_t* stack);
void clean_stack(tag_stack_t* stack);
tag_stack_elem_t* pop_stack(tag_stack_t* stack);
int close_valid(tag_stack_t* stack, char* name);
int push_stack(tag_stack_t* stack, char* name);
void free_stack_elem(tag_stack_elem_t* elem);

typedef struct xml_ctx {
	string curr_str;
	int line;
	tag_stack_t stack;
} xml_ctx_t;


int str_add(char** dst, char* add);

xml_ctx_t xctx;
void init_xml_ctx(xml_ctx_t* ctx);
void reset_xml_ctx(xml_ctx_t* ctx);


 

void yyerror(const char *msg);
%}


%union{
	char* str;
	char cval;
}

%token <cval> LETTER
%token <cval> DIGIT
%token <cval> EQ
%token <cval> PARANTH
%token <cval> WHITE
%token <cval> OTHER
%token COMMENT_START COMMENT_END
%token NORMAL_START NORMAL_END
%token NORMAL_END_START
%token EMPTY_END
%token PROCESSING_START PROCESSING_END

%type <str> name
%type <str> content
%type <str> value
%type <str> attribute
%type <str> normal_tag_start
%type <str> whites

%%

xml: whites processing_tag root
	| content whites processing_tag root

whites: {$$ = (char*)malloc(sizeof(char)); $$[0] = '\0';}
	| whites WHITE {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| WHITE {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	;


single_tag: whites comment_tag whites 
	| whites empty_tag whites
	| whites processing_tag whites
	;
	
root: whites normal_tag_start nodes normal_tag_end whites{
		;
	}
	| whites normal_tag_start content normal_tag_end whites{
		;
	}
	| whites normal_tag_start normal_tag_end whites{
		;
	}
	;
	
	
nodes: nodes single_tag
	| nodes root
	| single_tag
	| root 
	;

name: name LETTER {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| name DIGIT {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| name OTHER {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| LETTER {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| OTHER {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	;

content: content LETTER {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| content DIGIT {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| content EQ {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| content PARANTH {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| content WHITE {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| content OTHER {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| LETTER {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| DIGIT {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| EQ {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| PARANTH {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| WHITE {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| OTHER {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	;


attribute: attribute whites name EQ PARANTH value PARANTH whites{
		xctx.curr_str="";
		xctx.curr_str+=$1;
		xctx.curr_str+=$2;
		xctx.curr_str+=$3;
		xctx.curr_str+=$4;
		xctx.curr_str+=$5;
		xctx.curr_str+=$6;
		xctx.curr_str+=$7;
		xctx.curr_str+=$8;
		if($1)		
			free($1);
		if($2)		
			free($2);
		if($3)		
			free($3); 
		if($6)		
			free($6);
		if($8)		
			free($8);
		$1=$2=$3=$6=$8=0;
		$$ = (char*)malloc(xctx.curr_str.length()+1); 
		strcpy($$, xctx.curr_str.c_str());
	}
	| whites name EQ PARANTH value PARANTH whites{
		xctx.curr_str="";
		xctx.curr_str+=$1;
		xctx.curr_str+=$2;
		xctx.curr_str+=$3;
		xctx.curr_str+=$4;
		xctx.curr_str+=$5;
		xctx.curr_str+=$6;
		xctx.curr_str+=$7;
		if($1)		
			free($1);
		if($2)		
			free($2);
		if($5)		
			free($5); 
		if($7)		
			free($7);
		$1=$2=$5=$7=0;
		$$ = (char*)malloc(xctx.curr_str.length()+1); 
		strcpy($$, xctx.curr_str.c_str());
	}
	;
	
value: value LETTER {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| value DIGIT {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| value EQ {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| value WHITE {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| value OTHER {$$=0; char w[2]={0,}; w[0] = $2; str_add(&$$, $1); str_add(&$$, w); if($1) free($1);}
	| LETTER {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| DIGIT {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| EQ {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| WHITE {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	| OTHER {$$=0; char w[2]={0,}; w[0] = $1; str_add(&$$, w);}
	;
comment_content: comment_content LETTER
	| comment_content DIGIT
	| comment_content EQ
	| comment_content PARANTH
	| comment_content WHITE
	| comment_content OTHER
	| comment_content PROCESSING_START
	| comment_content PROCESSING_END
	| comment_content COMMENT_START
	| comment_content NORMAL_END_START
	| comment_content EMPTY_END
	| comment_content NORMAL_START
	| comment_content NORMAL_END
	| LETTER
	| DIGIT
	| EQ
	| PARANTH
	| WHITE
	| OTHER
	| PROCESSING_START
	| PROCESSING_END
	| COMMENT_START
	| NORMAL_END_START
	| EMPTY_END
	| NORMAL_START
	| NORMAL_END
	;
	
comment_tag: COMMENT_START comment_content COMMENT_END {
		cout<< "[" << xctx.line << "]	" << "Found comment tag"<< endl;
	}
	;

empty_tag: NORMAL_START name EMPTY_END {
		cout<< "[" << xctx.line << "]	" << "Found empty tag:: name = "<< $2 << endl;
		if($2)
			free($2);
		$2 = 0;
		
	}
	| NORMAL_START name attribute EMPTY_END {
			cout<< "[" << xctx.line << "]	" << "Found empty tag:: name = <" << $2 << "> attributes =" << $3 << endl;
		if($2)
			free($2);
		if($3)
			free($3);
		$2=$3=0;
			
	}
	;
	
processing_tag: PROCESSING_START content PROCESSING_END {
		cout<< "[" << xctx.line << "]	" << "Found processing tag:: "<< $2 << endl;
		if($2)
			free($2); 
		$2=0;
	}
	;
	
normal_tag_start: NORMAL_START name NORMAL_END {
		cout<< "[" << xctx.line << "]	" << "Found normal tag start:: name = <" << $2 << ">" << endl;
		push_stack(&xctx.stack, $2); 
		if($2)
			free($2); 
		$2=0;
	}
	| NORMAL_START name attribute NORMAL_END {
		cout<< "[" << xctx.line << "]	" << "Found normal tag start:: name = <" << $2 << "> attributes = " << $3 <<  endl;
		push_stack(&xctx.stack, $2); 
		if($2)
			free($2); 
		if($3)
			free($3); 
		$2=$3=0;
	}
	;
	
normal_tag_end:	NORMAL_END_START name NORMAL_END {
		if(!(close_valid(&xctx.stack, $2) == 1))
		{
			free($2); $2=0;
			yyerror("Tags not properly nested!");
		}
		cout<< "[" << xctx.line << "]	" << "Found normal tag end name = <" << $2 << ">" << endl;
		if($2)
			free($2); 
		$2=0;
	}
	;
	
%%
main(int argc, char** argv) {
	if(argc == 1)
	{
		cerr<< "Usage: " << argv[0] << " <filename>" << endl;
		return -1;
	}
	
	FILE *file = fopen(argv[1], "r");
	if (!file) {
		cerr << "Can't open "<< argv[1] << "!" << endl;
		return -1;
	}
	yyin = file;

	init_xml_ctx(&xctx);
	do {
		yyparse();
	} while (!feof(yyin));	
	reset_xml_ctx(&xctx);
	
	return 0;
}

void yyerror(const char *msg) {
	cerr << "Error<" << xctx.line << ">" << "<" << xctx.curr_str << ">"<< " " << msg << endl;
	exit(-1);
}

void init_stack(tag_stack_t* stack)
{
	stack->count = 0;
	stack->top = 0;
}

void clean_stack(tag_stack_t* stack)
{
	tag_stack_elem_t* next = 0;
	stack->count = 0;
	while(stack->top)
	{
		next = stack->top->prev;
		free(stack->top->name);
		free(stack->top);
		stack->top = next;
	}
	stack->top = 0;
}

tag_stack_elem_t* pop_stack(tag_stack_t* stack)
{
	tag_stack_elem_t* result = 0;
	if(!stack->top)
		return 0;
		
	result = stack->top;
	stack->top = stack->top->prev;
	--stack->count;
	
	return result;
}

int close_valid(tag_stack_t* stack, char* name)
{
	tag_stack_elem_t* result = 0;
	int valid = 0;
	result = pop_stack(stack);
	if(strcmp(result->name, name) == 0)
		valid = 1;
		
	free(result->name);
	free(result);
	
	return valid;	
}

int push_stack(tag_stack_t* stack, char* name)
{
	int len = 0;
	tag_stack_elem_t* elem = 0;
	
	elem = (tag_stack_elem_t*)malloc(sizeof(tag_stack_elem_t));
	++stack->count;
	elem->prev = stack->top;
	len = strlen(name);
	elem->name = (char*)malloc(sizeof(char)*(len+1));
	strcpy(elem->name, name);
	stack->top = elem;
	return stack->count;
}

void free_stack_elem(tag_stack_elem_t* elem)
{
	free(elem->name);
	free(elem);
}

void init_xml_ctx(xml_ctx_t* ctx)
{
	ctx->curr_str = "";
	ctx->line = 0;
	init_stack(&ctx->stack);
}

void reset_xml_ctx(xml_ctx_t* ctx)
{
	ctx->curr_str = "";
	ctx->line = 0;
	clean_stack(&ctx->stack);
}


int str_add(char** dst, char* add)
{
	char* result = 0;
	int alen = 0;
	int dlen = 0;
	
	if(!dst)
		return 0;
	
	if(add)
		alen = strlen(add);
		
	if(*dst)
		dlen = strlen(*dst);
		
	if(!add)
		return 0;
	
	if(alen+dlen > 0)
	{
		result = (char*)malloc((alen+dlen+1)*sizeof(char));
		if(*dst)
			strcpy(result, *dst);
		strcpy(&result[dlen], add);
		result[dlen+alen] = 0;
	}
	if(*dst)
		free(*dst);
		
	(*dst) = result;
		
	return alen + dlen;
}