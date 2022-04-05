#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 19 10:50:13 2019

@author: tmeha
"""

'''
functions for plotting with mpslib
'''
  


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

if module_exists('pyvista',1):
    import pyvista
else:
    print('pyvista is not installed')
    
import numpy as np 
import matplotlib.pyplot as plt


def numpy_to_pvgrid(Data, origin=(0,0,0), spacing=(1,1,1)):
    '''
    Convert 3D numpy array to pyvista uniform grid
    
    '''
  
    # Create the spatial reference
    grid = pyvista.UniformGrid()
    # Set the grid dimensions: shape + 1 because we want to inject our values on the CELL data
    grid.dimensions = np.array(Data.shape) + 1
    # Edit the spatial reference
    grid.origin = origin # The bottom left corner of the data set
    grid.spacing = spacing # These are the cell sizes along each axis
    # Add the data values to the cell data
    grid.cell_arrays['values'] = Data.flatten(order='F') # Flatten the array!

    return grid


### 2D/3D grid plotting

def plot(D, force_3d=0, plotgrid=1, slice=0, threshold=(), origin=(0,0,0), spacing=(1,1,1), cmap='viridis', filename='', header=''):
    '''Plot matrix in 2D (matplotlib) or 3D (pyvista)

    Parameters
    ----------
    
    '''
    if (D.ndim == 3)|(force_3d==1):
        plot_3d(D, plotgrid=plotgrid, slice=slice, threshold=threshold, origin=origin, spacing=spacing, cmap=cmap, filename=filename, header=header )
    else:
        plot_2d(D, origin=origin, spacing=spacing, cmap=cmap, filename=filename, header=header)
        

def plot_2d(Data, plotgrid=1, slice=0, threshold=(), origin=(0,0,0), spacing=(1,1,1), cmap='viridis', filename='', header='' ):
    Data=np.squeeze(Data)
    nx, ny = Data.shape
    
    extent = [ origin[0]+-0.5*spacing[0] ,  origin[0]+nx*spacing[0]+0.5*spacing[0] , origin[1]-0.5*spacing[1] ,  ny*spacing[1]+origin[1]+0.5*spacing[1] ]
    #print(extent)
    
    plt.imshow(np.transpose(Data), cmap=cmap, extent=extent)
    if len(filename)>0:
        plt.savefig(filename)
    
    plt.grid()
    if len(header)>0:
        plt.title(header)
    plt.show()
    
    

def plot_3d(Data, plotgrid=1, slice=0, threshold=(), origin=(0,0,0), spacing=(1,1,1), cmap='viridis', filename='', header='' ):
    '''
    plot 3D cube using 'pyvista' 
    '''
    #import numpy as np 
    #from pyvistaqt import BackgroundPlotter as Plotter    
    from pyvista import Plotter as Plotter    
    
    
    plot = Plotter() # interactive
    
    # create uniform grid 
    if (plotgrid==1)|(slice==1):
        grid = numpy_to_pvgrid(Data, origin=origin, spacing=spacing)
    
    if (plotgrid==1)&(slice==0):
        plot.add_mesh(grid, cmap=cmap)
    
    if (slice==1):
        grid_slice = grid.slice_orthogonal()
        plot.add_mesh(grid_slice, cmap=cmap)
        
        single_slice = grid.slice(normal=[1, 1, 0])
        plot.add_mesh(single_slice, cmap=cmap)
    
    if (len(threshold)==2):
        grid_threshold = grid.threshold(threshold)   
        plot.add_mesh(grid_threshold, cmap=cmap)

        
    if len(filename)>0:
        plot.screenshot(filename)
    
    plot.add_text(header)
    plot.show_grid()
    plot.show()



#### Plot reals

def plot_3d_reals(O, nshow=4):
    '''Plot realizations in in O.sim in 3D
    Currently simply a wrapper to plot_3d_reals_pyvista()'''
    plot_3d_reals_pyvista(O, nshow)


def plot_3d_reals_pyvista(O, nshow=4):
    '''Plot realizations in in O.sim in 3D using pyvista
    
    Paramaters
    ----------
    O : mpslib object
        
    nshow : int (def=4)
        show a maxmimum of 'nshow' realizations
    '''
    import numpy as np
    import pyvista
    
    if not(hasattr(O,'sim')):
        print('No data to plot (no "sim" attribute)')
        return -1
    if (O.sim is None):
        print('No data to plot ("sim" attribute i "None")')
        return -1
    
    nr = O.par['n_real']
    nshow = np.min((nshow,nr))
    
    
    nxy = np.ceil(np.sqrt(nshow)).astype('int')
    
    plotter = pyvista.Plotter( shape=(nxy,nxy))

    i=-1
    for ix in range(nxy):
        for iy in range(nxy):
            i=i+1;
            plotter.subplot(iy,ix)

            Data = O.sim[i]
            grid = pyvista.UniformGrid()
            grid.dimensions = np.array(Data.shape) + 1

            grid.origin = O.par['origin']
            grid.spacing = O.par['grid_cell_size']
            grid.cell_arrays['values'] = Data.flatten(order='F') # Flatten the array!

            plotter.add_mesh(grid.slice_orthogonal())
            plotter.add_text('#%d' % (i+1))
            plotter.show_grid()

        
    plotter.show()






#%%
def plot_3d_real(O,ireal=0,slice=0):
    '''
    plot 3D relization using pyvista
    O [MPSlib object]
    ireal [int] number of realizations
    slice [int] =1, slice volume
                =0, 3D cube
    '''
    
    plot_3d_pyvista(O.sim[ireal], slice=slice, origin=O.par['origin'], spacing=O.par['grid_cell_size'])
    
#%%
def plot_eas(Deas):
    '''
    Plot data directly form EAS
    '''
    import matplotlib.pyplot as plt
    import numpy as np
    from scipy import squeeze
    
    # check for matrix/cube
    if 'Dmat' in Deas:
        if (Deas['dim']['nz']==1):
            if (Deas['dim']['ny']==1):
                plt.plot(np.arange(Deas['dim']['nx']),Deas['Dmat'])
            elif (Deas['dim']['nx']==1): 
                plt.plot(np.arange(Deas['dim']['ny']),Deas['Dmat'])
            else:
                # X-Y
                plt.imshow(np.transpose(Deas['Dmat'][:,:,0]))                
                plt.xlabel('X')
                plt.ylabel('Y')
        elif (Deas['dim']['ny']==1):
            if (Deas['dim']['nz']==1):
                plt.plot(np.arange(Deas['dim']['nx']),Deas['Dmat'])
            elif (Deas['dim']['nx']==1): 
                plt.plot(np.arange(Deas['dim']['nz']),Deas['Dmat'])
            else:
                # X-Z
                plt.imshow(squeeze(Deas['Dmat'][:,0,:]))
                plt.xlabel('X')
                plt.xlabel('Z')
        elif (Deas['dim']['nx']==1):
            if (Deas['dim']['ny']==1):
                plt.plot(np.arange(Deas['dim']['nz']),Deas['Dmat'])
            elif (Deas['dim']['nz']==1): 
                plt.plot(np.arange(Deas['dim']['ny']),Deas['Dmat'])
            else:
                # Y-Z
                plt.imshow(squeeze(Deas['Dmat'][0,:,:]))
                plt.xlabel('Y')
                plt.xlabel('Z')
        else:
            plot_3d_pyvista(Deas['Dmat'])
    else:
        # scatter plot
        print('EAS scatter plot not yet implemented')        
        
        
    
def marg1D(O, plot=1, hardcopy=0, hardcopy_filename='marg1D'):
    '''Plot 1D marginal probabilities from realizations and compares to the
    1D marginal from the training image
    
    Paramaters
    ----------
    O : mpslib object
        
    plot : int (def=0)
        plot the output
        
        
    Output
    ------
    O.marg1D_sim : np.array [nr,ncat]
    O.marg1D_ti : np.array [ncat]
    
    '''
    import numpy as np
    import matplotlib.pyplot as plt
    
    
    #%%
    #D = np.array(O.sim)
    #cat = np.sort(np.unique(O.ti))
    D = np.array(O.sim)
    cat = np.sort(np.unique(O.ti))
    
    ncat = len(cat)
    dim = D.shape 
    dim_xyz = dim[1:4]
    nr=dim[0]
    #H = np.zeros(dim_xyz)
    #P = np.zeros((ncat,dim_xyz[0],dim_xyz[1],dim_xyz[2]))
    
    #%% 1D marginal stats
    marg1D=[]
    for ir in range(nr):
        c=np.zeros(ncat)
        for icat in range(ncat):
            c[icat]=np.count_nonzero(O.sim[ir]==cat[icat])
            p = c / np.sum(c)
        marg1D.append(p)
    #%%                
    O.marg1D_sim = np.array(marg1D)                
    u, c = np.unique(O.ti, return_counts = True)        
    p_ti = c / np.sum(c)        
    O.marg1D_ti = p_ti                
    
    
    if (plot):
        plt.figure(1)
        plt.clf()
        plt.hist(O.marg1D_sim)
        plt.plot(O.marg1D_ti,np.zeros(len(O.marg1D_ti)),'*', markersize=50)
        plt.xlabel('1D marginal Probability of category form simulations and ti')
        if (hardcopy):
            plt.savefig(hardcopy_filename)
        
        plt.figure(2)
        plt.clf()
        for icat in range(ncat):
            plt.plot(O.marg1D_sim[:,icat], label='Cat=%d'%(cat[icat]) )
        plt.legend()                
        tmp=O.marg1D_sim
        for icat in range(ncat):
            tmp[:,icat]=O.marg1D_ti[icat]
        tmp
        plt.plot(tmp, 'k-')
        plt.xlabel('Realization number')
        plt.ylabel('Porb(cat|realization)')
        plt.show()
        if (hardcopy):
            plt.savefig(hardcopy_filename+'_2')

    return True

    
    #%% Probability map
    #for icat in range(ncat):
        
    
            
        