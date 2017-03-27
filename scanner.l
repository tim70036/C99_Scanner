    /* Definition Section */

%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>

    int numL = 0;
    char buf[1000];
    int bufIndex = 0;

%}

%x  COMMENT

DIGIT    [0-9]
FS			(f|F|l|L)
IS			(u|U|l|L)*
E			[Ee][+-]?{DIGIT}+

INT     {DIGIT}|[1-9]{DIGIT}*
DOUBLE  ({DIGIT}*"."{DIGIT}+)|({DIGIT}+"."{DIGIT}*)
SCI     ({INT}|{DOUBLE})({E})

PUNC    ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"
CHAR    \'.\'
STR     \"(\\.|[^"])*\"
OP      "+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"&"
ID      [a-zA-Z_]*[a-zA-Z_0-9]*
KEY     "void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"
STDIO    "remove"|"rename"|"tmpfile"|"tmpnam"|"fclose"|"fflush"|"fopen"|"freopen"|"setbuf"|"setvbuf"|"fprintf"|"fscanf"|"printf"|"scanf"|"sprintf"|"sscanf"|"vfprintf"|"vprintf"|"vsprintf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"|"fread"|"fwrite"|"fgetpos"|"fseek"|"fsetpos"|"ftell"|"rewind"|"clearerr"|"feof"|"ferror"|"perror"
SPACE   [ \f\t\r\v]+
%%
"/*"    {
        BEGIN(COMMENT);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }
<COMMENT>"*/" {
        /*  End of Comment  */
        BEGIN(INITIAL);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
}
<COMMENT>\n {
        /* Comment newline print it out */

        numL++;
        printf("%d:%s\n",numL,buf);
        buf[0] = 0;  /* Clean Buffer */
        bufIndex = 0;
    }
<COMMENT>.  {
        /* If use .*  then it will eat the ending of comment */

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

"//".*  {
        /* Single line comment , simply copy to buf, and wait for \n to handle*/
        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{KEY}   {
        printf("#key:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{STDIO} {
        printf("#key:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{INT}   {
        printf("#integer:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{DOUBLE} {
        printf("#double:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{SCI}   {
        printf("#sci:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{PUNC}  {
        printf("#punc:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{OP}    {
        printf("#op:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{CHAR}  {

        /* Error Detect? */

        printf("#char:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{STR}   {
        /* Extract String */
        char str[1000];
        strcpy(str,yytext+1); /* The first " is gone */
        str[yyleng-2] = 0; /* The last " is gone */

        /* Error Detect? */

        printf("#string:%s\n",str);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{ID}    {
        printf("#id:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{SPACE}   {
        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

\n  {
        numL++;
        printf("%d:%s\n",numL,buf);
        buf[0] = 0;  /* Clean Buffer */
        bufIndex = 0;
    }

.   {
        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }


%%

    /* C code Section */

int main(int argc, char* argv[])
{
    ++argv; --argc; /* Skip program name */
    yyin = ( argc > 0 ) ? fopen(argv[0], "r") : stdin;

    yylex();

    return 0;
}
