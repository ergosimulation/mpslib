Installation and compilation
============================

Download
--------

| The latest release, containing statically compiles binaries for
  Windows and Linux, can be found here:
| https://github.com/ergosimulation/mpslib/releases/latest.

The source can be downloaded from GitHub
https://github.com/ergosimulation/mpslib.

Compilation
-----------

The MPSlib codes are written in standard
`C++11 <https://www.wikiwand.com/en/C%2B%2B11>`__. MPSlib has been
developed using the GNU C++ compiler (tested on Windows, Linux and OSX),
and Visual Studio C++. Using GNU C++ the code can be compiled using

::

    git clone https://github.com/ergosimulation/mpslib.git MPSlib
    cd MPSlib
    make


LINUX (Ubuntu Linux (>16.04))
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Prerequisites: g++, which can be installed using

::

    sudo apt-get install build-essential

Compiler flags:

::

    CPPFLAGS = -static -O3 -std=c++11 -Wl,--no-as-needed

OSX (XCODE+GCC)
^^^^^^^^^^^^^^^

Prerequisites: Xcode, g++

The '-static' option is not available using XCode/OSX, so the following
compiler flags are suggested:

::

    CPPFLAGS = -O3

Windows: (mingw-w64)
^^^^^^^^^^^^^^^^^^^^

MPSlib has been tested using MinGW, specifically mingw-w64
([http://mingw-w64.org/doku.php]), which can be obtained in several
ways. (Note that not all builds of MinGW works!)

One (recommended) approach is to make use of MSYS2. Follow the guide at
[http://msys2.github.io/] to install MSYS2, and then install the
mingw\_w64 toolchain using:

::

        pacman -S mingw-w64-x86_64-gcc
        pacman -S make

Then run "MSYS2 MinGW 64-bit" and/or "MSYS2 MinGW 64-bit" (should present in the windows start menu), and run the 'make' command in the mpslib folder:

::

  cd /mnt/c/Users/john/mpslib
  make


