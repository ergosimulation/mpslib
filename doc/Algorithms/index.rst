Running MPS algorithms
======================

| The MPS algorithms are run from the commandline using a parameter
  filename as an argument.
| If no argument is given, the default parameter file is assumed to the
  be name of the simulation
| algorithm appended with '.txt'.

Therefore

::

    mps_genesim
    mps_snesim_tree
    mps_snesim_list

will be equivalent to

::

    mps_genesim mps_genesim.txt
    mps_snesim_tree mps_snesim_tree.txt
    mps_snesim_list mps_snesim_list.txt


.. toctree::
   :maxdepth: 1
	      
   running   
   chapGenesim/mps_genesim
   chapSnesim/mps_snesim
   	     


