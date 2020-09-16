SNESIM with varying template size
=================================

By default SNESIM will be run with a one fixed template size for all
multiple grids, using e.g

::

    Search template size X # 7  
    Search template size Y # 7  
    Search template size Z # 4 

It can be useful to change the size of the template, such that the
template size differs for each multiple grid used. This can be chosen by
defining two numbers the template in each direction. The first number
refers to the template size at the coarsest grid, while the last number
refers to the template size at the finest grid. For intermediate grids,
linear interpolation between first and last template size is used.

The following example will use a larger template size for the coarsest
grid (7x7x4), and a smaller template size for the finest grid (5x5x2):

::

    Search template size X # 7 5  
    Search template size Y # 7 5  
    Search template size Z # 4 2 

Examples of running ``mps_snesim_tree`` with different template sizes
can be found at
https://github.com/ergosimulation/mpslib/tree/master/examples/2D/varying_template.

The following figure show the result of 2D unconditional simulation
using different template sizes. The red line in the top of the figures
represent the CPU time needed to generate the different realizations:

.. figure:: /assets/mps_snesim_2d_varying_template_T0=__4_9s_NMulGrid=5.png
   :alt: 

