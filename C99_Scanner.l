/* Definition Section */

%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>

    int numL = 0;
    char buf[1000];     memset(buf,0,sizeof(buf));
    int bufIndex = 0;
%}

DIGIT    [0-9]
CHAR     [A-Za-z]
ID       [a-z][a-z0-9]*

%%

/* Rule Section*/

\n  {
        numL++;
        printf("%d:%s\n",numL,buf);
        bufIndex = 0;
    }

.   {
        strcpy(buf[bufIndex], yytext);
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
