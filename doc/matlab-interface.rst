Matlab interface
================

A simple Matlab interface to the algorithms on MPSlib has been
developed. It consists of the following m-files:

Running MPSlib algorithms:

-  `mps_cpp.m <https://github.com/ergosimulation/mpslib/blob/master/matlab/mps_cpp.m>`_: Run MPSlib algorithms
-  `mps_cpp_thread.m <https://github.com/ergosimulation/mpslib/blob/master/matlab/mps_cpp_thread.m>`_: Split MPSlib simulation on multiple
   threads
-  `mps_cpp_clean.m <https://github.com/ergosimulation/mpslib/blob/master/matlab/mps_cpp_clean.m>`_: Clean up files after running MPSlib.

Reading and writing parameter files:

-  mps_snesim_read_par.m
-  mps_snesim_write_par.m
-  mps_enesim_read_par.m
-  mps_enesim_write_par.m

Examples:

-  mps_cpp_example.m
-  mps_cpp_example_softwarex.m
-  mps_cpp_example_estimation.m
-  mps_cpp_example_entropy.m

These m-files requires no special toolboxes, and are compatible with GNU
Octave.

``mps_cpp`` takes to three inputs, of which the first two are mandatory:

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

Getting started in Matlab
-------------------------

The simplest approach to using ``mps_cpp`` is to use for example

::

    TI=mps_ti;           %  training image
    SIM=zeros(80,60).*NaN; %  simulation grid
    [reals,O]=mps_cpp(TI,SIM);

This will use the classical channel based training image (from Strebelle
(2000)), and perform unconditinoal simulation (using ``mps_snesim_tree``) in 2D grid of size 80x60 pixels. ``reals`` will contain one single generated realization, and the ``O`` structure will be populated with all the parameters used for ``mps_snesim_tree``:

::

    O = 

    struct with fields:

                                null: ''
                                debug: -1
                                rseed: 0
                        output_folder: '.'
                            WriteTI: 1
                        ti_filename: 'ti.dat'
                simulation_grid_size: [60 80 1]
                            origin: [0 0 0]
                    grid_cell_size: [1 1 1]
                        mask_filename: 'mask.dat'
                hard_data_filename: 'd_hard.dat'
                            method: 'mps_snesim_tree'
                parameter_filename: 'mps_snesim.txt'
                            n_real: 1
                    n_multiple_grids: 3
                    n_min_node_count: 0
                            n_cond: 39
                        template_size: [5 5 1]
            shuffle_simulation_grid: 2
        entropyfactor_simulation_grid: 4
                    shuffle_ti_grid: 1
            hard_data_search_radius: 1
                soft_data_categories: '0;1'
                soft_data_filename: 'soft.dat'
                            n_threads: 1
                        doEstimation: 0
                            doEntropy: 0
                        exe_filename: 'F:\PROGRAMMING\mpslib\matlab\..\mps_snesim_tree.exe'
                                time: 0.2945
                                    x: [1×60 double]
                                    y: [1×80 double]
                                    z: 0
                                clean: 1

SNESIM type simulation
-----------------------
SNESIM, using both search trees and list for lookup, is available using both ``mps_snesim_tree``and ``mps_snesim_list``. Both algorithms make use of the same parameters (and parameter file)'. The choice of simulation algortihm is done using:
::
    O.method='mps_snesim_list'; 
    O.method='mps_snesim_tree'; 

The main parameters specific for ``mps_snesim_tree`` and ``mps_snesim_list`` are 
::
                    n_multiple_grids: 3  # Number of multiple grids
                    n_min_node_count: 0  # min number of counts in conditional pdf
                            n_cond: 39   # number of conditional data
                        template_size: [5 5 1]  # the templated size

A dynamic template size canbe set using 
::
    O.template_size = [15 15 1; 5 5 1]';
that suggests a template size of [15 15 1] is used at the coarse grid, and [5 5 1] at the finest grid.


GENESIM type simulation
-----------------------

A simple GENESIM type simulation can be obtained using

::

    TI=mps_ti;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.method='mps_genesim'; 
    [reals,O]=mps_cpp(TI,SIM,O);

which return the ``O``\ data structure:

::

    O = 

    struct with fields:

                            method: 'mps_genesim'
                                debug: -1
                                rseed: 0
                        output_folder: '.'
                            WriteTI: 1
                        ti_filename: 'ti.dat'
                simulation_grid_size: [60 80 1]
                            origin: [0 0 0]
                    grid_cell_size: [1 1 1]
                        mask_filename: 'mask.dat'
                hard_data_filename: 'd_hard.dat'
                parameter_filename: 'mps_genesim.txt'
                            n_real: 1
                            n_cond: [25 1]
                            n_max_ite: 1000000
                    n_max_cpdf_count: 1
            shuffle_simulation_grid: 2
        entropyfactor_simulation_grid: 4
                    shuffle_ti_grid: 1
            hard_data_search_radius: 100000
                soft_data_categories: '0;1'
                soft_data_filename: 'soft.dat'
                            n_threads: 1
                    distance_measure: 1
                        distance_min: 0
                        distance_pow: 0
                colocated_dimension: 0
                    max_search_radius: [1000000 1000000]
                        doEstimation: 0
                            doEntropy: 0
                        exe_filename: 'F:\PROGRAMMING\mpslib\matlab\..\mps_genesim.exe'
                                time: 1.9083
                                    x: [1×60 double]
                                    y: [1×80 double]
                                    z: 0
                            clean: 1

