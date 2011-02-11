/*
Author: Bryan Marty <bxm156@case.edu>
Generated: Tue Nov 30 13:59:26 2010
*/
#include <iostream>
#include <string>

using namespace std;

class Test3{
public:
 
 string  says;
 
 Test3 ( string  _says ){
 says = _says;
}
 
private:
};
int main(int argc, char *argv[]){
Test3 *test3 = new Test3 ("Test3 says");
cout << test3->says << endl;
return 0;
}

