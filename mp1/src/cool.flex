/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
  if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
    YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

int comment_cnt;

extern int curr_lineno;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

%option noyywrap

/*
 * Define names for regular expressions here.
 */

%x string
%x comment

%%

(?i:class) return CLASS;
(?i:else) return ELSE;
f(?i:alse) {yylval.boolean=false;return BOOL_CONST;}
(?i:fi) return FI;
(?i:if) return IF;
(?i:in) return IN;
(?i:inherits) return INHERITS;
(?i:isvoid) return ISVOID;
(?i:let) return LET;
(?i:loop) return LOOP;
(?i:pool) return POOL;
(?i:then) return THEN;
(?i:while) return WHILE;
(?i:case) return CASE;
(?i:esac) return ESAC;
(?i:new) return NEW;
(?i:of) return OF;
(?i:not) return NOT;
t(?i:rue) {yylval.boolean=true;return BOOL_CONST;}
"<-" return ASSIGN;
"<=" return LE;
"=>" return DARROW;
"*)" {yylval.error_msg="Unmatched *)";return ERROR;}
[-.@~+*/<=:(){},;] return yytext[0];

[0-9]+ {yylval.symbol=inttable.add_string(yytext);return INT_CONST;}
[A-Z][A-Za-z0-9_]* {yylval.symbol=idtable.add_string(yytext);return TYPEID;}
[a-z][A-Za-z0-9_]* {yylval.symbol=idtable.add_string(yytext);return OBJECTID;}

[ \n\f\r\t\v] if(yytext[0]=='\n')curr_lineno++;

 /*strings*/
"\"" {BEGIN(string);yymore();}
<string>\\[^\0\n] {yymore();}
<string>\\\n {curr_lineno++;yymore();}
<string>\" {char *s=yytext+1,*d=string_buf;
                BEGIN(INITIAL);
                if(yyleng!=strlen(yytext)){
                    yylval.error_msg="String contains null character.";
                    return ERROR;
                }
                while(*(s+1)){
                    if(*s=='\\'){
                        switch(*++s){
                            case 'b':*d='\b';break;
                            case 't':*d='\t';break;
                            case 'n':*d='\n';break;
                            case 'f':*d='\f';break;
                            default:*d=*s;break;
                        }
                        s++;d++;
                    }else{
                        *d++=*s++;
                    }
                    if(d-string_buf>=MAX_STR_CONST){
                        yylval.error_msg="String constant too long";
                        return ERROR;
                    }
                }
                *d='\0';
                yylval.symbol=stringtable.add_string(string_buf);
                return STR_CONST;}
<string>\n {yylval.error_msg="Unterminated string constant";
                BEGIN(INITIAL);
                curr_lineno++;
                return ERROR;}
<string><<EOF>> {YY_NEW_FILE;
				BEGIN(INITIAL);
                yylval.error_msg="EOF in string constant";
                return ERROR;}
<string>. {yymore();}

 /*comments*/
--.*
"(*" {comment_cnt=1;BEGIN(comment);}
<comment>"(*" {comment_cnt++;}
<comment>"*)" {comment_cnt--;if(comment_cnt==0)BEGIN(INITIAL);}
<comment>\n {curr_lineno++;}
<comment><<EOF>> {BEGIN(INITIAL);
                yylval.error_msg="EOF in comment";
                return ERROR;}
<comment>.

. {yylval.error_msg=yytext;return ERROR;}

 /*
  * Define regular expressions for the tokens of COOL here. Make sure, you
  * handle correctly special cases, like:
  *   - Nested comments
  *   - String constants: They use C like systax and can contain escape
  *     sequences. Escape sequence \c is accepted for all characters c. Except
  *     for \n \t \b \f, the result is c.
  *   - Keywords: They are case-insensitive except for the values true and
  *     false, which must begin with a lower-case letter.
  *   - Multiple-character operators (like <-): The scanner should produce a
  *     single token for every such operator.
  *   - Line counting: You should keep the global variable curr_lineno updated
  *     with the correct line number
  */

%%
