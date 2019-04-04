Ex: Varying template size in SNESIM
-----------------------------------
`mps_snesim_tree` and `mps_snesim_list` allowing using a template size that changes for each multiple grid.
The template size is given as a value for the coarsest multiple grid, and a value for the final dense simulation grid. Linear interpolation is used to compute the template size at each multiple grid

For example using a template size of 8x7x4 oon the coarsest grid and a template size of 4x3x3 on the finest grid can be given in the mps_snesim parameter file as 

.. code-block:: python
   :linenos:
   :lineno-start: 6

   Search template size X # 8 4
   Search template size Y # 7 3
   Search template size Z # 4 3
   ...
    
The main reason for using variable template size is that, typically, a considerable amount of CPU is used in the finer simulation grids to prune (remove) conditional data.

The computational speed and effect on simulation results can be investigated by simulating with a fixed random seed for a number of different choices of template (from `mpslib_snesim_varying_template.py <https://github.com/ergosimulation/mpslib/blob/master/scikit-mps/examples/mpslib_snesim_varying_template.py>`_).
Figure :numref:`varying_template` shows one realization obtained using a fixed template size of 11x11x1 (upper left) compared to using varyaing templates. The startingf template (used at the coarse multiple grid) is set to 11x11x1 in all cases. The template at the finest grid is tested for 10x10x1, 9x9x1, ...., 1x1x1.
The lower left figure shows the simulation time for each realization. Figure :numref:`varying_template_speedup` show the computational speedup relative to using a fixed full size template. 

The computational speedup is more significant doing 3D simulation.

.. _varying_template:
.. figure:: /assets/varying_template.png

   E-type mean using a sequential, random and preferential simulation path, conditioning to 3 non-co-located soft data.


.. _varying_template_speedup:
.. figure:: /assets/varying_template_speedup.png
    :width: 70%
    :align: center
   
    CPU speedup compared to using a fixed template of size 11x11x1.



