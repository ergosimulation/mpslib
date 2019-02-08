Matlab interface
================

A simple matlab interface to the algorithms on MPSlib has been
developed. It consist of the following m-files:

Running MPSlib algorithms:

-  `mps_cpp.m <>`__: Run MPSlib algorithms
-  `mps_cpp_thread.m <>`__: Split MPSlib simulation on multiple
   threads
-  `mps_cpp_clean.m <>`__: Clean up files after running MPSlib.

Reading and writing parameter files:

-  mps_snesim_read_par.m
-  mps_snesim_write_par.m
-  mps_enesim_read_par.m
-  mps_enesim_write_par.m

Examples:

-  mps_example_softwarex.m
-  mps_cpp_demo.m

These m-files requires no special toolboxes, and are compatible with GNU
Octave. However, the examples below requires the
`mGstat <http//mgstat.sf.net/>`__ toolbox.

``mps_cpp`` takes to three inputs, og which the first two are mandatory:

::

    TI  : [1D/2D/3D] matrix with a training image
    SIM : [1D/2D/3D] simulation grid of NaN values
    O   : Object controlling the simulation. (optional)

``mps_cpp.m`` can be used to perform MPS simulation using both
``mps_genesim``, ``mps_snesim_tree``, and ``mps_snesim_list``. By
default ``mps_snesim_tree`` is used unless the choice of simulation
algorithm is set in the ``O.method`` field:

::

    O.method='mps_snesim_tree';     
    O.method='mps_snesim_list'; 
    O.method='mps_genesim';

SNESIM type simulation
----------------------

The simplest approach to using ``mps_cpp`` is to use for example

::

    TI=channels;           %  training image
    SIM=zeros(80,60).*NaN; %  simulation grid
    [reals,O]=mps_cpp(TI,SIM);

This will use the classical channel based training image (from Strebelle
(2000)), and perform simulation 2D grid of size 80x60. The ``O``
structure will then be updated with all the parameters that can be set:

::

    >> O

    O = 

      struct with fields:

                                 null: ''
                                debug: -1
                                rseed: 1
                        output_folder: '.'
                          ti_filename: 'ti.dat'
                 simulation_grid_size: [60 80 1]
                               origin: [0 0 0]
                       grid_cell_size: [1 1 1]
                               method: 'mps_snesim_tree'
                   parameter_filename: 'snesim.txt'
                               n_real: 1
                     n_multiple_grids: 3
                     n_min_node_count: 0
                               n_cond: -1
                        template_size: [5 5 1]
              shuffle_simulation_grid: 1
        entropyfactor_simulation_grid: 4
                      shuffle_ti_grid: 1
                   hard_data_filename: 'conditional.dat'
              hard_data_search_radius: 1
                 soft_data_categories: '0;1'
                   soft_data_filename: 'soft.dat'
                            n_threads: 1
                         exe_filename: 'E:\Users\tmh\RESEARCH\PROGRAMMING\GITHUB\MPSLIB\matlab\..\mps_snesim_tree.…'
                                 time: 1.2122
                                    x: [1×60 double]
                                    y: [1×80 double]
                                    z: 0

GENESIM type simulation
-----------------------

A simple GENESIM type simulation can be obtained using

::

    TI=channels;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.method='mps_genesim'; 
    [reals,O]=mps_cpp(TI,SIM,O);

which return the ``O``\ data structure:

::

    > O

    O = 

      struct with fields:

                               method: 'mps_genesim'
                                debug: -1
                                rseed: 1
                        output_folder: '.'
                          ti_filename: 'ti.dat'
                 simulation_grid_size: [60 80 1]
                               origin: [0 0 0]
                       grid_cell_size: [1 1 1]
                   parameter_filename: 'genesim.txt'
                               n_real: 1
                               n_cond: 25
                            n_max_ite: 10000
                     n_max_cpdf_count: 10
                        template_size: [5 5 1]
              shuffle_simulation_grid: 1
        entropyfactor_simulation_grid: 4
                      shuffle_ti_grid: 1
                   hard_data_filename: 'conditional.dat'
              hard_data_search_radius: 1
                 soft_data_categories: '0;1'
                   soft_data_filename: 'soft.dat'
                            n_threads: 1
                         exe_filename: 'E:\Users\tmh\RESEARCH\PROGRAMMING\GITHUB\MPSLIB\matlab\..\mps_genesim.exe'
                                 time: 1.1624
                                    x: [1×60 double]
                                    y: [1×80 double]
                                    z: 0

GENESIM as ENESIM
~~~~~~~~~~~~~~~~~

``mps_genesim`` can act as a classical ENESIM algorithm by scanning the
whole training image at each iteration: \`

::

    TI=channels;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.n_max_ite
    O.method='mps_genesim'; 
    O.n_max_ite=1e+9 ; Iterate 'forever'
    O.n_max_cpdf_count=1e+9 ; No upper limit on number of counts for conditional pdf
    [reals,O]=mps_cpp(TI,SIM,O);

GENESIM as DIRECT SAMPLING
~~~~~~~~~~~~~~~~~~~~~~~~~~

``mps_genesim`` can act as the DIRECT SAMPLING algorithm by scanning
whole training image only until one (the first) matching event is found,
i.e. by at each iteration: \`

::

    TI=channels;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.n_max_ite
    O.method='mps_genesim'; 
    O.n_max_cpdf_count=1 ; No upper limit on number of counts for conditional pdf
    [reals,O]=mps_cpp(TI,SIM,O);

Plot simulation results
-----------------------

``mps_cpp_plot``, can be used use to plot simulation results

::

    [reals,O]=mps_cpp(TI,SIM,O);
    mps_plot_cpp(reals,O);

If debug level is larger than one, then the number of temporary grids
with different information, is alos visualized.

::

    O.debug_level=2;
    [reals,O]=mps_cpp(TI,SIM,O);
    mps_plot_cpp(reals,O);

Parallel simulation
-------------------

When simulating more than one realization, ``mps_cpp_thread`` can be
used to split the simulation onto several threads, such that simulation
will be performed in parallel. (This requires Matlab with the `Matlab
Parallel
toolbox <https://mathworks.com/products/parallel-computing/>`__)

::

    TI=channels;           %  training image
    SIM=zeros(80,60).*NaN; %  simulation grid
    O.method='mps_snesim_tree'; 
    O.n_real=10;

    % simulation on one CPU
    t0=now;
    [reals]=mps_cpp(TI,SIM,O);
    disp(sprintf('Elapsed time (sequential): %g s',(now-t0)*(3600*24)))

    % simulation on multiple CPUs (require the Matlab Parallel toolbox)
    t0=now;
    [reals]=mps_cpp_thread(TI,SIM,O);
    disp(sprintf('Elapsed time (parallel): %g s',(now-t0)*(3600*24)))

Provides the following output, running on 4 threads:

::

    Elapsed time (sequential): 21.326 s
    mps_cpp_thread: Using 4 threads/workers
    mps_cpp_thread: running thread #4 in mps_04
    mps_cpp_thread: running thread #3 in mps_03
    mps_cpp_thread: running thread #2 in mps_02
    mps_cpp_thread: running thread #1 in mps_01
    Elapsed time (parallel): 6.835 s
