'''
mpslib_parallel:
An example of performing simulation in parallel
'''
import mpslib as mps
import time
import numpy as np
import os
import copy


#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_snesim_tree', simulation_grid_size=(150,130,1), origin=(0,0,0))

#O.par['n_threads']=30; # 10

O.par['n_real']=50
O.par['n_cond']=9
d_hard = np.array([[25,10,0,0],[28,13,0,1]])
# Set training image
O.ti = mps.trainingimages.checkerboard2()[0]
O.ti = mps.trainingimages.strebelle()[0]
#O.plot_ti()
O.d_hard = d_hard
#O.delete_local_files() # Make sure no hard/soft data are conditioned to
O.remove_gslib_after_simulation=0;


# Make sure the TI is set as a variable
#if os.path.isfile(O.par['ti_fnam']):
#    E=mps.eas.read(O.par['ti_fnam'])
#    O.ti=E['Dmat']
    
    
#%% SERIAL    
'''
Oserial = copy.deepcopy(O)
t0=time.time()
Oserial.run()
t1=time.time()-t0
print('Simulation time sequential: %4.2fs' % t1)    
'''
#%% PARALLEL    
# NEXT LINE NEEDED IN WINDOWS TO PREVENT INFINITE LOOP
print('in script: __name__ = %s' % __name__)
if (os.name=='nt'):
    print('Do not run this in a script as it will cause an infinite loop in windows')
    print('Instead, run it intearctively in ipython.')
    input("Press Enter to continue...")
O.par['n_threads']=-1# USE ALL
t0=time.time()
if __name__ == '__main__':
    Oall = O.run_parallel()
t2=time.time()-t0

print('Simulation time parallel:   %4.2fs' % t2)    



#%% PARALLEL    
# NEXT LINE NEEDED IN WINDOWS TO PREVENT INFINITE LOOP
print('in script: __name__ = %s' % __name__)
if (os.name=='nt'):
    print('Do not run this in a script as it will cause an infinite loop in windows')
    print('Instead, run it intearctively in ipython.')
    input("Press Enter to continue...")
O.par['n_threads']=4# USE 4
t0=time.time()
if __name__ == '__main__':
    Oall = O.run_parallel()
t3=time.time()-t0

print('Simulation time parallel:   %4.2fs' % t3)    


#%%

#emean, evar = O.plot_etype()
#mps.plot.plot_3d_vtk(emean[:,:,np.newaxis])
