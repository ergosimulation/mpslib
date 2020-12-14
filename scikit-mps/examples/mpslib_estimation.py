'''
mpslib_estimation:
Estimation vs simulation
'''
import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np
import copy

plt.ion()

#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_genesim')

#%% Select number of iterations [def=1]
O.par['n_real']=1
O.par['n_cond']=3
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
O_sim = copy.deepcopy(O)
O_sim.parameter_filename='mps_sim.txt'
O_sim.par['n_real']=30
O_sim.delete_local_files() # to make sure no old data are floating around
O_sim.run()

#%% Plot the results
O_sim.plot_reals(hardcopy=1, hardcopy_filename='sim_reals')
O_sim.plot_etype(hardcopy=1, hardcopy_filename='sim_etype')
plt.show()



#%% Run MPSlib in Estimation mode
O_est = copy.deepcopy(O)
O_est.parameter_filename='mps_est.txt'
O_est.delete_local_files() # to make sure no old data are floating around
O_est.par['do_estimation']=1
O_est.par['do_entropy']=1

O_est.par['n_real']=1
O_est.par['n_max_cpdf_count']=1000000 # We need ENESIM/GENESIM and not DS
O_est.par['n_max_ite']=1000000
O_est.remove_gslib_after_simulation=1

O_est.run()

#%%
P1=O_est.est[1][:,:,0].T
H=O_est.Hcond[:,:,0].transpose()

plt.figure()
plt.subplot(121)
plt.imshow(P1)
plt.title('P(m_i)=1')
plt.subplot(122)
plt.imshow(H)
plt.title('Conditional Entropy')

plt.show()
