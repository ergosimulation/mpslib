'''
mpslib_simple:
The simplest example of running MPSliv from python
'''
import mpslib as mps
# Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_snesim_tree')
O.delete_local_files() # Make sure no hard/soft data are conditioned to

# Set training image
#O.ti= mps.trainingimages.strebelle()[0]
# Select number of iterations [def=1]
O.par['n_real']=4

# Run MPSlib
O.run()
# Plot the results
O.plot_reals()
O.plot_etype()

