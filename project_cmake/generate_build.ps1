$dir = ".\build"
if(test-path $dir){
    rm build -recurse -force
}

mkdir build
cd build
cmake -G "MinGW Makefiles" ..
mingw32-make
cd ..

