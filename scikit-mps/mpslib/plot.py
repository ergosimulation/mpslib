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



def plot_3d_vtk(Data, slice=0, filename=''):
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


