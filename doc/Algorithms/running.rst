General options
---------------

The following entries appear in all parameter files

Number of realizations
^^^^^^^^^^^^^^^^^^^^^^

The number of realizations to generate

Random Seed
^^^^^^^^^^^

An integer determines the random seed. A fixed value will return the
same realizations for each run.

-  [0] assign a 'random' seed at each iteration (new seed every second)

Simulation grid size X, Y, Z
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The number of grid cells in the simulation grid

Simulation grid origin X, Y, Z
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The value coordinate of the first pixel in the X, Y, and Z direction.

Simulation grid grid cell size X
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The size of each pixel in the simulation grid, in the X, Y, and Z
direction.

Training image file
^^^^^^^^^^^^^^^^^^^

| The name of the training image file (no spaces allowed).
| it must be in GSLIB/EAS ASCII format, and the first line (the 'title')
  must contain the
| dimension of the training file as 'NX NY NZ'.
| See the TI folder for examples, and `Training image
  format </training-image-format.md>`__ for more information.

Output folder (spaces in name not allowed)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The path to the folder containing all output. Use forward slash '/' to
separate folders.

Shuffle Simulation Grid path (2: preferential, 1: random, 0: sequential) # 2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-  [0] sequential path through simulation grid (possibly a multiple
   grid)
-  [1] random path through simulation grid
-  [2] preferential path (only useful when soft data is considered)

Entropy factor
^^^^^^^^^^^^^^

When a preferential path is selected the 'EntropyFactor' can be se as a
second parameter after the choice of path.

Shuffle Training Image path (1 : random, 0 : sequential)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

(Does not affect snesim type algorithms)

-  [0] sequential path
-  [1] random path

HardData filename
^^^^^^^^^^^^^^^^^

EAS filename with 4 columns: X, Y, Z, and D

HardData search radius
^^^^^^^^^^^^^^^^^^^^^

(world units)

Softdata categories
^^^^^^^^^^^^^^^^^^^

(separated by ;)

Soft datafilenames
^^^^^^^^^^^^^^^^^^

(separated by ; only need (number\_categories - 1) grids)

Number of threads (minimum 1, maximum 8 - depend on your CPU)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Currently not used.

Debug mode
^^^^^^^^^^

-  [-2]: No information is written to screen or files on disk
-  [-1]: + Simulation output is written to files on disk
-  [ 0]: + Information about simulation is written to screen
-  [ 1]: + Simulated realization(s) are shown in terminal
-  [ 2]: + Extra information is written to disk (Random path, number of conditional data, ...)
-  [ 3]: + Debug information written to screen (results in much slower performance - in general not useful
   for an end-user)

MASK file
^^^^^^^^^

EAS filename with 4 columns: X, Y, Z, and MASK. 
A mask files of tha same size as the simulation grid can be supplied. '0' in a node indicates a node that will not be simulated. '1' in a node indicates a node that will be simulated.

Entropy
^^^^^^^^^

-  [ 0]: No computation of entropy
-  [ 1]: Compute entropy/self-information as part of simulation

See [HANSEN2020]_ for more information.

Estimation
^^^^^^^^^^

-  [ 0]: Do not perform sequential estimation
-  [ 1]: Perform sequential estimation (rather than sequential simulation)

See [JOHANNSSON2019]_ for more information.
