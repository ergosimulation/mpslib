Installation and compilation
============================

Download
--------

| The latest release, containing statically compiles binaries for
  windows and Linux, can be found here:
| https://github.com/ergosimulation/mpslib/releases/latest.

The source can be downloaded from github
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
    sh ./configure.sh
    make

Platform specific compilation options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The line ``sh ./configure.sh`` test for a the platform used (OSX, Linux,
Windows) and stes the C++ compilation flags accordingly (``CPPFLAGS``).

::

    sh ./configure.sh
    make

The ``configure.sh`` script requires 'sed' and 'uname'. If these are not
available the only difference for different architectures should be
related to static linking, which is not available on GCC/OSX. This can
be manually adjusted in the CPPFLAGS variable in the Makefile.

LINUX (Ubuntu Linux 16.04)
^^^^^^^^^^^^^^^^^^^^^^^^^^

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
([http://mingw-w64.org/doku.php]), which can be obtained in a number of
ways. (Note that not all builds of MinGW works!)

One (recommended) approach is to make use of MSYS2. Follow the guide at
[http://msys2.github.io/] to install MSYS2, and then install the
mingw\_w64 toolchain using:

::

        pacman -S mingw-w64-x86_64-gcc
        pacman -S make

Compiler flags:

::

    CPPFLAGS = -static -O3
