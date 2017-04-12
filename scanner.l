    /* Definition Section */

%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>

    int numL = 1;
    char buf[1000];
    int bufIndex = 0;

    int tokenOn = 1;
    int sourceOn = 1;
%}

%x  COMMENT

DIGIT    [0-9]
DIGIT_SEQ  {DIGIT}+
FRAC    ({DIGIT_SEQ}?"."{DIGIT_SEQ})|({DIGIT_SEQ}".")
FS		(f|F|l|L)

DOUBLE  {FRAC}{FS}?

E		[Ee][+-]?{DIGIT_SEQ}
SCI     ({FRAC}|{DIGIT_SEQ}){E}{FS}?

L       (l|L|ll|LL)
U       (u|U)
IS      ({U}|{L}|{L}{U}|{U}{L})

INT     ({DIGIT}|[1-9]{DIGIT}*){IS}?


CHAR    L?'([^'\\\n]|\\(n|t))'
STR     L?\"(\\(n|t)|[^"\\\n])*\"

ID      [a-zA-Z_]+[a-zA-Z_0-9]*

PUNC    ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"
OP      "+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"&"
KEY     "void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"
STDIO    "remove"|"rename"|"tmpfile"|"tmpnam"|"fclose"|"fflush"|"fopen"|"freopen"|"setbuf"|"setvbuf"|"fprintf"|"fscanf"|"printf"|"scanf"|"sprintf"|"sscanf"|"vfprintf"|"vprintf"|"vsprintf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"|"fread"|"fwrite"|"fgetpos"|"fseek"|"fsetpos"|"ftell"|"rewind"|"clearerr"|"feof"|"ferror"|"perror"
SPACE   [ \f\t\r\v]+

SOURCE_ON   #{SPACE}?"pragma"{SPACE}"source"{SPACE}"on"{SPACE}?\n
SOURCE_OFF   #{SPACE}?"pragma"{SPACE}"source"{SPACE}"off"{SPACE}?\n
TOKEN_ON    #{SPACE}?"pragma"{SPACE}"token"{SPACE}"on"{SPACE}?\n
TOKEN_OFF   #{SPACE}?"pragma"{SPACE}"token"{SPACE}"off"{SPACE}?\n

%%

{SOURCE_ON}    {
    sourceOn = 1;

    /* Fuck \n */
    yytext[yyleng-1] = 0;   strcpy(&(buf[bufIndex]), yytext);  bufIndex += (yyleng-1);
    unput('\n');
    }

{SOURCE_OFF}   {
    sourceOn = 0;

    /* Fuck \n */
    yytext[yyleng-1] = 0;   strcpy(&(buf[bufIndex]), yytext);  bufIndex += (yyleng-1);
    unput('\n');
    }

{TOKEN_ON}      {
    tokenOn = 1;

    /* Fuck \n */
    yytext[yyleng-1] = 0;   strcpy(&(buf[bufIndex]), yytext);  bufIndex += (yyleng-1);
    unput('\n');
    }

{TOKEN_OFF}    {
    tokenOn = 0;

    /* Fuck \n */
    yytext[yyleng-1] = 0;   strcpy(&(buf[bufIndex]), yytext);  bufIndex += (yyleng-1);
    unput('\n');
    }

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

        /* Check pragma */
        if(sourceOn == 1)   printf("%d:%s\n",numL,buf);

        numL++; /* Enter newline */

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
        /* Check pragma */
        if(tokenOn == 1)    printf("#key:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{STDIO}  {
        /* Check pragma */
        if(tokenOn == 1)    printf("#key:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

0{INT}  {
    /* In order to make TA happy */
    fprintf(stderr, "Error at line %d: %s\n", numL, yytext); exit(1);
    }

{INT}    {
        /* Check pragma */
        if(tokenOn == 1)    printf("#integer:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{DOUBLE}  {
        /* Check pragma */
        if(tokenOn == 1)    printf("#double:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{SCI}    {
        /* Check pragma */
        if(tokenOn == 1)    printf("#sci:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{PUNC}   {
        /* Check pragma */
        if(tokenOn == 1)    printf("#punc:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{OP}    {
        /* Check pragma */
        if(tokenOn == 1)    printf("#op:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{CHAR}  {

        /* Error Detect? */

        /* Check pragma */
        if(tokenOn == 1)    printf("#char:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }


{STR}   {
        /* Extract String */
        char str[1000];
        if(yytext[0] == 'L')
        {
            strcpy(str,yytext+2); /* The first " is gone */
            str[yyleng-3] = 0; /* The last " is gone */
        }
        else
        {
            strcpy(str,yytext+1);
            str[yyleng-2] = 0; /* The last " is gone */
        }


        /* Error Detect? */

        /* Check pragma */
        if(tokenOn == 1)    printf("#string:%s\n",str);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

[0-9]+{ID}  {
    /* In order to make TA happy */
    fprintf(stderr, "Error at line %d: %s\n", numL, yytext); exit(1);
    }

{ID}    {
        /* Check pragma */
        if(tokenOn == 1)    printf("#id:%s\n",yytext);

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

{SPACE}   {
        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

\n  {

        /* Check pragma */
        if(sourceOn == 1)   printf("%d:%s\n",numL,buf);

        numL++; /* Enter newline */

        buf[0] = 0;  /* Clean Buffer */
        bufIndex = 0;

    }

.   {
        fprintf(stderr, "Error at line %d: %s\n", numL, yytext); exit(1);

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
