'''
mpslib_entropy:
Compute selfinformation for each realizations and then the Entropy
'''
import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np
import copy

plt.ion()

#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_genesim')

#%% Select number of iterations [def=1]
O.par['n_cond']=9
O.par['simulation_grid_size'][0]=38
O.par['simulation_grid_size'][1]=23
O.par['simulation_grid_size'][2]=1
O.par['hard_data_fnam']='hard.dat'
#%% Use hard data
# Set hard data
d_hard = np.array([[ 3, 3, 0, 1],
                    [ 8, 8, 0, 0],
                    [ 12, 3, 0, 1]])
    

O.d_hard = d_hard
# Set training image
O.ti = mps.trainingimages.strebelle(di=3, coarse3d=1)[0]
#O.plot_ti()

#%% Run MPSlib in simulation mode
O.parameter_filename='mps.txt'
O.par['do_entropy']=1
O.par['n_real']=30

O.par['n_real']=10
O.par['n_max_cpdf_count']=10 # We need ENESIM/GENESIM and not DS
O.par['n_max_ite']=1000000
O.remove_gslib_afterulation=0
O.delete_local_files() # to make sure no old data are floating around


#%%
Onc=[]
H=[]
Hstd=[]
n_cond_arr=[0,1,2,4,8,16]
i=-1
for n_cond in n_cond_arr:
    i=i+1
    print(n_cond)
    Onc.append(copy.deepcopy(O))
    Onc[i].par['n_cond']=n_cond
    Onc[i].run()
    H.append(Onc[i].H)
    Hstd.append(Onc[i].Hstd)

plt.figure()
plt.subplot(211)
plt.semilogy(n_cond_arr,H,'-*')
plt.xlabel('n_cond')
plt.ylabel('Entropy')

plt.subplot(212)
plt.errorbar(n_cond_arr, H, Hstd)
plt.yscale('log')
plt.xlabel('n_cond')
plt.ylabel('Entropy')


