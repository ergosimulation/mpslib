'''
plot_ti_3d.py Example of plotting training images using vista
'''
#%% Load modules
import mpslib as mps
import numpy as np 

#%% Loop through all TIøs and plot them in 3D
TI_fnames,d=mps.trainingimages.ti_list(1)

for i in range(len(TI_fnames)):
    print('Loading %s' % TI_fnames[i])
    TI, TI_fname = getattr(mps.trainingimages,TI_fnames[i])()
    
    # mps.plot.plot_3d(TI, slice=0, filename=d[i]+'.png')
    mps.plot.plot_3d(TI, slice=1, filename=d[i]+'.png')
