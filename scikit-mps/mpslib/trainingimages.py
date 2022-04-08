# -*- coding: utf-8 -*-
"""
Created on Wed Jan 24 19:36:26 2018

@author: thoma
"""

import os
import numpy as np
from . import eas
from . import plot

#import urllib.request
try:
#    from urllib.request import urlopen
     from urllib.request import urlretrieve as urlretrieve
except ImportError:
#    from urllib2 import urlopen
    from urllib import urlretrieve as urlretrieve

def get_remote(url = 'http://www.trainingimages.org/uploads/3/4/7/0/34703305/ti_strebelle.sgems',local_file = 'ti.dat', is_zip=0, filename_in_zip=''):
    #import os    
    
    if (is_zip==1):
        local_file_zip = local_file + '.zip'
    
    if not (os.path.exists(local_file)):
        if (is_zip==1):
            import zipfile
            # download zip file
            print('Beginning download of ' + url + ' to ' + local_file_zip)
            urlretrieve(url, local_file_zip)
            # unzip file
            print('Unziping %s to %s' % (local_file_zip,local_file))
            zip_ref = zipfile.ZipFile(local_file_zip, 'r')
            zip_ref.extractall('.')
            zip_ref.close()
            # rename unzipped file            
            if len(filename_in_zip)>0:
                os.rename(filename_in_zip,local_file)
            
            
        else:
            print('Beginning download of ' + url + ' to ' + local_file)
            urlretrieve(url, local_file)
        
        
    return local_file
    
def coarsen_2d_ti(Dmat,di=2):
    '''
    Takes a 2D trainin image and makes it coarser, by constructing a 3D TI 
    based on all coarsened 2D images
    '''
    
    nx, ny, nz = Dmat.shape
    ndim3 = di * di    
    x = np.arange(nx)
    y = np.arange(ny)
    ix = x[0:(nx - di):di]
    iy = y[0:(ny - di):di]
    nx2 = len(ix)
    ny2 = len(iy)
    TI = np.zeros( (nx2, ny2, nz, ndim3))
    l = -1;
    for j in range(di):
        for k in range(di):
            l = l + 1
            
            TI_small = Dmat[(0 + j)::di, (0 + k)::di, 0]
            TI[:, :, 0,l] = TI_small[0:nx2, 0:ny2]
            
    TI=np.squeeze(TI)
    return TI


def ti_list(show=1):
    ti_name=[]
    ti_desc=[]
    
    ti_name.append('checkerboard')
    ti_desc.append('2D checkerboard')

    ti_name.append('checkerboard2')
    ti_desc.append('2D checkerboard - alternative')

    ti_name.append('strebelle')
    ti_desc.append('2D discrete channels from Strebelle')
    
    ti_name.append('lines')
    ti_desc.append('2D discrete lines')

    ti_name.append('stones')
    ti_desc.append('2D continious stones')
    
    ti_name.append('bangladesh')
    ti_desc.append('2D discrete Bangladesh')

    ti_name.append('maze')
    ti_desc.append('2D discrete maze')

    ti_name.append('rot90')
    ti_desc.append('3D rotation 90')

    ti_name.append('horizons')
    ti_desc.append('3D continious horizons')

    ti_name.append('fluvsim')
    ti_desc.append('3D discrete fluvsim')
    
    if (show==1):
        print('Available training images:')
        for i in range(len(ti_name)):
            print('%15s - %s' % (ti_name[i],ti_desc[i]) )
    
    
    return ti_name, ti_desc


def ti_plot_all():
    '''
    plot all training images
    '''
    
    import sys
    this_mod = sys.modules[__name__]

    TI_fnames,d=ti_list(1)

    for i in range(len(TI_fnames)):
        print('Loading %s' % TI_fnames[i])
        TI, TI_fname = getattr(this_mod,TI_fnames[i])()
        print(TI.shape)
        plot.plot_3d(TI,1)


'''
The training images
'''
def fluvsim():
    local_file = 'ti_fluvsim.dat';
    filename_in_zip='ti_fluvsim_big_channels3D.SGEMS'
    #url = 'http://www.trainingimages.org/uploads/3/4/7/0/34703305/ti_fluvsim_big_channels3d.zip';
    url = 'https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/ti_fluvsim_big_channels3D.zip';
    is_zip=1;
    local_file = get_remote(url,local_file,is_zip=is_zip, filename_in_zip=filename_in_zip)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    
    return TI, local_file

def horizons():
    local_file = 'ti_horizons.dat';
    url='https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/TI_horizons_continuous.SGEMS'
    #filename_in_zip='TI_horizons_continuous.SGEMS'
    is_zip=0;
    local_file = get_remote(url,local_file,is_zip=is_zip)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    
    return TI, local_file


