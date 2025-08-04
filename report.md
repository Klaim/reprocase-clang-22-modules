 # Summary

`clang++-22` outputs a compilation error when compiling a pre-processed c++ modules file (using `-frewrite-includes`) which generated code starts with `# 1 "<built-in>"` while `clang++-22` expects `module;`, `module ...;` or `export module ...;`.

Note: I couldnt test with `clangc++-21` yet because of  https://github.com/llvm/llvm-project/issues/151221 , will test it later.

# Context

```
$ clang++-22 --version
Ubuntu clang version 22.0.0 (++20250804082146+0cfe9f7287f7-1~exp1~20250804082205.1075)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin

$ clang++-20 --version
Ubuntu clang version 20.1.8 (++20250708082440+6fb913d3e2ec-1~exp1~20250708202457.136)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-20/bin
```

# How To Reproduce

Reproducer: https://github.com/Klaim/reprocase-clang-22-modules

Requires `clang++-22` to be available in the environment.
Clone it then run `repro.sh` for the failing version using `clang++-22`, `repro-works.sh` for the succeeding version which is the same commands but wiht `clang++-20`.

## From scratch:

1. Create a simple module file, here `module.mxx`:
```c++
export module mymodule;

export namespace mymodule
{
    void func() {  }
}
```

Then run these commands in sequence (after creating an `output/` directory):

```sh
clang++-22 -std=c++26 -D__cpp_modules=201907L -finput-charset=UTF-8 -w -x c++-module -MQ ^ -MD -E -frewrite-includes -MF - -o ./output/mymodule.pcm.ii ./mymodule.mxx

clang++-22 -std=c++26 -D__cpp_modules=201907L -finput-charset=UTF-8 -E -x c++-module ./output/mymodule.pcm.ii

clang++-22 -std=c++26 -D__cpp_modules=201907L -Wno-unqualified-std-cast-call -fdiagnostics-color -finput-charset=UTF-8 -Xclang -fmodules-embed-all-files -fmodule-output=./output/mymodule.pcm -o ./output/mymodule.pcm.o -c -x c++-module ./output/mymodule.pcm.ii

```

## Observed

With `clang++-22`:
```
$ ./repro.sh
step 1
^: mymodule.mxx
step 2
# 1 "./output/mymodule.pcm.ii"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 495 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "./output/mymodule.pcm.ii" 2
# 1 "<built-in>"
# 1 "./mymodule.mxx"
export module mymodule;


export namespace mymodule
{
    void func() { }
}
step 3
./mymodule.mxx:1:8: error: module declaration must occur at the start of the translation unit
    1 | export module mymodule;
      |        ^
./output/mymodule.pcm.ii:1:1: note: add 'module;' to the start of the file to introduce a global module fragment
    1 | # 1 "<built-in>"
      | ^
1 error generated.
```

## Expected

No error.

For example `repro-works.sh` which only changes the compiler to `clang++-20` works as expected, no error.

```
$ ./repro-works.sh
step 1
^: mymodule.mxx
step 2
# 1 "./output/mymodule.pcm.ii"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 495 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "./output/mymodule.pcm.ii" 2
# 1 "<built-in>"
# 1 "./mymodule.mxx"
export module mymodule;


export namespace mymodule
{
    void func() { }
}
step 3
```

# More Context

I initially hit this issue when attempting to build a modules-only (except some dependencies) project using `build2` which uses these build steps.
Depending on the module, if there was a `import std;` then the error would first appear for `std.cppm`.
