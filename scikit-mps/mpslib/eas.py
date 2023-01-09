#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr 27 16:06:14 2017

@author: tmeha

Examples

import eas;
import matplotlib.pyplot as plt;

# Get the JURA data
import urllib.request
urllib.request.urlretrieve('https://github.com/cultpenguin/mGstat/raw/master/examples/data/jura/prediction.dat', 'prediction.dat')

# Read the JURA data
file_eas='prediction.dat';
Oeas = eas.read(file_eas) 

i_show=5;
cm = plt.cm.get_cmap('RdYlBu')
sc=plt.scatter(Oeas['D'][:,0],Oeas['D'][:,1],s=8*Oeas['D'][:,i_show],c=Oeas['D'][:,i_show], cmap=cm)
plt.xlabel(Oeas['header'][0])
plt.ylabel(Oeas['header'][1])
plt.title(Oeas['header'][i_show])
plt.colorbar(sc);
plt.show();

"""
import numpy as np
import os
debug_level=0

def read(filename='eas.dat', nanval=-997799):
    '''
    eas = eas.read(filename): Reads an EAS/GSLIB formatted file and outputs a dictionary
        eas['D']: The data (2D numpy array)
        eas['Dmat']: The data converted to a number of of size [nx,ny,nz] ONLY IF FIRST LINE CONTAINS DIMENSION
        eas['title']: Title of EAS data. Can contained the dimension, e.g. '20 30 1'
        eas['n_cols']: number of columns of data
        eas['header']: Header string of length n_cols    
    '''
    
    
    if not (os.path.isfile(filename)):
        print("Filename:'%s', does not exist" % filename)
    
    
    file = open(filename, "r")
    if (debug_level > 0):
        print("eas: file ->%20s" % filename)

    eas = {}
    eas['title'] = (file.readline()).strip('\n')

    if (debug_level > 0):
        print("eas: title->%20s" % eas['title'])

    dim_arr = eas['title'].split()
    if len(dim_arr) == 3:
        eas['dim'] = {}
        eas['dim']['nx'] = np.int16(dim_arr[0])
        eas['dim']['ny'] = np.int16(dim_arr[1])
        eas['dim']['nz'] = np.int16(dim_arr[2])

    eas['n_cols'] = np.int16(file.readline())
    
    eas['header'] = []
    for i in range(0, eas['n_cols']):
        # print (i)
        h_val = (file.readline()).strip('\n')
        eas['header'].append(h_val)

        if (debug_level>1):
            print("eas: header(%2d)-> %s" % (i,eas['header'][i]))

    file.close()

    try:
        eas['D'] = np.genfromtxt(filename, skip_header=2+eas['n_cols'])
        if (debug_level>1):
            print("eas: Read data from %s" % filename)
    except:
        print("eas: COULD NOT READ DATA FROM %s" % filename)
        

    # add NaN values
    try:
        eas['D'][eas['D']==nanval]=np.nan        
    except:
        print("eas: FAILED TO HANDLE NaN VALUES (%d(" % nanval)
    
    # If dimensions are given in title, then convert to 2D/3D array
    if "dim" in eas:
        if (eas['dim']['nz']==1):
            eas['Dmat']=eas['D'].reshape((eas['dim']['ny'],eas['dim']['nx']))
        elif (eas['dim']['nx']==1):
            eas['Dmat']=np.transpose(eas['D'].reshape((eas['dim']['nz'],eas['dim']['ny'])))
        elif (eas['dim']['ny']==1):
            eas['Dmat']=eas['D'].reshape((eas['dim']['nz'],eas['dim']['nx']))
        else:
            eas['Dmat']=eas['D'].reshape((eas['dim']['nz'],eas['dim']['ny'],eas['dim']['nx']))
            

        eas['Dmat']=eas['D'].reshape((eas['dim']['nx'],eas['dim']['ny'],eas['dim']['nz']))
        eas['Dmat']=eas['D'].reshape((eas['dim']['nz'],eas['dim']['ny'],eas['dim']['nx']))
      
        eas['Dmat'] = np.transpose(eas['Dmat'], (2,1,0))
         
        if (debug_level>0):
            print("eas: converted data in matrixes (Dmat)")

    eas['filename']=filename

    return eas

    
def write(D = np.empty([]), filename='eas.dat', title='eas title', header=[]):
    '''
    eas.write(D,filename): writes an EAS/GSLIB formatted file from an 1D-3D numpy array
        D: 1D to 3D numpy array
        filename: output eas file
    '''
    if (D.ndim==0): 
            print("eas: no data to write - exiting")
            return 0
    
    if (D.ndim==1):
        ncols=1
        ndata=len(D)
    else:    
        (ndata,ncols) = D.shape
            #(ncols,ndata) = D.shape; 

    eas={}
    eas['D'] = D
    eas['n_cols'] = ncols
    eas['title'] = title
    eas['header'] = []
    for i in range(ncols):
        if i<len(header):
            eas['header'].append(header[i])
        else:
            eas['header'].append('col%d' % i)

    if (debug_level > 0):
        print("eas: writing data to %s, ncolumns=%d, ndata=%d." % (filename, ncols, ndata))
    write_dict(eas,filename)

    return eas

def write_mat(D = np.empty([]), filename='eas.dat'):
    '''
    eas.write_mat(eas,filename): writes an EAS/GSLIB formatted file from a dictionary
        eas['D']: The data (1D/2D/3D numpy array)
        eas['title']: Title of EAS data. Can contained the dimension, e.g. '20 30 1'
        eas['n_cols']: number of columns of data
        eas['header']: Header string of length n_cols    
        filename: EAS filename
    '''
    if (D.ndim==0): 
            print("eas: no data to write - exiting")
            return 0
    
    if (D.ndim==1):
        ny=1
        nx=len(D)
    elif (D.ndim==2): 
        nz=1
        (nx,ny) = D.shape
        D = np.transpose(D)
    else:
        (nx,ny,nz) = D.shape
        D = np.transpose(D, (2,1,0))
        
    title = ("%d %d %d" % (nx,ny,nz) )
    if (debug_level > 0):
        print("eas: writing matrix to %s " % filename)
        print("eas: (nx,ny,nz)=(%d,%d,%d) " % (nx,ny,nz) )
        print("eas: title=%s"%title)

    eas={}
    eas['dim'] = {}
    eas['dim']['nx'] = nx
    eas['dim']['ny'] = ny    
    eas['dim']['nz'] = nz        
    eas['n_cols'] = 1 
    eas['title'] = title
    eas['header'] = []
    eas['header'].append('Header')
    
    eas['D'] = D.flatten();

    write_dict(eas,filename)

    return eas

def write_dict(eas,filename='eas.dat'):
    """
    :param eas: eas dictionary as read using eas.read
    :param filename: filename
    :return: 1

    Example:
    Deas = eas.read('data.gslib')
    eas.write(Deas,'data2.gslib')
    """
    if (eas['D'].ndim==1):
        n_data = len(eas['D'])
        n_cols=1;
    else:
        (n_data,n_cols) = eas['D'].shape
    
    
    full_path = os.path.join(filename)
    file = open(full_path, 'w')
    
    # print header
    file.write('%s\n' % eas['title'])
    file.write('%d\n' % eas['n_cols'])
    for i in range(0, eas['n_cols']):
        file.write('%s\n' % eas['header'][i])
        
        
    if n_cols == 1:
        for ii in np.arange(n_data):
            file.write('%g\n' % eas['D'][ii])
    else:
        #for ii in np.arange(nreal):
        #    f.write('%s%d\n' % ('real', ii))

        for ii in np.arange(n_data):
            for jj in np.arange(n_cols):
                file.write('%12g' % eas['D'][ii, jj])
            file.write('\n')
    file.close();   
    return 1
    

