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

O1=mps.mpslib(method='mps_genesim')
O1.par['debug_level']=-1
# when debug_level>-1 and the text output from mpslib increase, the mpslib exe file is detached from 
# python before it has finished running!!!
TI, TI_filename=mps.trainingimages.checkerboard2()
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