def rot90():
    local_file = 'ti_tot90.dat';
    url='https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/checker_rtoinvariant_90.zip'
    filename_in_zip='checker_rtoinvariant_90.SGEMS'
    is_zip=1;
    local_file = get_remote(url,local_file,is_zip=is_zip, filename_in_zip=filename_in_zip)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    
    return TI, local_file



def strebelle(di=1, coarse3d=0):
    
    url = 'https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/ti_strebelle.sgems';
    local_file = get_remote(url,'ti_strebelle.dat')
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    
    local_file = 'ti_strebelle_%d.dat' % (di);
    
    
    TI = Deas['Dmat']
    if di>1:
        if coarse3d==0:
            Dmat = TI
            TI = Dmat[::di,::di, :]
        else:
            Dmat = TI
            TI = coarsen_2d_ti(Dmat, di)
    
    eas.write_mat(TI,local_file)

    return TI, local_file


def lines(di=1,coarse3d=0):
    local_file = 'ti_lines.dat';
    url = 'https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/ti_lines_arrows.sgems';
    get_remote(url,local_file)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']

    if di > 1:
        local_file = "ti_lines_%d.dat" % di
        if coarse3d == 0:
            Dmat = TI
            TI = Dmat[::di, ::di]
        else:
            Dmat = TI
            TI = coarsen_2d_ti(Dmat, di)

    return TI, local_file


def stones():
    local_file = 'ti_stones.dat';
    url = 'https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/ti_stonewall.sgems';
    get_remote(url,local_file)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    return TI, local_file

def bangladesh(di=1,coarse3d=0):
    local_file = 'ti_bangladesh.dat';
    url = 'https://github.com/GAIA-UNIL/trainingimages/raw/master/MPS_book_data/Part2/bangladesh.sgems';
    get_remote(url,local_file)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    
    if di > 1:
        if coarse3d == 0:
            Dmat = TI
            TI = Dmat[::di, ::di, ::di]
        else:
            Dmat = TI
            TI = coarsen_2d_ti(Dmat, di)

    return TI, local_file

def maze():
    local_file = 'ti_maze.dat';
    url = 'https://raw.githubusercontent.com/cultpenguin/mGstat/master/ti/maze.gslib';
    get_remote(url,local_file)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    return TI, local_file

def kasted(dx=50):
    local_file = 'ti_maze.dat';
    if dx==50:
        url = 'https://raw.githubusercontent.com/ergosimulation/mpslib/master/data/kasted/kasted_ti_dx50.dat';
        local_file = 'ti_kasted_dx50.dat';
    elif dx==100:
        url = 'https://raw.githubusercontent.com/ergosimulation/mpslib/master/data/kasted/kasted_ti_dx100.dat';
        local_file = 'ti_kasted_dx100.dat';
    elif dx==200:
        url = 'https://raw.githubusercontent.com/ergosimulation/mpslib/master/data/kasted/kasted_ti_dx200.dat';
        local_file = 'ti_kasted_dx200.dat';
    elif dx==400:
        url = 'https://raw.githubusercontent.com/ergosimulation/mpslib/master/data/kasted/kasted_ti_dx400.dat';
        local_file = 'ti_kasted_dx400.dat';
    
    get_remote(url,local_file)
    Deas = eas.read(local_file)
    TI = Deas['Dmat']
    return TI, local_file






def checkerboard(nx=40, ny=40, cellsize=4):

    import numpy as np
    TI=np.kron([[1, 0] * cellsize, [0, 1] * cellsize] * cellsize, np.ones((nx,ny)))
    TI=TI[:,:,np.newaxis]

    local_file = 'ti_checkerboard.dat'
    
    eas.write_mat(TI,local_file)

    Deas = eas.read(local_file)
    TI = Deas['Dmat']

    
    return TI, local_file

def checkerboard2(nx=40, ny=50, cell_x=8, cell_y=4, cell_2=10):
    import numpy as np
    TI=np.zeros((ny,nx))

    for ix in range(nx):             # Note that i ranges from 0 through 7, inclusive.
        for iy in range(ny):           # So does j.
            if (ix%cell_x < (cell_x/2))==(iy%cell_y < (cell_y/2)): # The checkerboard
                TI[iy, ix] = 0
            else:
                TI[iy,ix]=1

            if (ix%(cell_2+1) < (cell_2/2))&(iy%(cell_2+1) < (cell_2/2)): # some more 'checks' a little off
                TI[iy, ix] = 2

            if (ix+iy)%cell_x==0:
                TI[iy, ix] = 0

    local_file = 'ti_checkerboard2_%d_%d__%d_%d__%d.dat' % (nx,ny,cell_x,cell_y,cell_2) # a diagonal
    
    eas.write_mat(TI,local_file)

    Deas = eas.read(local_file)
    TI = Deas['Dmat']


    
    return TI, local_file
