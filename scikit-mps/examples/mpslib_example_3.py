# mpslib_example.py
# example of using mpslib.py

import os
import sys
sys.path.append('p:\\troels.norvin\\mpslib\\mpslib_python\\python\\')


#%%
import mpslib as mps
import mpslib.eas as eas
import matplotlib.pyplot as plt
import numpy as np

#%%  LOAD TI
ti_file_remote = os.path.join('..','ti','ti_bangladesh_768_243_1.dat')
ti_file1='ti_1.dat'
Oti = eas.read(ti_file_remote)
eas.write_dict(Oti,ti_file1)

fig1 = plt.figure(1)
plt.title('TI')
plt.imshow(Oti['Dmat'])
#plt.show()
#%% TRANSPOSE AND WRITE TI
ti_file2 = 'ti_2.dat'

Dmat=Oti['Dmat']
O = eas.write_mat(Dmat.transpose(),ti_file2)

#%% READ WRITTEN TO AN PLOT
Oti2 = eas.read(ti_file2)
fig1 = plt.figure(2)
plt.imshow(Oti2['Dmat'])
plt.title('TI 2')
#plt.show()

#%% SIMULATE
O1 = mps.mpslib(method='mps_snesim_tree', n_real = 1, verbose_level=0, ti_fnam=ti_file1)
O1.run()

O1.blank_grid = np.zeros((O1.par['simulation_grid_size'][1],O1.par['simulation_grid_size'][0]),dtype=np.int)
O1.blank_grid[0:20,:]=1
O1.blank_sim()

O2 = mps.mpslib(method='mps_snesim_tree', n_real = 1, verbose_level=0, ti_fnam=ti_file2)
O2.run()

O2.blank_grid = np.zeros((O1.par['simulation_grid_size'][1],O1.par['simulation_grid_size'][0]),dtype=np.int)
O2.blank_grid[20:,:]=1
O2.blank_sim()

#%%
plt.set_cmap('hot')
fig1 = plt.figure(1)
plt.subplot(2,2,1)
plt.imshow(O1.simblk[0], interpolation='none')
plt.subplot(2,2,2)
plt.imshow(O2.simblk[0], interpolation='none')

fig1.suptitle(O1.method, fontsize=16)
plt.savefig('ex3.png', dpi=600)


