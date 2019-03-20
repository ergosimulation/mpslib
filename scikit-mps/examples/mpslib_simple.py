'''
mpslib_simple:
The simplest example of running MPSlib from python
'''
import mpslib as mps


#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_snesim_tree')
O.par['n_real']=4


# Set training image
O.ti = mps.trainingimages.checkerboard2()[0]
O.plot_ti()

#%% Select number of iterations [def=1]

#%% Run MPSlib
O.delete_local_files() # Make sure no hard/soft data are conditioned to
O.run()

#%% Plot the results
O.plot_reals()

O.plot_etype()

O.plot_reals_vtk()
