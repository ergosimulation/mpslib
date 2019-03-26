'''
mpslib_hard_and_soft_data.py

Example of parsing hard and soft data to MPSLIB algorithms
'''

import mpslib as mps
import numpy as np

#%%
if __name__ == '__main__':
    
    
    #%%
    #O1=mps.mpslib(method='mps_snesim_tree', parameter_filename='mps_snesim.txt')
    O1=mps.mpslib(method='mps_genesim', parameter_filename='mps_genesim.txt')
    

    use_ti_2cat = 0
    if use_ti_2cat==1:
        TI1, TI_filename1 = mps.trainingimages.strebelle(3, coarse3d=1)
        O1.par['soft_data_categories']=np.array([0,1])
    
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
        O1.par['soft_data_categories']=np.array([0,1,2])
    
        
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
    
    
    
    
    O1.ti=TI1
    
    #%%
    O1.par['n_cond']=16
    O1.par['rseed']=1
    O1.par['simulation_grid_size'][0]=30
    O1.par['simulation_grid_size'][1]=30
    O1.par['simulation_grid_size'][2]=1
    O1.par['n_real']=200
    O1.par['debug_level']=-1
    O1.par['hard_data_fnam']='hard.dat'
    O1.par['soft_data_fnam']='soft.dat'
    # snesim
    O1.par['n_multiple_grids']=2;
    O1.par['n_max_cpdf_count']=1
    O1.par['shuffle_simulation_grid']=1
    # enesim
    O1.par['n_cond_soft']=1
    
    
    O1.delete_local_files()
    
    
    
    
    #O1.d_hard = d_hard
    O1.d_soft = d_soft
    
    O1.remove_gslib_after_simulation=1;
    doRunPar = 1
    if (doRunPar):
        O1.par['n_threads']=-1;
        O1.run_parallel()
    else:
        O1.run()
    
    #s=np.std(O1.sim, axis=0)
    #m=np.mean(O1.sim, axis=0)
    
    O1.plot_reals()
    O1.plot_etype()
    
    