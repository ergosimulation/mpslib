'''
ex_hard_as_soft:
The simplest example of running MPSliv from python
'''
import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np
import copy
#plt.ion()
plt.ioff()

#%% load TI
EAS=mps.eas.read('ti.dat')
TI_filename = EAS['filename']
TI=EAS['Dmat']

#plt.imshow(TI)
#plt.title(TI_filename)
#plt.show()
#%%

#%% hard data

d_hard  =np.array([[ 6.     , 14.     ,  0.     ,  1],
                   [13.     , 16.     ,  0.     ,  1],
                   [ 3.     , 14.     ,  0.     ,  1]])

#%% The soft data 
# The soft data
d_soft  =np.array([[ 6.     , 14.     ,  0.     ,  0.14375,  0.85625],
                   [13.     , 16.     ,  0.     ,  0.14375,  0.85625],
                   [ 3.     , 14.     ,  0.     ,  0.14375,  0.85625]])

# The soft data, but coded as 'hard' data
d_soft_hard = np.array([[ 6., 14.,  0.,  0.,  1.],
                        [13., 16.,  0.,  0.,  1.],
                        [ 3., 14.,  0.,  0.,  1.]])        



#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
nx=20
ny=30
nz=1
x0=0
y0=0
z0=0
O=mps.mpslib(method='mps_genesim', 
             simulation_grid_size=np.array([nx, ny, nz]), 
             origin=np.array([x0, y0, z0]))
O.delete_local_files() # Make sure no hard/soft data are conditioned to


# Use soft data

O.par['n_real']=100
O.par['shuffle_simulation_grid']=2 # '2' indicates using a preferential simulation path
O.par['n_max_ite']=10000000;
O.par['n_max_cpd_count']=20; # Direct sampling style
O.par['n_cond']=16;
O.par['n_cond_soft']=0;

O.par['max_search_radius']=100;
O.par['max_search_radius_soft']=100;

O.par['soft_data_fnam']='d_soft.dat'

Omul=[]

Omul.append(copy.deepcopy(O))
Omul[-1].d_soft = d_soft
Omul[-1].par['n_cond_soft']=0;
Omul[-1].txt='Soft data, co-located only'

Omul.append(copy.deepcopy(O))
Omul[-1].d_soft = d_soft
Omul[-1].par['n_cond_soft']=3;
Omul[-1].txt='Soft data, 3 non-co-located'



Omul.append(copy.deepcopy(O))
Omul[-1].d_soft = d_soft_hard    
Omul[-1].par['n_cond_soft']=0;
Omul[-1].txt='Soft as HARD data, colocated only'


Omul.append(copy.deepcopy(O))
Omul[-1].d_soft = d_soft_hard
Omul[-1].par['n_cond_soft']=3;
Omul[-1].txt='Soft as HARD data, 3 non-co-located'

Omul.append(copy.deepcopy(O))
Omul[-1].d_hard = d_hard
Omul[-1].txt='HARD data'

nO=len(Omul)

m_all = []
for ipath in [0,1,2]:
    m_arr = []
    plt.figure()
    for iex in range(nO):
        if hasattr(O, 'd_soft'):
            delattr(O,'d_soft')        
        if hasattr(O, 'd_hard'):
            delattr(O,'d_hard')        


        Omul[iex].parameter_filename='mps_%02d_ex%03d' % (ipath,iex)
        Omul[iex].par['shuffle_simulation_grid']=ipath
        
        Omul[iex].run()
        
        Omul[iex].delete_soft_data()
        Omul[iex].delete_hard_data()
        
        m_arr.append(np.mean(Omul[iex].sim, axis=0))
    
        plt.subplot(nO,1,iex+1)
        plt.title(Omul[iex].txt)
        plt.imshow(m_arr[-1], vmin=0, vmax=1)
    plt.savefig('hard_as_soft_path%d' % ipath)
    plt.show()
    m_all.append(m_arr)

