'''Python
Example of using sequential Gibbs simualtion to randoly pertub a realization
'''


import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np
import random

O1=mps.mpslib(method='mps_snesim_tree')

TI1, TI_filename1 = mps.trainingimages.strebelle(3, coarse3d=1)
O1.ti=TI1

O1.par['n_multiple_grids']=2;
O1.par['n_cond']=49
O1.par['n_real']=1
O1.par['debug_level']=-1
O1.par['simulation_grid_size'][0]=35
O1.par['simulation_grid_size'][1]=30
O1.run()

step=0.75;


N_run = 9;

for i in range(0,N_run):

    D1 = O1.sim[0]

    d_hard = O1.seq_gibbs_set_hard_data(step)
    O1.d_hard = d_hard
    O1.run()

    D2 = O1.sim[0]

    plt.figure(1)
    plt.subplot(131)
    plt.pcolor(O1.x,O1.y,D1)
    plt.subplot(132)
    plt.scatter(d_hard[:,0],d_hard[:,1],c=d_hard[:,3])
    plt.subplot(133)
    plt.pcolor(O1.x,O1.y,D2)

    plt.savefig('seq_gibbs_%02d'%(i+1))
    plt.show()





