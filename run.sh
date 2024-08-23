cmake -S . -B 
make 
./compiler $1 $2
rm -rf cmake_install.cmake CMakeCache.txt
make clean
rm -rf CMakeFiles