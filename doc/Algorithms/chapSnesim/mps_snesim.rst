.. _ref-snesim:

SNESIM: Single normal equation simulation
=========================================

The ``mps_snesim_tree`` and ``mps_snesim_list`` differ only in the way conditional data are stored in memory (using either a tree like [STREBELLE2002]_ or a list structure as [STRAUBHAAR2011]_). 

Both algorithms share the same format for the required parameter file:

::

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
    Shuffle Simulation Grid path (2: Preferential, 1: random, 0: sequential) # 1
    Maximum number of counts for condtitional pdf # 10000
    Shuffle Training Image path (1 : random, 0 : sequential) # 1
    HardData filaneme  (same size as the simulation grid)# harddata/mps_hard_grid.dat
    HardData seach radius (world units) # 15
    Softdata categories (separated by ;) # 1;0
    Soft datafilenames (separated by ; only need (number_categories - 1) grids) # softdata/mps_soft_xyzd_grid.dat
    Number of threads (minimum 1, maximum 8 - depend on your CPU) # 1
    Debug mode(2: write to file, 1: show preview, 0: show counters, -1: no ) # 1

A few lines in the parameter files are specific to the SNESIM type
algorithms, and will be discussed below:

line 3, ``n_mul_grids``
^^^^^^^^^^^^^^^^^^^^^^^

``n_mul_grids`` defines the number of multiple grids used.
``n_mul_grids=0``, means that no multiple grid will be used.

line 4, ``n_min_node``
^^^^^^^^^^^^^^^^^^^^^^

The search tree will only be searched to a level where the number of
counts in the conditional distribution is above ``n_min_node``.

line 5, ``n_cond``
^^^^^^^^^^^^^^^^^^

``n_cond`` is the maximum number of conditional point used, within the
search template

lines 6-8, the search template, ``tem_nx``, ``tem_ny``, ``tem_nz``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| The search template defines the size of the template that is used to
  prescan the training image
| and store (using a tree or list) the conditional distribution for all
  configurations of the data template.

Varying template size [only valid for mps\_snesim\_tree]
--------------------------------------------------------

Optionally a the template size can vary for different multiple grid
sizes. The first number refer to the template size at the coarsest
multiple grid. The last number refer to the template size at the finest
grid (simulated last). The template size for intermediate grid sizes is
found by linear interpolation, and output to the screen if the debug
mode is above 0. The use of varying template sizes can reduce
computation time considerable, with only little effect on the pattern
reproduction.

For example the following defines a 9x9x1 template at the coarsest grid,
and a 3x3x1 grid at the finest grid

::

    Search template size X # 9 3
    Search template size Y # 9 3
    Search template size Z # 1 1

Also,

::

    Search template size X # 5 5 
    Search template size Y # 5 5 
    Search template size Z # 5 5

is equivalent to

::

    Search template size X # 5  
    Search template size Y # 5  
    Search template size Z # 5 

 		    
   
