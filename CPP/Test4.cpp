/*
Author: Bryan Marty <bxm156@case.edu>
Generated: Tue Nov 30 13:59:26 2010
*/
#include <iostream>
#include <string>

using namespace std;

class Test4{
public:
 
  int  addTwoNumbers ( int x , int y );
 
private:
  int  subTwoNumbers ( int x , int y );
 
};
int addTwoNumbers (int x,int y ){
return x +y ;
}
int subTwoNumbers (int x,int y ){
return x -y ;
}
int main(int argc, char *argv[]){
cout << "3 + 5 is ..." << endl;
int x = addTwoNumbers (3,5);
cout << x  << endl;
cout << "\n" << endl;
}

