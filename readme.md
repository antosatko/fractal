# Fractal

A simple CLI application to draw the [Newton fractal](https://en.wikipedia.org/wiki/Newton_fractal)
and save it on the disk as a [PPM file](https://netpbm.sourceforge.net/doc/ppm.html).

## Architecture

The client side code is written in C++ and calculations use the [ISPC programming language](https://ispc.github.io/).

## Building

 - Install ISPC and verify by running `ispc --version`
 - Have C++ compiler and cmake installed
 - Run `cmake -B build -S .`, `cmake --build build`
 - If all steps succeed the executable will be located at `build/fractal`

## Running

Once built you can run the executable. For the full list of options run with `-h`.
By-default the application outputs fractal for [z^5 - 1 = 0](https://commons.wikimedia.org/wiki/File:Newtroot_1_0_0_0_0_m1.png) after 250 maximum iterations.

## Going forward

I plan to introduce multithreading with the `launch` keyword. The only issue is that
I could not figure out how to link the project with ISPC runtime library in a cross-platform way.
