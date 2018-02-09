# mpslib_example_1.py
# example of using mpslib

#%%
import mpslib as mps
import matplotlib.pyplot as plt
plt.ion()
plt.set_cmap('hot')

#%% MPS_SNESIM_TREE

O1 = mps.mpslib(method='mps_snesim_tree',
                    n_real = 4, verbose_level=-1)
O1.parameter_filename = 'mps_snesim.txt'
O1.par['debug_level']=-1
O1.par['n_cond']=4
O1.run()

O1.plot_reals()
plt.savefig(O1.method+'.png', dpi=600)
plt.show()


#%% Use the same modeling parameters, but change simulation methods
O1.change_method('mps_snesim_list')
O1.run()
O1.plot_reals()
plt.savefig(O1.method+'.png', dpi=600)


#%% RUN GENESIM
# or consider
#O1.change_method('mps_genesim')
O2 = mps.mpslib(method='mps_genesim',  verbose_level=1)
O2.par['n_real']=4;
O2.par['n_max_ite']=1000;
O2.par['n_cond']=31;
O2.par['shuffle_simulation_grid']=1;
O2.parameter_filename = 'mps_genesim.txt'
O2.run();

O2.plot_reals()
plt.savefig("mpslib_exmaple_1_" + O2.method+'.png', dpi=600)
plt.show();
