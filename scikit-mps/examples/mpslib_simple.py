'''
mpslib_simple:
The simplest example of running MPSlib from python
'''
import mpslib as mps


#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_snesim_tree')
#%% Select number of iterations [def=1]
O.par['n_real']=4


# Set training image
O.ti = mps.trainingimages.strebelle()[0]
O.plot_ti()

#%% Run MPSlib
O.run()

#%% Plot the results
O.plot_reals(hardcopy=1, hardcopy_filename='mpslib_simple_reals')

O.plot_etype(hardcopy=1, hardcopy_filename='mpslib_simple_etype')
