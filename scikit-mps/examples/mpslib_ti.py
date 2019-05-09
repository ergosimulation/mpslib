'''
Load and plot training images
'''

import numpy as np
import matplotlib.pyplot as plt
import mpslib as mps
from scipy import squeeze

    

#%% Read and plot training images
TI, TI_fname = mps.trainingimages.strebelle()
TI, TI_fname = mps.trainingimages.bangladesh()
TI, TI_fname = mps.trainingimages.rot90()
if (TI.shape[2]==1):
    plt.imshow(TI[:,:,0])
else:
    mps.plot.plot_3d(TI, slice=1)
        
Deas=mps.eas.read(TI_fname)
D=Deas['Dmat']
mps.plot.plot_eas(Deas)


#%% Test that EAS reading and writing are consistent
fname='test.dat'

mps.eas.write_mat(TI,fname)
Deas2=mps.eas.read(fname)
D2=Deas2['Dmat']
print(D.shape)
print(D2.shape)


#%% Plot all available trainig images

TI_fnames,d=mps.trainingimages.ti_list()

for i in range(len(TI_fnames)):
    print('Loading %s' % TI_fnames[i])
    TI, TI_fname = getattr(mps.trainingimages,TI_fnames[i])()
    print(TI.shape)
    mps.plot.plot_3d(TI,1)

#%%

'''
Show examples of simple 2D checkeboard training images
'''
plt.figure(2)
fig, axs = plt.subplots(2,2, figsize=(10, 10), facecolor='w', edgecolor='k')
axs = axs.ravel()
for i in range(4):
    TI, TI_filename = mps.trainingimages.checkerboard(40,40,i+1)
    axs[i].imshow(squeeze(TI))
    axs[i].set_title(TI_filename + " - N%d " %i)

plt.suptitle('trainingimages.checkerboard')
plt.show(block=False)


#%%
'''
Show examples of simple 2D checkeboard training images
'''
plt.figure(3)
fig, axs = plt.subplots(2,4, figsize=(10, 6), facecolor='w', edgecolor='k')
axs = axs.ravel()
cell_x=8
cell_y=4
for i in range(4):
    TI, TI_filename = mps.trainingimages.checkerboard2(nx=40,ny=42, cell_x=4, cell_y=4, cell_2=2*i+1)
    axs[i].imshow(squeeze(TI))
    axs[i].set_title(TI_filename + " - N%d " %i, fontsize=8)
for i in range(4):
    TI, TI_filename = mps.trainingimages.checkerboard2(nx=40,ny=42, cell_x=(i+1)*2, cell_y=(i+1), cell_2=3*i+1)
    axs[i+4].imshow(squeeze(TI))
    axs[i+4].set_title(TI_filename + " - N%d " %i, fontsize=8)

plt.suptitle('trainingimages.checkerboard',fontsize=14)
plt.show(block=False)


#%%
'''
Show examples of the channels TI in different resolution
'''
plt.figure(4)
fig, axs = plt.subplots(2,3, figsize=(10, 6), facecolor='w', edgecolor='k')
axs = axs.ravel()
for i in range(6):
    TI, TI_filename = mps.trainingimages.strebelle(di=i+1)
    axs[i].imshow(np.transpose(squeeze(TI)))
    axs[i].set_title(TI_filename + " - N%d " %(i+1), fontsize=8)

plt.suptitle('Channels',fontsize=14)
plt.show(block=False)

#%%
'''
Show examples of the multiple channels TI in coarse resolution
'''
plt.figure(5)
di=5;
fig, axs = plt.subplots(di,di, figsize=(10, 10), facecolor='w', edgecolor='k')
axs = axs.ravel()
TI, TI_filename = mps.trainingimages.strebelle(di, coarse3d=1)
for i in range(di*di):
    axs[i].imshow(np.transpose(TI[:,:,i]))
    #axs[i].set_title(TI_filename + " - N%d " %(i+1), fontsize=8)

plt.suptitle("Coarsed Channels with different offset and di=%d"%(di) ,fontsize=14)
plt.show(block=False)




'''
Done
'''
plt.show()

# Show coarsened pseudo 3D cube
mps.plot.plot_3d(TI,slice=1)
