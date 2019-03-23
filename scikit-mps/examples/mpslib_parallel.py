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
if __name__ == '__main__':
    
    #%%
    O=mps.mpslib(method='mps_snesim_tree', simulation_grid_size=(80,70,1), origin=(0,0,0))
    
    #O.par['n_threads']=30; # 10
    
    O.par['n_real']=30
    O.par['n_cond']=16
    d_hard = np.array([[25,10,0,0],[28,13,0,1]])
    d_hard = np.array([[25,10,0,0],[28,13,0,1]])
    d_soft = np.array([[10,10,0,0.1, 0.9],[10,13,0,.1, 0.9],[30,53,0,.01, 0.99]])
    # Set training image
    O.ti = mps.trainingimages.checkerboard2()[0]
    O.ti = mps.trainingimages.strebelle(di=2)[0]
    #O.plot_ti()
    O.d_hard = d_hard
    O.d_soft = d_soft
    #O.delete_local_files() # Make sure no hard/soft data are conditioned to
    O.remove_gslib_after_simulation=1;
    #O.gslib_combine
    
    
    # INMPORTANT
    O.delete_hard_data()
    O.delete_soft_data()
    O.delete_mask_data()
    

    
    
    #%% SERIAL    
    '''
    Oserial = copy.deepcopy(O)
    t0=time.time()
    Oserial.run()
    t1=time.time()-t0
    print('Simulation time sequential: %4.2fs' % t1)    
    '''     
    #%% PARALLEL    
    # NEXT LINE NEEDED IN WINDOWS TO PREVENT INFINITE LOOP
    Opar1 = copy.deepcopy(O)
    if (os.name=='nt2'):
        print('Do not run this in a script as it will cause an infinite loop in windows')
        print('Instead, run it intearctively in ipython.')
        input("Press Enter to continue...")
    Opar1.par['n_threads']=-1# USE ALL
    t0=time.time()
    Opar1.run_parallel()
    t2=time.time()-t0
    
    print('Simulation time parallel:   %4.2fs' % t2)    
    
    
        
    #%% PARALLEL    
    '''
    # NEXT LINE NEEDED IN WINDOWS TO PREVENT INFINITE LOOP
    Opar2 = copy.deepcopy(O)
    print('in script: __name__ = %s' % __name__)
    if (os.name=='nt2'):
        print('Do not run this in a script as it will cause an infinite loop in windows')
        print('Instead, run it intearctively in ipython.')
        input("Press Enter to continue...")
    Opar2.par['n_threads']=2# USE 4
    t0=time.time()
    Opar2.run_parallel()
    t3=time.time()-t0
    
    print('Simulation time parallel:   %4.2fs' % t3)    
    '''    
    #%%
    '''
    print("_______________________________________")
    print('Simulation time sequential: %4.2fs' % t1)    
    print('Simulation time parallel:   %4.2fs' % t2)    
    print('Simulation time parallel:   %4.2fs' % t3)    
    '''



    emean, evar = Opar1.plot_etype()
    mps.plot.plot_3d_vtk(emean[:,:,np.newaxis])
