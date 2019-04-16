# CC65 nes makefile example

The purpose of this repository is to share an example of a makefile with the following features:

- find automatically files so you don't need to update the `makefile` on every new one added
- include content (file or binary) in your `C` or `ASM` files without the need to write the relative path
- defines `deps` so only modified files will be updated
- compiled files are placed in a `build` folder so your sources doesn't get mixed up with the resulting object files
- compile the C runtine to the installed version of cc65 to avoid compatibilties issue

 
## Getting started

The example makefile comes with a basic sample project that will allow you to experiment how it work and allow you to further understand how to use it in your own project.  

You will need a proper environment to run it (WSL, mingw, linux, macOS etc).

After retrieving a copy of this repository, a few settings will be required:

- either update the sh files inside the `scripts` folder to point to the proper emulator or 
  - update it directly inside the makefile 
- update the path of the CC65 tools (cc65, ca65 etc) if they are not in your path

### How to use

Once properly set, the only thing to know is which commands are available and what they do.

To just compile the project:

```
make
```

To compile only the runtime:

```
make runtime
```

To run with the default emulator that you set:

```
make run
```

To run the first debug emulator that you set:

```
make debug
```

To run the second debug emulator:

```
make debug2
```

The third one:

```
make debug3
```

To clean the `build` folder, `dbg` and `nes` file:
```
make clean
```

To clean the `runtime` only:
```
make clean-runtime
```

To clean both the `build` folder and `runtime`
```
make clean-both
```

## Basic folder structure

The makefile follow a few rules to allow. As long that you put the files in the proper folder, it will find them automatically.

The structure is as follow:

```
top
├── config -> cc65 cfg file 
├── data -> put any data (music, chr etc here)
├── libs -> put any files that needs to be included in other C/asm files like famitone, neslib etc
├── runtime -> C runtime source (2.17)
├── scripts -> shell scripts to start emulators
└── src -> this is were you put your source files
```

Note: 
- there is a limitation of 2 level depth for sub-directories 
- data can be put in src folder but not the opposite
- the cfg file is actually hardcoded in the makefile


## About the sample

The sample is based on the files that were included in the [neslib library by Shiru](https://shiru.untergrund.net/files/src/cc65_nes_examples.zip). The only difference is that a few parts are separated in independant files compared to the original first tample.  The main goal was to test if the makefile does catch the files and understand how the C runtime work with CC65.  

It can be used to do basic testing with neslib and famitone but it may not be an appropriate sample to use for a real project ^^;;

## Note

This README is still a work-in-progress and will be updated with more information if necessary.