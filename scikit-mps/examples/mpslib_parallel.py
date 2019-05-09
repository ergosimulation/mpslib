'''
mpslib_parallel:
An example of performing simulation in parallel
'''
import mpslib as mps
import time
import numpy as np
import os
import copy


#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
# for windows users : 
# IT IS SUPER IMPOERTANT TO ADD THE MEXT LINE IN ORDER TO PREVENT 
# PYTHON ENTERING AN INFINITE LOOP DOING PRALLEL SIMULATION!
if __name__ == '__main__':
    
    #%% Setup MPSlib
    O=mps.mpslib(method='mps_snesim_tree', simulation_grid_size=(80,70,1), origin=(0,0,0))
    #O=mps.mpslib(method='mps_genesim', simulation_grid_size=(80,70,1), origin=(0,0,0))
    
    
    O.par['n_real']=50
    O.par['n_cond']=4
    # Set training image
    O.ti = mps.trainingimages.strebelle()[0]
    #O.plot_ti()
    
    # Set hard and soft data
    O.delete_local_files() # Make sure no hard/soft data are conditioned to
    d_hard = np.array([[25,10,0,0],[28,13,0,1]])
    d_soft = np.array([[10,10,0,0.1, 0.9],[10,13,0,.1, 0.9],[30,53,0,.01, 0.99]])
    O.d_hard = d_hard
    O.d_soft = d_soft
    
    O.remove_gslib_after_simulation=1
    
    #%% SERIAL    
    Oserial = copy.deepcopy(O)
    t0=time.time()
    Oserial.run()
    t1=time.time()-t0
    print('Simulation time sequential: %4.2fs' % t1)    
    
    #%% PARALLEL    
    # NEXT LINE NEEDED IN WINDOWS TO PREVENT INFINITE LOOP
    Opar1 = copy.deepcopy(O)
    if (os.name=='nt2'):
        print('Do not run this in a script as it will cause an infinite loop in windows')
        print('Instead, run it intearctively in ipython.')
        input("Press Enter to continue...")
    Opar1.par['n_threads']=-1# USE ALL available threads
    #Opar1.par['n_threads']=20# USE 20 threads
    #Opar1.par['n_threads']=64# USE 4 threads
    t0=time.time()
    Opar1.run_parallel()
    t2=time.time()-t0
    
    print('Simulation time parallel:   %4.2fs' % t2)    
    
    #%%
    try:
        print('Simulation time sequential: %4.2fs' % t1)    
    except:
        pass
    
    #%% Plot somwe results



    emean, evar = Opar1.plot_etype()
    mps.plot.plot_3d(emean[:,:,np.newaxis])
