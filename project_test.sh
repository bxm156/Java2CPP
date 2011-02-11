make clean
make
rm -fr ./CPP
mkdir CPP
./java2cpp ./Tests/Test0.java &> ./CPP/Test0.cpp
./java2cpp ./Tests/Test1.java &> ./CPP/Test1.cpp
./java2cpp ./Tests/Test2.java &> ./CPP/Test2.cpp
./java2cpp ./Tests/Test3.java &> ./CPP/Test3.cpp
./java2cpp ./Tests/Test4.java &> ./CPP/Test4.cpp
./java2cpp ./Tests/Test5.java &> ./CPP/Test5.cpp
echo "Hi Prof. Oldham!"
echo "Tests 0-5 from the ./Tests folder have been converted to C++ and stored in the ./CPP directory."
echo "Thank you - Bryan Marty bxm156"