# Summary

`clang-22` outputs an error when compiling a pre-processed c++ modules file starting with `# 1 "<built-in>"`.

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

Reproducer:

With any module file (also works with just `std` module file):
```c++
// module.mxx
export module mymodule;



export namespace mymodule
{
    void func() {  }
}
```