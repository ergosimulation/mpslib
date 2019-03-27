'''
mpslib_hard_and_soft_data.py

Example of parsing hard and soft data to MPSLIB algorithms
'''

import mpslib as mps
import numpy as np
import time
import copy
import matplotlib.pyplot as plt
#%%
if __name__ == '__main__':
    
    
    #%%
    #O1=mps.mpslib(method='mps_snesim_tree', parameter_filename='mps_snesim.txt')
    O=mps.mpslib(method='mps_genesim', parameter_filename='mps_genesim.txt')
    

    use_ti_2cat = 1
    if use_ti_2cat==1:
        TI1, TI_filename1 = mps.trainingimages.strebelle(3, coarse3d=1)
        O.par['soft_data_categories']=np.array([0,1])
    
        # Set hard data
        d_hard = np.array([[ 6, 14, 0, 1],
                           [ 13, 16, 0, 1],
                           [ 3, 14, 0, 0]])
    
        # Set soft data
        d_soft = np.array([[ 6, 14, 0, 0.001, 0.999],
                           [ 13, 16, 0, 0.001, 0.999],
                           [ 3, 14, 0, 0.001, 0.999]])
    
    else:
        TI1, TI_filename1 = mps.trainingimages.checkerboard2()
        O.par['soft_data_categories']=np.array([0,1,2])
    
        
        # Set soft data
        d_soft = np.array([[ 6, 14, 0, 0.001, 0.999, 0],
                           [ 13, 16, 0, 0.001, 0.999, 0],
                           [ 3, 14, 0, 0.001, 0.999, 0]])
    
        # Set hard data
        d_hard = np.array([[ 6, 14, 0, 2],
                           [ 3, 14, 0, 2]])
        # Set soft data
        d_soft = np.array([[ 6, 14, 0, 0.001, 0.001, 0.998],
                           [ 3, 14, 0, 0.001, 0.001, 0.998]])
    
    
    
    
    O.ti=TI1
    
    #%%
    O.remove_gslib_after_simulation=1;
    O.par['n_cond']=16
    O.par['rseed']=1
    O.par['simulation_grid_size'][0]=30
    O.par['simulation_grid_size'][1]=30
    O.par['simulation_grid_size'][2]=1
    O.par['n_real']=250
    O.par['debug_level']=-1
    O.par['hard_data_fnam']='hard.dat'
    O.par['soft_data_fnam']='soft.dat'
    # snesim
    O.par['n_multiple_grids']=2;
    O.par['n_max_cpdf_count']=1
    O.par['shuffle_simulation_grid']=2
    # enesim
    O.par['n_cond_soft']=1
    
    
    
    
    n_cond_soft = np.array([0,1,2])
    i_path = np.array([0,1,2])
    
    t = []
    etype_mean = [] 
    etype_std = [] 
    
    plt.figure(1)
    plt.clf()
            
    n=-1
    for i in range(len(n_cond_soft)):
        for j in range(len(i_path)):
            n=n+1
            O.delete_local_files()
            
            O_test = copy.deepcopy(O)
            
            O_test.par['n_cond_soft']=n_cond_soft[i]
            O_test.par['shuffle_simulation_grid']=i_path[j]
            
            O.d_hard = d_hard
            #O_test.d_soft = d_soft
            t0=time.time()
            doRunPar = 1
            if (doRunPar):
                O_test.par['n_threads']=-1;
                O_test.run_parallel()
            else:
                O_test.run()
            
            etype_mean.append(np.mean(O_test.sim, axis=0))
            etype_std.append(np.std(O_test.sim, axis=0))
            t.append(time.time()-t0)
            
            plt.figure(1)
            plt.subplot(3,3,n+1)
            plt.imshow(np.transpose(etype_mean[n][:,:,0]), vmin=0, vmax=2);
            #plt.colorbar();
            plt.title('ip=%d, nc=%d, t=%3.1fs' % (O_test.par['shuffle_simulation_grid'],O_test.par['n_cond_soft'],t[n]))
            
    plt.show()
            
            
    