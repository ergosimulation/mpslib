# -*- coding: utf-8 -*-
"""
Created on Thu Feb  1 20:44:17 2018

@author: Thomas Mejer Hansen
"""
##%load_ext autoreload
##%autoreload 2
##%%
#import sys
#sys.path.append('../mpslib')

import mpslib as mps
import numpy as np
import pyvista as pv

#from pyvistaqt import BackgroundPlotter as Plotter    
from pyvista import Plotter as Plotter  

TI, TI_filename=mps.trainingimages.rot90()
mps.plot.plot_3d_pyvista(TI)

TI, TI_filename=mps.trainingimages.strebelle()
mps.plot.plot_3d_pyvista(TI, slice=1, origin=np.array([10,10,200]))



O=mps.mpslib(method='mps_snesim_tree', simulation_grid_size=np.array([30,30,20]))
O.run()

#%%

TI, TI_filename=mps.trainingimages.strebelle(di=4, coarse3d=1)
O=mps.mpslib(method='mps_snesim_tree', origin=np.array([10,10,20]),  simulation_grid_size=np.array([30,30,20]))
#O.par['template_size']=np.array([8,8,8])
O.par['template_size'][2]=8
O.par['n_cond']=49
O.run()

grid_ti = mps.plot.numpy_to_pvgrid(TI, origin=(0,0,0), spacing=(1,1,1))
grid_sim = mps.plot.numpy_to_pvgrid(O.sim[0], origin=O.par['origin'], spacing=O.par['grid_cell_size'])

plot = Plotter() # interactive

plot.add_mesh(grid_sim)
plot.add_mesh(grid_ti)

plot.show()

#%%

TI, TI_filename=mps.trainingimages.strebelle(di=4, coarse3d=1)
TI2=TI[:,:,0]

mps.plot.plot(TI)
mps.plot.plot(TI2)
              


#%%

grid = mps.plot.numpy_to_pvgrid(TI, origin=(0,0,0), spacing=(1,1,1))
plot = Plotter() # interactive
plot.add_mesh(grid)
plot.show()

#%%

# when debug_level>-1 and the text output from mpslib increase, the mpslib exe file is detached from 
# python before it has finished running!!!
TI, TI_filename=mps.trainingimages.checkerboard2()

plot = Plotter() # interactive
grid = mps.plot.numpy_to_pvgrid(TI, origin=(0,0,0), spacing=(1,1,1))
#grid_threshold = grid.threshold(threshold)   


#%%
O1=mps.mpslib(method='mps_genesim')
O1.par['debug_level']=-1
O1.ti = TI
O1.par['ti_fnam']=TI_filename
O1.par['simulation_grid_size'][0]=35
O1.par['simulation_grid_size'][1]=15
O1.par['simulation_grid_size'][2]=1
O1.par['soft_data_fnam']='soft_case2.dat'
O1.par['shuffle_simulation_grid']=2
O1.par['n_cond']=49
O1.par['rseed']=0
O1.par['n_real']=36
O1.d_hard=np.array([[10,10,0,2],[13,10,0,2]])
O1.parameter_filename='plot.par'
O1.delete_local_files()
O1.run()


#%%
mps.plot.plot_3d(TI)
O1.plot_reals(O1.par['n_real'])
O1.plot_reals_3d(O1.par['n_real'])
O1.plot_etype()


