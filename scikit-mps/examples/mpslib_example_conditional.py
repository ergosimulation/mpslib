#%%
import sys
import matplotlib.pyplot as plt
import mpslib as mps
import numpy as np

#%% MPS_SNESIM_TREE
O1=mps.mpslib(method='mps_snesim_tree')
#O1=mps.mpslib(method='mps_genesim')
O1.par['debug_level']=-1


# when debug_level>-1 and the text output from mpslib increase, the mpslib exe file is detached from 
# python before it has finished running!!!
TI, TI_filename=mps.trainingimages.lines()
#TI, TI_filename=mps.trainingimages.bangladesh()
#TI, TI_filename=mps.trainingimages.checkerboard()
#TI, TI_filename=mps.trainingimages.checkerboard2()
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=40, ny=50, cell_x=8, cell_y=4, cell_2=10)
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=100, ny=100, cell_x=4, cell_y=4, cell_2=3)
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=100, ny=100, cell_x=14, cell_y=8, cell_2=5)
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=40, ny=40, cell_x=4, cell_y=4, cell_2=9)
#TI, TI_filename=mps.trainingimages.maze()

O1.par['ti_fnam']=TI_filename
O1.par['simulation_grid_size'][0]=35
O1.par['simulation_grid_size'][1]=35
O1.par['simulation_grid_size'][2]=1

O1.par['soft_data_fnam']='soft_case2.dat'
O1.par['shuffle_simulation_grid']=2
O1.ti = TI
O1.par['n_cond']=1
O1.par['rseed']=0
O1.par['n_real']=125
O1.parameter_filename='test.par'
O1.run()


#plt.ion()
plt.figure(1)
plt.subplot(3, 3, 1)
plt.imshow(TI, interpolation='none')
plt.title(O1.par['ti_fnam'])

plt.set_cmap('hot')
fig1 = plt.figure(1)
for i in range(1, np.min((O1.par['n_real'],6))):
    plt.subplot(3,3,i+1)
    plt.imshow(O1.sim[i], interpolation='none')
    plt.title("Real %d" % i)

fig1.suptitle(O1.method, fontsize=16)
plt.show()


#%%
from scipy import stats
d=mps.eas.read(O1.par['soft_data_fnam'])
emean = np.mean(O1.sim, axis=0)
estd = np.std(O1.sim, axis=0)
mode=stats.mode(O1.sim, axis=0)
emode = mode[0][0]

plt.figure(2)
plt.subplot(1,3,1)
plt.imshow(emean)
plt.colorbar()
plt.plot(d['D'][:,0], d['D'][:,1], 'k*',MarkerSize=32)
#plt.scatter(x=d['D'][:,0], y=d['D'][:,1],s=20)
plt.scatter(x=d['D'][:,0], y=d['D'][:,1], c=d['D'][:,4],s=15)
#plt.scatter(x=d['D'][:,0], y=d['D'][:,1], c=d['D'][:,3])
plt.title('Etype Mean')

plt.subplot(1,3,2)
plt.imshow(estd)
plt.colorbar()
plt.plot(d['D'][:,0], d['D'][:,1], 'k*',MarkerSize=32)
plt.title('Etype Std')

plt.subplot(1,3,3)
plt.imshow(emode)
plt.colorbar()
plt.title('Etype Mode')

plt.savefig("soft_ti_example_%s_%s.png" % (O1.method,O1.par['ti_fnam']), dpi=600)
plt.show()



