# mpslib_example_mask.py
# example of using masks with mpslib

#%%
import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np
import copy
from scipy import squeeze

#%% Get some training images

# TI1: Strebelle
TI1, TI_filename1 = mps.trainingimages.strebelle(di=1)
TI1=np.swapaxes(TI1,0,1)
mps.eas.write_mat(TI1,TI_filename1)
# TI1: Strebelle, rotated and coarsened
TI2, TI_filename2 = mps.trainingimages.strebelle(di=2)
mps.eas.write_mat(TI2,TI_filename2)


plt.figure(1)
plt.subplot(121)
plt.imshow(np.transpose(squeeze(TI1)))
plt.title(TI_filename1)
plt.subplot(122)
plt.imshow(np.transpose(squeeze(TI2)))
plt.title(TI_filename2)
plt.show()

#%% MPS_SNESIM_TREE
grid_size = np.array([350, 200, 1])
O = mps.mpslib(method='mps_snesim_tree',
                    n_real = 1, verbose_level=-1)
#O = mps.mpslib(method='mps_genesim',
#                    n_real = 1, verbose_level=-1)
O.par['debug_level']=-1
O.par['n_cond']=49
O.par['simulation_grid_size']=grid_size
O.delete_hard_data()


#%% USE MASK
d_mask1=np.zeros([grid_size[0],grid_size[1],grid_size[2]])
d_mask1[80:150,100:180]=1;
d_mask1[0:40,80:150,]=1;
d_mask2=1-d_mask1;

mask_fnam1='mask_01.dat'
mask_fnam2='mask_02.dat'
mps.eas.write_mat(d_mask1,mask_fnam1)
mps.eas.write_mat(d_mask2,mask_fnam2)


plt.figure(2)
plt.subplot(121)
plt.imshow(np.transpose(squeeze(d_mask1)))
plt.title('Mask 1')
plt.subplot(122)
plt.imshow(np.transpose(squeeze(d_mask2)))
plt.title('Mask 2')
plt.show()


#%% Simulation in region/mask 1
O1=copy.deepcopy(O)
O1.par['mask_fnam']=mask_fnam1;
#O1.par['ti_fnam']=TI_filename1;
O1.ti=TI1
O1.run()
O1.plot_reals()
#%% SImulation in region/mask 2
d_hard = O1.hard_data_from_sim()
#%%
O2=copy.deepcopy(O)
O2.parameter_filename='mps_mask2.par'
O2.par['mask_fnam']=mask_fnam2;
O2.ti=TI2
#O2.par['ti_fnam']=TI_filename2;
O2.delete_hard_data()
O2.d_hard = d_hard
O2.run()
O2.plot_reals()



