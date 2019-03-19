'''
plot_ti_vtki.py Example of plotting training images using vtki
'''
#%% Load modules
import mpslib as mps
import numpy as np 

def module_exists(module_name,show_info=0):
    try:
        __import__(module_name)
    except ImportError:
        if (show_info>0):
            print('%s cannot be loaded. please install it using e.g' % module_name)
            print('pip install %s' % module_name)
        return False
    else:
        return True


#%%

def plot_3d_vtk(Data, slice=0, filename=''):
    '''
    plot 3D sube using 'vtki' 
    '''
    
    if module_exists('vtki',1):
        import vtki
    else:
        return 1

    values = np.transpose(Data, (2,1,0))
    
    # Create the spatial reference
    grid = vtki.UniformGrid()
    # Set the grid dimensions: shape + 1 because we want to inject our values on the CELL data
    grid.dimensions = np.array(values.shape) + 1
    # Edit the spatial reference
    grid.origin = (0, 0, 0) # The bottom left corner of the data set
    grid.spacing = (1, 1, 1) # These are the cell sizes along each axis
    # Add the data values to the cell data
    grid.cell_arrays['values'] = values.flatten(order='F') # Flatten the array!
    # Now plot the grid!
    if (slice==0):
        grid.plot(show_edges=True)
    else:
        plot = vtki.Plotter()
        plot.add_mesh(grid.slice_orthogonal())
        plot.show_grid()
        if len(filename)>0:
            plot.screenshot(filename)
        plot.show()




#%% Loop through all TIøs and plot them in 3D
TI_fnames,d=mps.trainingimages.ti_list(1)

for i in range(len(TI_fnames)):
    print('Loading %s' % TI_fnames[i])
    TI, TI_fname = getattr(mps.trainingimages,TI_fnames[i])()
    
    plot_3d_vtk(TI,1,d[i]+'.png' )


#%% TEST EAS
import matplotlib.pyplot as plt
from scipy import squeeze

#ti_strebelle.dat')   
Deas = mps.eas.read('ti_checkerboard2_40_50__8_4__10.dat')
#Deas = mps.eas.read('ti_fluvsim.dat')    
D=Deas['Dmat']
print('original title -> ',Deas['title'])  
print('read size-> ',D.shape)  


S=mps.eas.write_mat(D,'test.dat')

Deas2 = mps.eas.read('test.dat')    
D2=Deas2['Dmat']
print('NEW title -> ',Deas2['title'])  
print('NEW read size-> ',D2.shape)  
  
#%%
plt.figure(1)
#plt.subplot(2,3,1);plt.imshow(squeeze(D[:,:,0]))
#plt.subplot(2,3,2);plt.imshow(squeeze(D[:,0,:]))
plt.subplot(2,3,3);plt.imshow(squeeze(D[0,:,:]))
#plt.subplot(2,3,4);plt.imshow(squeeze(D2[:,:,0]))
#plt.subplot(2,3,5);plt.imshow(squeeze(D2[:,0,:]))
plt.subplot(2,3,6);plt.imshow(squeeze(D2[0,:,:]))
