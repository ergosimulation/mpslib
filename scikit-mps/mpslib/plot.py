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



def plot_3d_vtk(Data, slice=0, origin=(0,0,0), spacing=(1,1,1), filename='', ):
    '''
    plot 3D sube using 'vtki' 
    '''
    import numpy as np 
    
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
    grid.origin = origin # The bottom left corner of the data set
    grid.spacing = spacing # These are the cell sizes along each axis
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




#%%
def plot_3d_mpl(Data):
    '''
    Plot 3D numpy array with matplob lib
    -> currently not very useulf
    '''
    import matplotlib.pyplot as plt
    import numpy as np

    # This import registers the 3D projection, but is otherwise unused.
    from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import

    print('USE THIS WITH CAUTION.. ONLY SUITABLE FOR SMALLE 3D MODELS. USE the VTKi interface instead')

    cat0 = Data<.5
    cat1 = Data>=.5

    # set the colors of each object
    colors = np.empty(Data.shape, dtype=object)
    colors[cat0] = 'white'
    colors[cat1] = 'red'
    
    # and plot everything
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    ax.voxels(Data, facecolors=colors, edgecolor='k')
    
    plt.show()


def plot_3d_real(O,ireal=0,slice=0):
    '''
    plot 3D relization using vtki
    O [MPSlib object]
    ireal [int] number of realizations
    slice [int] =1, slice volume
                =0, 3D cube
    '''
    
    plot_3d_vtk(O.sim[ireal], slice=slice, origin=O.par['origin'], spacing=O.par['grid_cell_size'])
    
    
    
    