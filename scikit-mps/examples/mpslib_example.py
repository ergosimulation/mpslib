# mpslib_example.py
# example of using mpslib.py

import sys
sys.path.append('mpslib')


#%%
import mpslib as mps
# import mpslib_tmh as mps_tmh
import matplotlib.pyplot as plt
#plt.ion()

#%% MPS_SNESIM_TREE

O1 = mps.mpslib(method='mps_snesim_tree',hard_data_fnam = 'mps_2d_hard_data.dat',
                    n_real = 2, verbose_level=1)
O1.parameter_filename = 'mps_snesim.txt'
O1.par['debug_level']=-1
O1.par['n_cond']=4
#TI=mps.trainingimages.lines()
#O1.par['ti_fnam']=TI['filename']
O1.run()

# PLOT SNESIM
plt.set_cmap('hot')
fig1 = plt.figure(1)
for i in range(0, O1.par['n_real']):
    plt.subplot(3,3,i+1)
    plt.imshow(O1.sim[i], interpolation='none')

fig1.suptitle(O1.method, fontsize=16)
plt.savefig(O1.method+'.png', dpi=600)
plt.show()


#%% Use the same modeling parameters, but change simulation methods
O1.change_method('mps_genesim')
O1.change_method('mps_snesim_list')
O1.run()



#%% RUN GENESIM
O2 = mps.mpslib(method='mps_genesim',  verbose_level=1)
O2.par['n_real']=4;
O2.par['n_max_ite']=1000;
O2.par['n_cond']=31;
O2.par['shuffle_simulation_grid']=1;
O2.parameter_filename = 'mps_genesim.txt'
O2.run();


#%% PLOT GENESIM REALIZATIONS
font = {'family' : 'Ubuntu',
        'weight' : 'bold',
        'size'   : 8}
plt.rc('font', **font)
#plt.rcParams.update({'font.size': 6})

fig = plt.figure(2)
plt.set_cmap('gray')
fig.suptitle(O2.method, fontsize=16)
    

for i in range(0, O2.par['n_real']):
    ax = plt.subplot(3,3,i+1)
    ax.set_title('Realization #%d' % i)
    ax.imshow(O2.sim[i],interpolation='none')
        
plt.savefig(O2.method+'.png', dpi=600)
plt.show();
