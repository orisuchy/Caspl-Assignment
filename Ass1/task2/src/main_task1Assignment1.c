#include <stdio.h>
#include <stdlib.h>

extern void assFunc(int x, int y);
char c_checkValidity(int x, int y);

int main(int argC, char **argv)
{
  int x,y, in = 32;
  char buffer[in];
  //printf ("Enter first number: ");
  fgets (buffer, in, stdin);
  x = atoi (buffer);
  //printf ("Enter second number: ");
  fgets (buffer, in, stdin);
  y = atoi (buffer);
  // printf("%d\t\n", x + y);
  assFunc(x,y);
  printf("\n");
}

char c_checkValidity(int x, int y){
    if ( x >= y)
        return 1;
    else
        return 0;
}
