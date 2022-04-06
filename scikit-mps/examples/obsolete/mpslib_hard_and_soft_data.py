'''
mpslib_hard_and_soft_data.py

Example of parsing hard and soft data to MPSLIB algorithms
'''
#%%
import mpslib as mps
import numpy as np
import matplotlib.pyplot as plt
plt.ion()

#%%
if __name__ == '__main__':
    
    
    #%%
    #O1=mps.mpslib(method='mps_snesim_tree', parameter_filename='mps_snesim.txt')
    O1=mps.mpslib(method='mps_genesim', parameter_filename='mps_genesim.txt')
    
    
    TI1, TI_filename1 = mps.trainingimages.strebelle(3, coarse3d=1)
    O1.par['soft_data_categories']=np.array([0,1])
    
    #TI1, TI_filename1 = mps.trainingimages.checkerboard2()
    #O1.par['soft_data_categories']=np.array([0,1,2])
    
    O1.ti=TI1
    
    #%%
    O1.par['rseed']=1
    O1.par['n_multiple_grids']=0;
    O1.par['n_cond']=25
    O1.par['n_cond_soft']=3
    O1.par['n_real']=50
    O1.par['debug_level']=-1
    O1.par['simulation_grid_size'][0]=18
    O1.par['simulation_grid_size'][1]=13
    O1.par['simulation_grid_size'][2]=1
    O1.par['hard_data_fnam']='hard.dat'
    O1.par['soft_data_fnam']='soft.dat'
    O1.delete_local_files()
    
    O1.par['n_max_cpdf_count']=100
    O1.par['shuffle_simulation_grid']=2
    
    # Set hard data
    d_hard = np.array([[ 0, 0, 0, 2],
                       [ 1, 0, 0, 0],
                       [ 2, 0, 0, 2]])
    
    # Set soft data
    d_soft = np.array([[ 0, 0, 0, 0, 0, 1],
                       [ 1, 0, 0, 1, 0, 0],
                       [ 2, 0, 0, 0, 0, 1]])
    
    
    # Set hard data
    d_hard = np.array([[ 0, 1, 0, 1],
                       [ 0, 1, 0, 1],
                       [ 0, 0, 0, 0]])
    
    # Set soft data
    d_soft = np.array([[ 0, 0, 0, 0.001, 0.999],
                       [ 1, 0, 0, 0.001, 0.999],
                       [ 2, 0, 0, 0.999, 0.001]])
    
    
    
    #O1.d_hard = d_hard
    O1.d_soft = d_soft
    
    
    #O1.remove_gslib_after_simulation=0;
    O1.par['n_threads']=-1;
    O1.run_parallel()
    
    s=np.std(O1.sim, axis=0)
    m=np.mean(O1.sim, axis=0)
    
    O1.plot_reals()
    O1.plot_etype()
    plt.show()
    
    #%% 
    D=np.zeros((len(O1.sim),3))
    for i in range(len(O1.sim)):
        D[i,0]=O1.sim[i][0,0][0]
        D[i,1]=O1.sim[i][1,0][0]
        D[i,2]=O1.sim[i][2,0][0]
        print('%g %g %g' % (O1.sim[i][0,0],O1.sim[i][1,0],O1.sim[i][2,0]) )
    
    print(np.std(D, axis=0))
    
