# mpslib_example.py
# example of using mpslib.py


#%%
import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np

#%%  LOAD TI

#%%  LOAD TI
ti = mps.trainingimages.bangladesh(di=2)[0]


ti_file1='ti_1.dat'
ti_file2 = 'ti_2.dat'

#%% SIMULATE
O1 = mps.mpslib(method='mps_snesim_tree', n_real = 1, verbose_level=0, ti_fnam=ti_file1)
O1.ti = ti
O1.run()

O1.blank_grid = np.zeros((O1.par['simulation_grid_size'][1],O1.par['simulation_grid_size'][0]),dtype=np.int)
O1.blank_grid[0:20,:]=1
O1.blank_sim()

O2 = mps.mpslib(method='mps_snesim_tree', n_real = 1, verbose_level=0, ti_fnam=ti_file2)
O2.ti = np.transpose(ti)
O2.run()

O2.blank_grid = np.zeros((O1.par['simulation_grid_size'][1],O1.par['simulation_grid_size'][0]),dtype=np.int)
O2.blank_grid[20:,:]=1
O2.blank_sim()

#mpsobjs = [O1,O2]
#mps.regions(mpsobj = mpsobjs)

#%%
plt.set_cmap('hot')
fig1 = plt.figure(1)
plt.subplot(2,2,1)
plt.imshow(O1.simblk[0], interpolation='none')
plt.subplot(2,2,2)
plt.imshow(O2.simblk[0], interpolation='none')
fig1.suptitle(O1.method, fontsize=16)
plt.savefig('mpslib_example_4.png', dpi=600)
plt.show()



