'''
ex_hard_as_soft:
The simplest example of running MPSliv from python
'''
import mpslib as mps
import matplotlib.pyplot as plt
import numpy as np
plt.ion()

#%% load TI
EAS=mps.eas.read('ti.dat')
TI_filename = EAS['filename']
TI=EAS['Dmat']
plt.imshow(TI)
plt.title(TI_filename)
plt.show()
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

O.par['n_real']=150
O.par['shuffle_simulation_grid']=2 # '2' indicates using a preferential simulation path
O.par['n_max_ite']=10000000;
O.par['n_max_cpd_count']=20; # Direct sampling style
O.par['n_cond']=25;
O.par['n_cond_soft']=3;
O.par['soft_data_fnam']='d_soft.dat'

if hasattr(O, 'd_soft'):
    delattr(O,'d_soft')        
if hasattr(O, 'd_hard'):
    delattr(O,'d_hard')        


m_arr = []

for iex in range(5):
    if (iex==0):
        O.d_soft = d_soft
        O.par['n_cond_soft']=1;
        txt='Soft data, co-located only'
    if (iex==1):
        O.d_soft = d_soft
        O.par['n_cond_soft']=3;
        txt='Soft data, 3 non-co-located'
    elif (iex==2):        
        O.d_soft = d_soft_hard    
        O.par['n_cond_soft']=1;
        txt='Soft as HARD data, colocated only'
    elif (iex==3):        
        O.d_soft = d_soft_hard
        O.par['n_cond_soft']=3;
        txt='Soft as HARD data, 3 non-co-located'
    elif (iex==4):    
        if hasattr(O, 'd_soft'):
            delattr(O,'d_soft')
        O.d_hard = d_hard
        txt='HARD data'
        
    O.run()
    m_arr.append(np.mean(O.sim, axis=0))
    #Plot the results
    O.plot_etype(title_txt=txt)
    plt.savefig('hard_as_soft_ex%d' % iex)
