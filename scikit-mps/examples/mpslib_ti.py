#

import numpy as np
import matplotlib.pyplot as plt
import mpslib as mps

plt.ion()

'''
Show different types of well known training images
'''

plt.figure(1)
fig, axs = plt.subplots(2, 3, figsize=(15, 12), facecolor='w', edgecolor='k')
axs = axs.ravel()
for i in range(5):
    if i==0:
        TI, TI_filename = mps.trainingimages.lines()
    elif i==1:
        TI, TI_filename = mps.trainingimages.bangladesh()
    elif i==2:
        TI, TI_filename = mps.trainingimages.maze()
    elif i==3:
        TI, TI_filename = mps.trainingimages.strebelle()
    elif i==4:
        TI, TI_filename = mps.trainingimages.stones()

    axs[i].imshow(TI)
    axs[i].set_title(TI_filename)

plt.show(block=False)

'''
Show examples of simple 2D checkeboard training images
'''
plt.figure(2)
fig, axs = plt.subplots(2,2, figsize=(10, 10), facecolor='w', edgecolor='k')
axs = axs.ravel()
for i in range(4):
    TI, TI_filename = mps.trainingimages.checkerboard(40,40,i+1)
    axs[i].imshow(TI)
    axs[i].set_title(TI_filename + " - N%d " %i)

plt.suptitle('trainingimages.checkerboard')
plt.show(block=False)


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
    axs[i].imshow(TI)
    axs[i].set_title(TI_filename + " - N%d " %i, fontsize=8)
for i in range(4):
    TI, TI_filename = mps.trainingimages.checkerboard2(nx=40,ny=42, cell_x=(i+1)*2, cell_y=(i+1), cell_2=3*i+1)
    axs[i+4].imshow(TI)
    axs[i+4].set_title(TI_filename + " - N%d " %i, fontsize=8)

plt.suptitle('trainingimages.checkerboard',fontsize=14)
plt.show(block=False)



'''
Show examples of the channels TI in different resolution
'''
plt.figure(4)
fig, axs = plt.subplots(2,3, figsize=(10, 6), facecolor='w', edgecolor='k')
axs = axs.ravel()
for i in range(6):
    TI, TI_filename = mps.trainingimages.strebelle(di=i+1)
    axs[i].imshow(TI)
    axs[i].set_title(TI_filename + " - N%d " %(i+1), fontsize=8)

plt.suptitle('Channels',fontsize=14)
plt.show(block=False)


'''
Show examples of the multiple channels TI in coarse resolution
'''
plt.figure(5)
di=5;
fig, axs = plt.subplots(di,di, figsize=(10, 10), facecolor='w', edgecolor='k')
axs = axs.ravel()
TI, TI_filename = mps.trainingimages.strebelle(di, coarse3d=1)
for i in range(di*di):
    axs[i].imshow(TI[:,:,i])
    #axs[i].set_title(TI_filename + " - N%d " %(i+1), fontsize=8)

plt.suptitle("Coarsed Channels with different offset and di=%d"%(di) ,fontsize=14)
plt.show(block=False)




'''
Done
'''
plt.show()

wait = input("PRESS ENTER TO CONTINUE.")
