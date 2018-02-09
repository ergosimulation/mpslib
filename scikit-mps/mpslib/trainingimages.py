# -*- coding: utf-8 -*-
"""
Created on Wed Jan 24 19:36:26 2018

@author: thoma
"""

import os.path
import numpy as np
from . import eas
#import urllib.request
try:
#    from urllib.request import urlopen
     from urllib.request import urlretrieve as urlretrieve
except ImportError:
#    from urllib2 import urlopen
    from urllib import urlretrieve as urlretrieve

def get_remote(url = 'http://www.trainingimages.org/uploads/3/4/7/0/34703305/ti_strebelle.sgems',local_file = 'ti.dat'):
    if not (os.path.exists(local_file)):
        print('Beginning download of ' + url + ' to ' + local_file)
        urlretrieve(url, local_file)
        #urllib.request.urlretrieve(url, local_file)

    print('Loading ' + local_file)
    D = eas.read(local_file)
    return D

def coarsen_2d_ti(Dmat,di=2):
    ny, nx = Dmat.shape
    ndim3 = di * di
    x = np.arange(nx)
    y = np.arange(ny)
    ix = x[0:(nx - di):di]
    iy = y[0:(ny - di):di]
    nx2 = ix.size
    ny2 = iy.size
    TI = np.zeros((ny2, nx2, ndim3))
    l = -1;
    for j in range(di):
        for k in range(di):
            l = l + 1
            TI_small = Dmat[(0 + j)::di, (0 + k)::di]
            TI[::, ::, l] = TI_small[0:ny2, 0:nx2]
    return TI


def strebelle(di=1, coarse3d=0):
    local_file = 'ti_strebelle.dat';
    url = 'http://www.trainingimages.org/uploads/3/4/7/0/34703305/ti_strebelle.sgems';
    Deas = get_remote(url,local_file)
    TI = Deas['Dmat']
    if di>1:
        if coarse3d==0:
            Dmat = TI
            TI = Dmat[::di,::di]
        else:
            Dmat = TI
            TI = coarsen_2d_ti(Dmat, di)

    return TI, local_file


def lines(di=1,coarse3d=0):
    local_file = 'ti_lines.dat';
    url = 'http://www.trainingimages.org/uploads/3/4/7/0/34703305/ti_lines_arrows.sgems';
    Deas = get_remote(url,local_file)
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
    url = 'http://www.trainingimages.org/uploads/3/4/7/0/34703305/ti_stonewall.sgems';
    Deas = get_remote(url,local_file)
    Dmat = Deas['Dmat']
    return Dmat, local_file

def bangladesh(di=1,coarse3d=0):
    local_file = 'ti_bangladesh.dat';
    url = 'http://trainingimages.org/uploads/3/4/7/0/34703305/bangladesh.sgems';
    Deas = get_remote(url,local_file)
    TI = Deas['Dmat']
    if di > 1:
        if coarse3d == 0:
            Dmat = TI
            TI = Dmat[::di, ::di]
        else:
            Dmat = TI
            TI = coarsen_2d_ti(Dmat, di)

    return TI, local_file

def maze():
    local_file = 'ti_maze.dat';
    url = 'https://raw.githubusercontent.com/cultpenguin/mGstat/master/ti/maze.gslib';
    Deas = get_remote(url,local_file)
    Dmat = Deas['Dmat']
    return Dmat, local_file




def checkerboard(nx=40, ny=40, cellsize=4):

    import numpy as np
    TI=np.kron([[1, 0] * cellsize, [0, 1] * cellsize] * cellsize, np.ones((ny, nx)))

    local_file = 'ti_checkerboard.dat'
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
    return TI, local_file
