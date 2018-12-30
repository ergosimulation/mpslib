#!/bin/sh
ARCH=`uname -s`
echo "Acrhitecture: $ARCH"
if [ "$ARCH" = "Darwin" ]; then
    # NO STATIC BUILDING ON OSX
    echo "Static building not allowed on OSX, using dynamic linking instead"
    # CPPFLAGS = "CPPFLAGS = -g -O3 -std=c++11 -Wl,--no-as-needed"
    CPPFLAGS="CPPFLAGS = -O3 -std=c++11 "

    # update line 5 in Makefile with proper compiler flags
    sed -i "" "5s/.*/$CPPFLAGS/" Makefile
else
    # USE STATIC BUILDING
    echo "STATIC BUILDING"
    # Next two lines should fix threading problem on ubuntu
    # CPPFLAGS="CPPFLAGS = -g -static -O3 -std=c++11 -Wl,--no-as-needed"
    CPPFLAGS="CPPFLAGS = -static -O3 -std=c++11 -Wl,--no-as-needed"
    # CPPFLAGS = -g -static -O3 -std=c++11 -Wl,--no-as-needed 
    # CPPFLAGS="CPPFLAGS = static -O3 -std=c++11"
    # CPPFLAGS="CPPFLAGS = -O3 -std=c++11"

    # update line 5 in Makefile with proper compiler flags
    sed -i "5s/.*/$CPPFLAGS/" Makefile
fi
# echo $CPPFLAGS

