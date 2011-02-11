#include <iostream> // Required for stream output (cout).
#include <string> // Required for string class.
using namespace std;

class Test3 {
  public:
    string says;
    Test3( string _says) { 
      says = _says;
    }
};

int main(int argc, char *argv[])
{
  Test3 *test3 = new Test3( "Test3 says");
  cout << test3->says << endl;
  return 0;
}
