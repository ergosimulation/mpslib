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

def plot(D, force_3d=0, slice=0, threshold=(), origin=(0,0,0), spacing=(1,1,1) ,**kwargs):
    '''Plot matrix in 2D (matplotlib) or 3D (pyvista)

    Parameters
    ----------
    
    '''
    plotgrid = kwargs.get('use_plotgrid',True)
    use_colorbar = kwargs.get('use_colorbar',True)
    title = kwargs.get('title',"")
    filename = kwargs.get('filename',"")
    cmap = kwargs.get('cmap',"viridis")
    
    if (D.ndim == 3)|(force_3d==1):
        plot_3d(D, origin=origin, spacing=spacing, **kwargs)
    else:
        plot_2d(D, origin=origin, spacing=spacing, **kwargs)
        

def plot_2d(Data, origin=(0,0,0), spacing=(1,1,1), **kwargs ):
    
    plotgrid = kwargs.get('use_plotgrid',True)
    use_colorbar = kwargs.get('use_colorbar',True)
    title = kwargs.get('title',"")
    filename = kwargs.get('filename',"")
    cmap = kwargs.get('cmap',"viridis")
    show = kwargs.get('show',True)
    grid_minor = kwargs.get('grid_minor',False)
    plot_origin = kwargs.get('plot_origin','lower')
    #print("Title=%s" % (title))
    
    Data=np.squeeze(Data)
    nx, ny = Data.shape
    
    extent = [ origin[0]+-0.5*spacing[0] ,  origin[0]+nx*spacing[0]+0.5*spacing[0] , origin[1]-0.5*spacing[1] ,  ny*spacing[1]+origin[1]+0.5*spacing[1] ]
    #print(extent)
    
    im=plt.imshow(np.transpose(Data), cmap=cmap, extent=extent, interpolation='None', origin=plot_origin)
    if len(filename)>0:
        plt.savefig(filename)
    
    if (use_colorbar):
        plt.colorbar(im, fraction=0.046, pad=0.04)
    if (plotgrid):
        if (grid_minor):
            ax=plt.gca()
            ax.set_xticks(np.arange(extent[0], extent[1], spacing[0]), minor=True)
            ax.set_yticks(np.arange(extent[2], extent[3], spacing[1]), minor=True)
            plt.grid(which='minor', color='w', linestyle='-', linewidth=1)
        else:
            plt.grid
    if len(title)>0:
        plt.title(title)
    if (show):
        plt.show()
    
    

def plot_3d(Data, origin=(0,0,0), spacing=(1,1,1), **kwargs ):
    '''
    plot 3D cube using 'pyvista' 
    '''
    #import numpy as np 
    #from pyvistaqt import BackgroundPlotter as Plotter    
    from pyvista import Plotter as Plotter    
    
    title = kwargs.get('title',"")
    show_edges = kwargs.get('show_edges',False)
    opacity = kwargs.get('opacity',1)
    #plotgrid = kwargs.get('use_plotgrid',True)
    use_colorbar = kwargs.get('use_colorbar',True)
    filename = kwargs.get('filename',"")
    cmap = kwargs.get('cmap',"viridis")
    slice = kwargs.get('slice',0)
    plotgrid = kwargs.get('plotgrid',1)
    threshold = kwargs.get('threshold',())
    add_points = kwargs.get('add_points','False')
    show_bounds = kwargs.get('show_bounds','True')
    show_axes = kwargs.get('show_axes','True')
    show_grid = kwargs.get('show_grid','False')
    
    
    plot = Plotter() # interactive
    
    # create uniform grid 
    if (plotgrid==1)|(slice==1):
        grid = numpy_to_pvgrid(Data, origin=origin, spacing=spacing)
    
    if (plotgrid==1)&(slice==0):        
        plot.add_mesh(grid, cmap=cmap, show_edges=show_edges, opacity=opacity)
    
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
        
    if (add_points):
        plot.add_points(grid.points, color='red',
              point_size=2)    
    if (show_grid):
        plot.show_grid()
    if (show_bounds):
        plot.show_bounds()
    if (show_axes):
        plot.show_axes()
    if (len(title)>0):
        plot.add_text(title)
    
    plot.show()



#### Plot reals



def plot_reals(O, nshow=4, **kwargs):
    '''Plot realizations in 2D (matplotlib) or 3D (pyvista)

    Parameters
    ----------
    '''
    
    cmap = kwargs.get('cmap',"viridis")

    if O.sim is not None:
    
        force_3d = kwargs.get('force_3d',0)
        slice = kwargs.get('slice',0)
        #nshow = kwargs.get('nshow',4)


        D=np.squeeze(O.sim[0])
        if (D.ndim == 3)|(force_3d==1):
            plot_3d_reals(O, nshow=nshow,  slice=slice, origin=O.par['origin'], spacing=O.par['grid_cell_size'], cmap=cmap)
        else:
            plot_2d_reals(O, nshow=nshow, cmap=cmap)

    else:
        print('No realizations to plot')

def plot_2d_reals(O, nshow=4, **kwargs):

    cmap = kwargs.get('cmap',"viridis")
    nshow=np.min([len(O.sim),nshow])

    nsp=np.int8(np.ceil(np.sqrt(nshow)))    

    for i in range(nshow):
        plt.subplot(nsp,nsp,i+1)

        D=np.squeeze(O.sim[i])
        plot_2d(D,  origin=O.par['origin'], spacing=O.par['grid_cell_size'], show=False, title='Real #%d' % (i+1), use_colorbar=False, cmap=cmap)

    plt.show()



def plot_3d_reals(O, nshow=4):
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



######## PLOT EAS
    
#%%
def plot_eas(Deas):
    '''
    Plot data directly form EAS
    '''
    import matplotlib.pyplot as plt
    import numpy as np
    
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
                plt.imshow(np.squeeze(Deas['Dmat'][:,0,:]))
                plt.xlabel('X')
                plt.xlabel('Z')
        elif (Deas['dim']['nx']==1):
            if (Deas['dim']['ny']==1):
                plt.plot(np.arange(Deas['dim']['nz']),Deas['Dmat'])
            elif (Deas['dim']['nz']==1): 
                plt.plot(np.arange(Deas['dim']['ny']),Deas['Dmat'])
            else:
                # Y-Z
                plt.imshow(np.squeeze(Deas['Dmat'][0,:,:]))
                plt.xlabel('Y')
                plt.xlabel('Z')
        else:
            plot_3d(Deas['Dmat'])
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
        
    
            
        