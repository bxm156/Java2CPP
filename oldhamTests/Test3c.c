#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct Test3 {
char *says;
};

struct Test3 *Test3( char * _says) { 
      struct Test3 *test3 = (struct Test3*)malloc( sizeof( struct Test3));
      test3->says = _says;
      return test3;
}

int main(int argc, char *argv[])
{
  struct Test3 *test3 = Test3( "Test3 says");
  printf( "%s\n", test3->says);
  return 0;
}
