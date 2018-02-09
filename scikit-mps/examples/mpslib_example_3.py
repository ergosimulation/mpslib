# mpslib_example_3.py
# Example of 'blank_simulation' --> Currently not working!!

#%%
import mpslib as mps
import mpslib.eas as eas
import matplotlib.pyplot as plt
import numpy as np

#%%  LOAD TI
ti = mps.trainingimages.strebelle(3,1)[0]


#%% SIMULATE
O1 = mps.mpslib(method='mps_snesim_tree', n_real = 1, verbose_level=-1)
O1.ti =ti
O1.run()

O1.blank_grid = np.zeros((O1.par['simulation_grid_size'][1],O1.par['simulation_grid_size'][0]),dtype=np.int)
O1.blank_grid[0:20,:]=1
O1.blank_sim()

O2 = mps.mpslib(method='mps_snesim_tree', n_real = 1, verbose_level=0)
O2.ti=np.transpose(ti)
O2.run()

O2.blank_grid = np.zeros((O1.par['simulation_grid_size'][1],O1.par['simulation_grid_size'][0]),dtype=np.int)
O2.blank_grid[20:,:]=1
O2.blank_sim()

#%%
plt.set_cmap('hot')
fig1 = plt.figure(1)
plt.subplot(2,2,1)
plt.imshow(O1.blank_grid, interpolation='none')
plt.subplot(2,2,2)
plt.imshow(O2.blank_grid, interpolation='none')
plt.subplot(2,2,3)
plt.imshow(O1.simblk[0], interpolation='none')
plt.subplot(2,2,4)
plt.imshow(O2.simblk[0], interpolation='none')
fig1.suptitle('mpslib_example_3 '+O1.method, fontsize=16)
plt.savefig('ex3.png', dpi=600)
plt.show()


