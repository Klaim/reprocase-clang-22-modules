echo "step 1"
clang++-20 -std=c++26 -D__cpp_modules=201907L -finput-charset=UTF-8 -w -x c++-module -MQ ^ -MD -E -frewrite-includes -MF - -o ./output/mymodule.pcm.ii ./mymodule.mxx

echo "step 2"
clang++-20 -std=c++26 -D__cpp_modules=201907L -finput-charset=UTF-8 -E -x c++-module ./output/mymodule.pcm.ii

echo "step 3"
clang++-20 -std=c++26 -D__cpp_modules=201907L -Wno-unqualified-std-cast-call -fdiagnostics-color -finput-charset=UTF-8 -Xclang -fmodules-embed-all-files -fmodule-output=./output/mymodule.pcm -o ./output/mymodule.pcm.o -c -x c++-module ./output/mymodule.pcm.ii
