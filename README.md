# MPSlib: a C++ class for Multiple-Point based sequential Simulation
MPSlib provides a set of algorithms for simulation of models based on a multiple point
statistical model inferred from a training image.

The goal of developing these codes has been to produce a set of algorithms, based
on sequential simulation, for simulation of multiple point statistical models.
The code should be easy to compile and extend, and should be allowed for both
commercial and non-commercial use.

MPSlib (version 1.0) has been developed by
[I-GIS](http://www.i-gis.dk/)
and
[Solid Earth Physics, Niels Bohr Institute](http://imgp.nbi.ku.dk/).

Development has been funded by the Danish National Hightech Foundation (now: the Innovation fund) through the ERGO (Effective high-resolution Geological Modeling) project, a collaboration between
[IGIS](http://i-gis.dk/),
[GEUS](http://geus.dk/), and
[Niels Bohr Institute](http://nbi.ku.dk/).

# Download
The latest relases, containing statically compiles binaries for windows and Linux, can be found here:
[https://github.com/ergosimulation/mpslib/releases/latest](https://github.com/ergosimulation/mpslib/releases/latest).

The source can be downloaded from github
[https://github.com/ergosimulation/mpslib](https://github.com/ergosimulation/mpslib)
and compiled using

	git clone https://github.com/ergosimulation/mpslib.git MPSlib
	cd MPSlib
	make

# Documentation
Documentation is available through [https://mpslib.readthedocs.io/en/latest/](https://mpslib.readthedocs.io/en/latest/).

# Compilation
The MPSlib codes are written in standard [C++11](https://www.wikiwand.com/en/C%2B%2B11).

MPSlib has been developed using the GNU C++ compiler (tested on Windows, Linux and OSX), and Visual Studio C++.

## Linux or macOS, with c++11
In general MPSLIB can be compiled using GCC ( > 4.8.1 ),  using

	make

## Windows: (mingw-w64)
Compiler flags:

CPPFLAGS = -static -O3

MPSlib has been tested using mingw in windows. Note that not all builds of mingw will work. Therefor we specifically make use of mingw-w64 ([http://mingw-w64.org/doku.php]), which can be obtained in a number of ways.

One (recommended) approach is to make use of MSYS2. Follow the guide at [http://msys2.github.io/] to install MSYS2, and then install the mingw_w64 toolchain using:

		pacman -S mingw-w64-x86_64-gcc
		pacman -S make


# Release history

## v1.0 [15-02-2016]
Initial release of MPSlib, with
`mps_snesim_list`,
`mps_snesim_tree`, and
`mps_genesim`.


# Running MPS algorithms
The MPS algorithms are run from the commandline using a parameter filename as an argument.
If no argument is give, the deafault parameter file is assumed to the be name of the simulation
algorithm appended with '.txt'.

Therefore
```
mps_genesim
```
and

```
mps_genesim mps_genesim.txt
```
has the same meaning.


## SNESIM: `mps_snesim_tree` and `mps_snesim_list`
the `mps_snesim_tree` and `mps_snesim_list` differ only in the way conditional data are stored in memory
(using either a tree or a list structure).

Both algorithms share the same format for the required parameter file:
```
Number of realizations # 1
Random Seed (0 for not random seed) # 0
Number of mulitple grids # 2
Min Node count (0 if not set any limit) # 0
Max Conditional count (-1 if not using any limit) # -1
Search template size X # 5
Search template size Y # 5
Search template size Z # 1
Simulation grid size X # 100
Simulation grid size Y # 100
Simulation grid size Z # 1
Simulation grid world/origin X # 0
Simulation grid world/origin Y # 0
Simulation grid world/origin Z # 0
Simulation grid grid cell size X # 1
Simulation grid grid cell size Y # 1
Simulation grid grid cell size Z # 1
Training image file (spaces not allowed) # TI/mps_ti.dat
Output folder (spaces in name not allowed) # output/.
Shuffle Simulation Grid path (1 : random, 0 : sequential) # 1
Maximum number of counts for condtitional pdf # 10000
Shuffle Training Image path (1 : random, 0 : sequential) # 1
HardData filaneme  (same size as the simulation grid)# harddata/mps_hard_grid.dat
HardData seach radius (world units) # 15
Softdata categories (separated by ;) # 1;0
Soft datafilenames (separated by ; only need (number_categories - 1) grids) # softdata/mps_soft_xyzd_grid.dat
Number of threads (minimum 1, maximum 8 - depend on your CPU) # 1
Debug mode(2: write to file, 1: show preview, 0: show counters, -1: no ) # 1
```

A few lines in the paremeter files are specific to the SNESIM type algorithms, and will be discussed below:
#### line 3, n_mul_grids
n_mul_grids defines the number of multiple grids used.
n_mul_grids=0, means that no multiple grid will be used.

#### line 4, n_min_node
The search tree will only be searched to a level where the number of counts in the
conditional distribution is above n_min_node.

#### line 5, n_cond
n_cond is the maximum number of conditional point used, within the search template

#### lines 6-8, the search template, tem_nx, tem_ny, tem_nz
The search template defines the size of the template that is used to prescan the traning image
and store (using a tree or list) the conditional distribution for all figurations of the data template.

## Generalized ENESIM: mps_genesim
`mps_genesim` is a generalized version of the ENESIM algorithm, that can be used to perform MPS simulation
similar to both ENESIM and Direct sampling (and in-between) depending how it is run.

An example of a parameter file is:
```
Number of realizations # 1
Random Seed (0 `random` seed) # 0
Maximum number of counts for conditional pdf # 1
Max number of conditional point # 25
Max number of iterations # 10000
Simulation grid size X # 18
Simulation grid size Y # 16
Simulation grid size Z # 1
Simulation grid world/origin X # 0
Simulation grid world/origin Y # 0
Simulation grid world/origin Z # 0
Simulation grid grid cell size X # 1
Simulation grid grid cell size Y # 1
Simulation grid grid cell size Z # 1
Training image file (spaces not allowed) # ti.dat
Output folder (spaces in name not allowed) # .
Shuffle Simulation Grid path (1 : random, 0 : sequential) # 2
Shuffle Training Image path (1 : random, 0 : sequential) # 1
HardData filename  (same size as the simulation grid)# conditional.dat
HardData seach radius (world units) # 1
Softdata categories (separated by ;) # 0;1
Soft datafilenames (separated by ; only need (number_categories - 1) grids) # soft.dat
Number of threads (minimum 1, maximum 8 - depend on your CPU) # 1
Debug mode(2: write to file, 1: show preview, 0: show counters, -1: no ) # -2
```

A few lines in the parameter files are specific to the GENESIM type algorithm, and will be discussed below:

#### line 3: Maximum number of counts for conditional pdf, n_max_count_cpdf
n_max_count_cpdf defines the maximum number of counts in the conditional distribtion obtained from the training image.
When n_max_count_cpdf has been reached the scanning of the training image stops.

##### ENESIM style
In case n_max_count_cpdf=infinity, mps_genesim will behave exactly to the classical ENESIM
algorithm, where the full traning is scanned at each iteration

##### Direct sampling style
In case n_max_count_cpdf=1, mps_genesim will behave similar to the direct sampling algorithm,

#### line 4: Max number for conditional points, n_cond
A maximum of n_cond conditional data are considered at each iteration when infering the
conditional pdf from the training image.

#### line 5:Max number of iterations, n_max_ite
A maximum of n_max_ite iterations of searching through the training image are performed.



## General options in the parameter files
The following entrie appear in all parameter files


#### Number of realizations
The number of realizations to generate

#### Random Seed
An integer determines the random seed. A fixed value will return the same realizations for each run.
+ [0] assign a 'random' seed at each iteratoin (new seed every second)

#### Simulation grid size X, Y, Z
The number of grid cells in the simulation grid

#### Simulation grid origin X, Y, Z
The value coordinate of the first pixel in the X, Y, and Z direction.

#### Simulation grid grid cell size X #
The size of each pixel in the simulation grid, in the X, Y, and Z direction.

#### Training image file
The name of the training image file (no spaces allowed).
it must be in GLSIB/EAS ASCII format, and the first line (the 'title') must contain the
dimension of the traning file as 'NXxNYxNZ'.
See the TI folder for examples.


#### Output folder (spaces in name not allowed)
The path to the folder containing all output. Use forward slash '/' to separate folders.



#### Shuffle Simulation Grid path (1 : random, 0 : sequential) # 1
+ [0] sequential path through simulation grid (possibly a multiple grid)
+ [1] random path through simulation grid

#### Maximum number of counts for condtitional pdf

#### Shuffle Training Image path (1 : random, 0 : sequential)
(Does not affect snesim type algrothms)
+ [0] sequential path
+ [1] random path

#### HardData filaneme  
EAS filename wity 4 columns: X, Y, Z, and D

#### HardData seach radius
(world units)

#### Softdata categories
(separated by ;)

#### Soft datafilenames
(separated by ; only need (number_categories - 1) grids)

#### Number of threads (minimum 1, maximum 8 - depend on your CPU)
Currently not used.

#### Debug mode
+ [-2]: No information is written to screen or files on disk
+ [-1]: + Simulation output is written to files on disk
+ [ 0]: + Information about simulation is written to screen
+ [ 1]: + Simulated realization(s) are shown in terminal
+ [ 2]: + Extra information is written to disk (Random path, ...)
+ [ 3]: + Debug information written to screen (in general not useful for an end-user)