The main parameters specific for ``mps_genesim`` are 
::

                               n_cond: [25 1]     % maximum number of conditional data for 
                                                  % hard and soft data
                            n_max_ite: 1000000    % maximum number of iteration in the ti
                     n_max_cpdf_count: 10         % maximum counts for the conditional pdf

The distance ``measure_measure``, ``measure_min``, ``measure_pow`` controls hwo the distance is computed for discrete and continious parameters:

::
                    distance_measure: 1
                        distance_min: 0
                        distance_pow: 0                     
        

GENESIM as ENESIM
^^^^^^^^^^^^^^^^^

``mps_genesim`` can act as a classical ENESIM algorithm by scanning the
whole training image at each iteration: \`

::

    TI=mps_ti;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.method='mps_genesim'; 
    O.n_max_ite=1e+9 ; Iterate 'forever'
    O.n_max_cpdf_count=1e+9 % No upper limit on number of counts for conditional pdf
    [reals,O]=mps_cpp(TI,SIM,O);

GENESIM as DIRECT SAMPLING
^^^^^^^^^^^^^^^^^^^^^^^^^^
``mps_genesim`` can act as the DIRECT SAMPLING algorithm by scanning
whole training image only until one (the first) matching event is found,
i.e. by at each iteration: \`

::

    TI=mps_ti;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.method='mps_genesim'; 
    O.n_max_ite  = 1000
    O.n_max_cpdf_count=1 ; % No upper limit on number of counts for conditional pdf
    [reals,O]=mps_cpp(TI,SIM,O);

GENESIM, a hybrid between ENESIM and DIRECT SAMPLING
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
GENESIM can run as a hybrid between DIRETC SAMPLING and ENESIM, by setting ``n_max_cpdf_count`` somewhere between 1 (DIRECT SAMPLING) and infinitty (ENESIM). This is especially usefule when conditioning to soft data- 

::

    TI=mps_ti;           %  training image
    SIM=zeros(80,60).*NaN; %  simulationgrid
    O.method='mps_genesim'; 
    O.n_max_ite  = 1000
    O.n_max_cpdf_count=10 ; % 
    [reals,O]=mps_cpp(TI,SIM,O);



Plot simulation results
-----------------------

``mps_cpp_plot``, can be used used to plot simulation results

::

    [reals,O]=mps_cpp(TI,SIM,O);
    mps_plot_cpp(reals,O);

If debug level is larger than one, then the number of temporary grids
with different information, is also visualized.

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

    TI=mps_ti;           %  training image
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

Sequential Estimation
---------------------
 All of ``mps_genesim``, ``mps_snesim_tree``, ``mps_snesim_list`` can used to perform conditinoal 'estimation', rather the the default sequential simulation, simply by setting ``O.doEstimation=1``. 

 Details about using sequential estimation with MPS algorithms can be found in [JOHANNSSON2019]_

::

      TI=mps_ti;           %  training image
      SIM=zeros(80,60).*NaN; %  simulationgrid
      SIM(10:12,20)=0; % some conditional data
      SIM(40:40:43)=1; % some conditional data
      O.method='mps_genesim';
      O.doEstimation=1;

      [reals,O]=mps_cpp(TI,SIM,O);
      est = O.cg; % this of size [80,60,2] as the training image has 2 soft_data_categories


Sequential estimation can be performed in parallel, consideiring each pixel at a time. This is utilised in ``mps_cpp_estimation`` that use parallel threads for faster estimation: 
::

      O.n_max_cpdf_count=100000;
      [est]=mps_cpp_estimation(TI,SIM,O);



Self-information and Entropy
----------------------------
The self-information for realizations can be computed by setting ``O.doEntropy=1``. 
Details about computing the self-information is found in  [HANSEN2020]_.

In this case the self-information of each realization is returned in ``O.SI``, and the entropy is the simply the average of  ``O.SI``.  


::

      clear all;
      TI=mps_ti;           %  training image
      SIM=zeros(80,60).*NaN; %  simulation grid
      O.method='mps_snesim_tree';
      O.doEntropy=1;
      O.n_real = 10;
      [reals,O]=mps_cpp(TI,SIM,O);

      % The self-information of each realizations is 
      O.SI = 

            431.6090
            364.8060
            415.4050
            378.6850
            425.6930
            402.5930
            524.6750
            475.0100
            336.9290
            489.7420

      % Compute the entropy as the average self-information
      H_est = mean(O.SI)

            H_est =

        424.5147





