GENESIM: Generalized ENESIM
===========================

GENESIM (``mps_genesim``) [HANSEN2016]_ is a generalized version of the ENESIM algorithm [GUARDIANO]_, in which the conditional distribtion computed from a finite set of conditional events. 

In one extreme, the full conditional distribution is obtained by scanning the whole training image at each iteration, in which case GENESIM is identical to the ENESIM algorithm [GUARDIANO]_.

In another extreme, the conditional distribution is constructed from only one conditional event. In this case GENESIM acts similar to the direct sampling algorithm [MARIETHOZ2010]_, with the practical difference that the local conditional distribution is in fact computed, and a realization is drawn from. In the direct sampling algorithm the conditional distribution is never realized, instead a new pixel value is chosen from the first matching conditional event.



An example of a parameter file for ``mps_genesim``:

::

    Number of realizations # 1
    Random Seed (0 `random` seed) # 0
    Maximum number of counts for conditional pdf # 1
    Max number of conditional point # 25
    Max number of iterations # 10000
    Distance Measure (0: discrete, 1: continious), maximum distance, power # 1 0 0
    ColocateDimension # 0
    Maximum Search Radius # 1000000
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
    Shuffle Simulation Grid path (2: preferential, 1: random, 0: sequential) # 2
    Shuffle Training Image path (1 : random, 0 : sequential) # 1
    HardData filename  (same size as the simulation grid)# conditional.dat
    HardData seach radius (world units) # 1
    Softdata categories (separated by ;) # 0;1
    Soft datafilenames (separated by ; only need (number_categories - 1) grids) # soft.dat
    Number of threads (minimum 1, maximum 8 - depend on your CPU) # 1
    Debug mode(2: write to file, 1: show preview, 0: show counters, -1: no ) # -2

A description of the options that apply to all MPS algorithms can be
seen :doc:`here <../running>`.


The following lines in the parameter files are specific to the GENESIM
type algorithm:

line 3: Maximum number of counts for conditional pdf, ``n_max_count_cpdf``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``n_max_count_cpdf`` defines the maximum number of counts in the
conditional distribution obtained from the training image. When
´n\_max\_count\_cpdf´ has been reached the scanning of the training
image stops.

When ``n_max_count_cpdf<0`` no limit on the number of counts is set.

line 4: Max number for conditional points, ``n_cond``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| A maximum of ``n_cond`` conditional data are considered at each
  iteration when inferring the
| conditional pdf from the training image.

line 5:Max number of iterations, ``n_max_ite``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A maximum of ``n_max_ite`` iterations of searching through the training
image are performed.

if\ ``n_max_ite<0`` the full training image is scanned.

line 6: distance\_measure, and, ``distance_measure``, maximum distance, ``distance_max``, and ``distance_pow``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``distance_measure`` used:

1: Number of matching pixels (Discrete TI)

2: Euclidean distance (Continuous TI)

The maximum distance what will lead to accepting a conditional template
match is set by ``distance_max. If not set, is set to distance_max=0``,
which means that a perfect match is searched for!

| Distance power is used to weight the conditioning data as a function
  of distance from the center values. ``distance_pow=0`` indicated no
  weighing. A higher will favor the data value of conditional events
  closer to the center value.
| See Mariethoz et al. (2010) Eqn. 2-3. for details.

line 6: 'max\_search\_radius'
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Only conditional data within a radius of 'max\_search\_radius' is used
as conditioning data.

line 7:'colocate\_dimension'
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For a 3D TI make sure the order matters in the last dimensions (allow
performing 2D co-simulation with conditional data in the third dimension)

debug mode
^^^^^^^^^^

when ``debug>1``, A number of extra grids will be written to disk for
each realization. If the used training image is called 'ti.dat', then,
following GSLIB files contains:

``ti.dat_tg1_0.gslib``: The distance between the conditional event and
the corresponding best 'match' in the TI .

``ti.dat_tg2_0.gslib``: The number of matching counts for the
conditional pdf.

``ti.dat_tg3_0.gslib``: The index in the TI, of the best matching
conditional event.

``ti.dat_path_0.gslib``: Index of the path in the simulation grid.

ENESIM
------

The classical ENESIM algorithm can be run setting\ ``n_max_count_cpdf``
and ``n_max_ite`` to infinity (using -1):

``Maximum number of counts for conditional pdf # -1``

``Max number of iterations # -1``

In this case the full training image will be scanned at each iteration
to establish a conditional probability density.

ENESIM leads to a very slow algorithm, but the full/most accurate
conditional distribtuion is computed at each iteration. This can be
usefull when performing simulation conditional to soft data. If not,
then the Direct Sampling algorithm is much more efficient
(``n_max_count_cpdf=inf)``

GENESIM
-------

In case\ ``0<n_max_count_cpdf<infinity``, ``mps_genesim`` will behave
intermediate between ENESIM and Direct Sampling.

GENESIM is useful in case the local conditional distribution is needed,
as is the case when conditioning to soft data. In this case, the GENESIM
may be much faster than ENESIM.

DIRECT SAMPLING
---------------

In case ``n_max_count_cpdf=1``, ``mps_genesim`` will behave similar to
the direct sampling algorithm. The computational efficiency can further
be controlled using ``n_max_ite,``\ to be set a value smaller than the
number of pixels in the training image.

As the full local conditional distribution is not available (it is never
computed/inferred), conditioning to soft data is done using the
rejection sampler (Hansen et al. 20xx, submitted)

Temporary Grids
---------------

If the verbose level is higher than one 5 temporary grids are written do
disk. In case the training image has the name 'ti.dat' the following
grids are exported as EAS files :

ti.dat\_tg1\_0.gslib: The distance for the last accepted match, when
scanning the training image.

ti.dat\_tg2\_0.gslib: The number of counts used to set up the
conditional probability density. When using Direct Sampling,
``n_max_count_cpdf=1``, this value should never be higher than 1.

ti.dat\_tg3\_0.gslib: The index of the position in the training image
for last/best match.

ti.dat\_tg4\_0.gslib: The number of iterations in the training image.

ti.dat\_tg5\_0.gslib: Used number of conditional points.
