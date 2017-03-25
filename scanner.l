/* Definition Section */

%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>

    int numL = 0;
    char buf[1000];
    int bufIndex = 0;

%}

DIGIT    [0-9]
NUM     {DIGIT}*
CHAR    \'.\'
STR     \".*\"

%%

{CHAR}  {
        
        /* Error Detect? */

        printf("#char:%c\n",yytext[1]);

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
