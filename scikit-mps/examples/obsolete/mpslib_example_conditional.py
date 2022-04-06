#%%
import matplotlib.pyplot as plt
import mpslib as mps
import numpy as np


#%% MPS_SNESIM_TREE
O1=mps.mpslib(method='mps_snesim_tree')
O1=mps.mpslib(method='mps_genesim')
O1.delete_local_files()
O1.par['debug_level']=-1


# when debug_level>-1 and the text output from mpslib increase, the mpslib exe file is detached from 
# python before it has finished running!!!
#TI, TI_filename=mps.trainingimages.lines()
#TI, TI_filename=mps.trainingimages.bangladesh()
#TI, TI_filename=mps.trainingimages.checkerboard()
#TI, TI_filename=mps.trainingimages.checkerboard2()
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=40, ny=50, cell_x=8, cell_y=4, cell_2=10)
TI, TI_filename=mps.trainingimages.checkerboard2(nx=100, ny=100, cell_x=4, cell_y=4, cell_2=3)
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
O1.par['n_cond']=81
O1.par['rseed']=1
O1.par['n_real']=15
O1.par['n_min_node_count']=1
O1.parameter_filename='test.par'
O1.run()


#%%

O1.plot_reals()

O1.plot_etype()

plt.figure(3)
plt.imshow(np.transpose(TI[:,:,0]), interpolation='none')
plt.title(O1.par['ti_fnam'])



