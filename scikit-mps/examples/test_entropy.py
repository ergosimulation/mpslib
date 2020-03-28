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
    O1=mps.mpslib(method='mps_snesim_tree', parameter_filename='mps_snesim.txt')
    #O1=mps.mpslib(method='mps_genesim', parameter_filename='mps_genesim.txt')
    
    
    #TI1, TI_filename1 = mps.trainingimages.strebelle(3, coarse3d=1)
    TI1, TI_filename1 = mps.trainingimages.strebelle(2)
    O1.par['soft_data_categories']=np.array([0,1])
    
    #TI1, TI_filename1 = mps.trainingimages.checkerboard2()
    #O1.par['soft_data_categories']=np.array([0,1,2])
    
    O1.ti=TI1
    
    #%%
    O1.par['rseed']=1
    O1.par['n_multiple_grids']=0;
    O1.par['n_cond']=25
    O1.par['n_cond_soft']=3
    O1.par['n_real']=500
    O1.par['debug_level']=-1
    O1.par['simulation_grid_size'][0]=38
    O1.par['simulation_grid_size'][1]=33
    O1.par['simulation_grid_size'][2]=1
    O1.par['template_size']=np.array([[16,16,1],[4,4,1]]).T
    O1.par['do_entropy']=1
    

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
    d_hard = np.array([[ 18, 18, 0, 1],
                       [ 0, 10, 0, 1],
                       [ 10, 0, 0, 0]])
    
    # Set soft data
    d_soft = np.array([[ 0, 0, 0, 0.001, 0.999],
                       [ 8, 12, 0, 0.001, 0.999],
                       [ 2, 0, 0, 0.999, 0.001]])
    
    
    
    O1.d_hard = d_hard
    #O1.d_soft = d_soft
    
    
    #O1.remove_gslib_after_simulation=0;
    O1.par['n_threads']=64;
    #O1.run()
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
    
#%%
for nm in np.array([0,1,2,3]):
    import copy
    Oh=copy.deepcopy(O1);
    Oh.parameter_filename='mps_H%d.txt' % (nm)
    Oh.par['do_entropy']=1
    Oh.par['do_estimation']=1
    Oh.par['n_real']=1
    Oh.par['n_multiple_grids']=nm;
    Oh.par['n_cond']=36
    
    Oh.remove_gslib_after_simulation=0
    Oh.run()
      
    EAS_H =mps.eas.read('ti.dat_ent_0.gslib')
    H=EAS_H['Dmat']
    plt.imshow(np.squeeze(H).T, vmin=0, vmax=1)
    plt.colorbar()
    plt.savefig('%s_nm%d.png' % (Oh.method,Oh.par['n_multiple_grids']))
    plt.show()
    
    # interp
    Hnan = np.where(H==nanval, np.nan, H)
    Hnan=np.squeeze(Hnan).T
    x = np.arange(0, Hnan.shape[1])
    y = np.arange(0, Hnan.shape[0])
    #mask invalid values
    array = np.ma.masked_invalid(Hnan)
    xx, yy = np.meshgrid(x, y)
    #get only the valid values
    x1 = xx[~array.mask]
    y1 = yy[~array.mask]
    newarr = array[~array.mask]
    from scipy import interpolate
    Hinterp = interpolate.griddata((x1, y1), newarr.ravel(),(xx, yy), method='cubic')
    
    plt.imshow(Hnan, vmin=0, vmax=1)
    plt.colorbar()
    plt.savefig('%s_nm%d_nan.png' % (Oh.method,Oh.par['n_multiple_grids']))
    plt.show()
    
    plt.imshow(Hinterp, vmin=0, vmax=1)
    plt.colorbar()
    plt.savefig('%s_nm%d_interp.png' % (Oh.method,Oh.par['n_multiple_grids']))
    plt.show()
    
# IT SEESM ONE MULTIPLE GRID IS OPTIMAL!!!! FOLLOWED BY INTERPOLATION
    
    
    
#%%
Og=mps.mpslib(method='mps_snesim_tree', parameter_filename='mps_snesim.txt')
Og=copy.deepcopy(Oh);
Og.change_method('mps_genesim')
Og.par['n_max_cpdf_count']=1000
Og.par['n_max_ite']=10000000
Og.parameter_filename='mps_G.txt'

Og.remove_gslib_after_simulation=0
Og.run()

EAS_H =mps.eas.read('ti.dat_ent_0.gslib')
H=EAS_H['Dmat']
plt.imshow(np.squeeze(H).T, vmin=0, vmax=1)
plt.colorbar()
plt.savefig('%s.png' % (Og.method))
plt.show()



