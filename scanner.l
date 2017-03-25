/* Definition Section */

%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>

    int numL = 0;
    char buf[1000];
    int bufIndex = 0;

    char bufStr[1000];
    int bufStrIndex = 0;
%}

DIGIT    [0-9]
CHAR     [A-Za-z(\\n)(\\t)]
ID       [a-z][a-z0-9]*

%x Str

%%
\"  {
        BEGIN(Str);
        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

<Str>\" {
        /* String Ends */
        BEGIN(INITIAL);
        printf("#string:%s\n",bufStr);
        bufStr[0] = 0;  /* Clean Buffer */
        bufStrIndex = 0;

        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
}

\n  {
        numL++;
        printf("%d:%s\n",numL,buf);
        buf[0] = 0;  /* Clean Buffer */
        bufIndex = 0;
    }

<Str>\n {
        /* Error */
    }

.   {
        strcpy(&(buf[bufIndex]), yytext);
        bufIndex += yyleng;
    }

<Str>. {
        strcpy(&(bufStr[bufStrIndex]), yytext);
        bufStrIndex += yyleng;

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
