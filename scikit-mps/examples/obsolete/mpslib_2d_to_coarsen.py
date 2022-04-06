# mpslib_2d_to_coarsen: Effect ofo corsening the training image
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import mpslib as mps
from scipy import squeeze
import copy
%matplotlib widget

plt.ion()

di=6 # Use every di'th data
# NO coarsening --> 1 2D TI
TI1, TI_filename1 = mps.trainingimages.strebelle(di, coarse3d=0)
# Coarsening --> multiple 2D TI
TI2, TI_filename2 = mps.trainingimages.strebelle(di, coarse3d=1)

mps.eas.write_mat(TI1,'ti1.dat')
mps.eas.write_mat(TI2,'ti2.dat')


#%% Plot the training images
fig = plt.figure(figsize=(15, 15))
outer = gridspec.GridSpec(2, 2, wspace=0.2, hspace=0.2)

ax1 = plt.Subplot(fig, outer[0])
fig.add_subplot(ax1)
plt.imshow(np.transpose(TI1[:,:,0]))
plt.title('One coarse TI')

ax1 = plt.Subplot(fig, outer[1])
fig.add_subplot(ax1)
plt.axis('off')
plt.title('LL')
plt.title('Mulitple coarse TI')

nsp = int(np.floor(np.sqrt(TI2.shape[2])))

for i in [1]:
    inner = gridspec.GridSpecFromSubplotSpec(nsp, nsp,
                    subplot_spec=outer[i], wspace=0.02, hspace=0.02)

    for j in range(nsp*nsp):
        ax = plt.Subplot(fig, inner[j])
        fig.add_subplot(ax)
        plt.imshow(np.transpose(TI2[:, :, j]))
        plt.axis('off')

#%% RUN THE SIMULATIONS

alg='mps_snesim_tree'
#alg='mps_genesim'
nc=8*8
rseed=1;
#nc=8*8
#Coarsen channel TI, using only coarsened TI

# Single coarsened TI
O1=mps.mpslib(method=alg)
O1.par['debug_level']=-1
O1.par['ti_fnam']='ti1.dat'
O1.par['simulation_grid_size'][0]=85
O1.par['simulation_grid_size'][1]=45
O1.ti = TI1
O1.par['simulation_grid_size'][2]=1
O1.par['shuffle_simulation_grid']=0
O1.par['n_cond']=nc
O1.par['rseed']=rseed
O1.par['n_real']=1
O1.parameter_filename='sim1.par'
O1.delete_local_files()
O1.run()

# Detailed Coarsened TI
O2=copy.deepcopy(O1);
O2.ti = TI2
O2.parameter_filename='sim2.par'
O2.delete_local_files()
O2.run()

#%%
ax3 = plt.Subplot(fig, outer[2])
fig.add_subplot(ax3)
plt.imshow(np.transpose(squeeze(O1.sim[0])))
plt.title('Real using Single coarse TI')

ax4 = plt.Subplot(fig, outer[3])
fig.add_subplot(ax4)
plt.imshow(np.transpose(squeeze(O2.sim[0])))
plt.title('Real using Multiple coarse TI')

plt.suptitle("%s - di=%d" % (alg,di))
plt.savefig('mpslib_coarsen_%d_%s.png'%(di,alg))

plt.show()
