'''
mpslib_hard_and_soft_data.py

Example of parsing hard and soft data to MPSLIB algorithms

Compare to mpslib/examples/soft_as_hard/ex_hard_as_soft

'''

import mpslib as mps
import numpy as np
import time
import copy
import matplotlib.pyplot as plt
#%%
if __name__ == '__main__':
    
    
    #%%
    #O=mps.mpslib(method='mps_snesim_tree', parameter_filename='mps_snesim.txt')
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
                           [ 3, 14, 0, 0.999, 0.001]])
    
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
    #O.par['n_cond']=36
    #O.par['n_real']=400
    O.par['n_cond']=16
    O.par['n_real']=40
    O.par['rseed']=1
    O.par['simulation_grid_size'][0]=30
    O.par['simulation_grid_size'][1]=30
    O.par['simulation_grid_size'][2]=1
    O.par['debug_level']=-1
    O.par['hard_data_fnam']='hard.dat'
    O.par['soft_data_fnam']='soft.dat'
    # snesim
    O.par['n_multiple_grids']=2;
    O.par['n_max_cpdf_count']=1
    O.par['shuffle_simulation_grid']=2
    # enesim
    O.par['n_cond_soft']=1
    
    n_cond_soft = np.array([0,1,2,3])
    i_path = np.array([0,1,2])
    
    t=np.zeros((len(n_cond_soft),len(i_path)))
                
    n=-1
    OUT=[]
    for i in range(len(n_cond_soft)):
        
        EM=[]
        for j in range(len(i_path)):
            
            
            
            n=n+1
            O.delete_local_files()
            
            O_test = copy.deepcopy(O)
            
            O_test.par['n_cond_soft']=n_cond_soft[i]
            O_test.par['shuffle_simulation_grid']=i_path[j]
            
            #O_test.d_hard = d_hard
            O_test.d_soft = d_soft
            
            t0=time.time()
            doRunPar = 1
            if (doRunPar):
                O_test.par['n_threads']=20;
                O_test.run_parallel()
            else:
                O_test.par['n_real']=30
                O_test.run()


            EM.append(np.mean(O_test.sim, axis=0))
            t[i,j]=time.time()-t0
        
        OUT.append(EM)
        
        
    mps.plot.marg1D(O_test,1)    
    #%% plot some data
    fig = plt.figure(figsize=(15, 15))
    plt.clf
        
    for i in range(len(n_cond_soft)):
        for j in range(len(i_path)):
        
            isb=len(i_path)*i+j+1
            plt.subplot(len(n_cond_soft),len(i_path),isb)
            plt.imshow(np.transpose(OUT[i][j][:,:,0]), vmin=0, vmax= np.max(O.ti));
            plt.title('ip=%d, nc=%d, t=%3.1fs' % (i_path[j],n_cond_soft[i],t[i,j]), fontsize=8)
    plt.suptitle('%s - %s' % (O.method,TI_filename1))
    plt.savefig('hard_as_soft_data_%s.png' % (O.method), dpi=600, facecolor='w', edgecolor='w',
        orientation='portrait', transparent=True)
    #plt.show()
            
            
    #%% plot some data
        
    for i in range(len(n_cond_soft)):
        fig = plt.figure(figsize=(15, 6))    
        plt.clf

        for j in range(len(i_path)):        
            isb=j+1
            plt.subplot(1,len(i_path),isb)
            plt.imshow(np.transpose(OUT[i][j][:,:,0]), vmin=0, vmax= np.max(O.ti));
            if i_path[j]==0:
                txt='Sequential'
            elif i_path[j]==1:
                txt='Random'
            elif i_path[j]==2:
                txt='Preferential'
                
            plt.title('%s path, Nc_{soft}=%d, t=%3.1fs' % (txt,n_cond_soft[i],t[i,j]), fontsize=12)
            
        #plt.suptitle('%s - %s' % (O.method,TI_filename1))
        plt.savefig('hard_as_soft_data_nonco_%s_%d.png' % (O.method,n_cond_soft[i]), dpi=600, facecolor='w', edgecolor='w', orientation='portrait', transparent=True)
        #plt.show()
                        
            