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

import matplotlib.pyplot as plt
import mpslib as mps


O1=mps.mpslib(method='mps_genesim')
O1.par['debug_level']=-1
# when debug_level>-1 and the text output from mpslib increase, the mpslib exe file is detached from 
# python before it has finished running!!!
TI, TI_filename=mps.trainingimages.checkerboard2()
O1.ti = TI
O1.par['ti_fnam']=TI_filename
O1.par['simulation_grid_size'][0]=35
O1.par['simulation_grid_size'][1]=35
O1.par['simulation_grid_size'][2]=1
O1.par['soft_data_fnam']='soft_case2.dat'
O1.par['shuffle_simulation_grid']=2
O1.par['n_cond']=25
O1.par['rseed']=0
O1.par['n_real']=16
O1.parameter_filename='plot.par'
O1.run()


#%%
O1.plot_reals(O1.par['n_real'])
O1.plot_etype()
O1.plot_reals(O1.par['n_real'])


wait = input("PRESS ENTER TO CONTINUE.")


