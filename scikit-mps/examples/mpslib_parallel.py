'''
mpslib_parallel:
An example of performing simulation in parallel
'''
import mpslib as mps
import time
import numpy as np
import os
import copy

'''
def run_unpack(args):
    Omul, txt = args
    print(txt)
    Omul.run()
    return Omul
'''
#%% Initialize the MPS object, using a specific algorithm (def='mps_snesim_tree')
O=mps.mpslib(method='mps_snesim_tree', simulation_grid_size=(50,30,1), origin=(0,0,0))
O.par['n_real']=100
O.par['n_cond']=9
d_hard = np.array([[25,10,0,0],[28,13,0,1]])
# Set training image
O.ti = mps.trainingimages.checkerboard2()[0]
O.ti = mps.trainingimages.strebelle()[0]
#O.plot_ti()
O.d_hard = d_hard
O.par['n_threads']=20;
#O.delete_local_files() # Make sure no hard/soft data are conditioned to

# Make sure the TI is set as a variable
if os.path.isfile(O.par['ti_fnam']):
    E=mps.eas.read(O.par['ti_fnam'])
    O.ti=E['Dmat']
    
#%% Run MPSlib using one thread
'''    
Omul=[]
for ithread in range(O.par['n_threads']):
    Omul.append(copy.deepcopy(O))    
    Omul[ithread].parameter_filename = '%s_%03d.txt' % (O.method,ithread)
    Omul[ithread].par['ti_fnam'] = 'ti_thread_%03d.dat' % ithread
    Omul[ithread].par['out_folder']='./thread%03d' % ithread
    if not (os.path.isdir(Omul[ithread].par['out_folder'])):
        os.mkdir(Omul[ithread].par['out_folder'])


#%%
if (O.par['n_threads']<1):
    Nthreads=20;
else:
    Nthreads = O.par['n_threads'];

real_per_thread= np.ceil(O.par['n_real']/Nthreads).astype(int)
print('parallel: using %d threads to simulate %d realizations' % (Nthreads,O.par['n_real']))
print('parallel: with up to %g relizations per thread' % real_per_thread)

#%%
Oall=[];
for ithread in range(Nthreads):

    OO=copy.deepcopy(O)
    OO.parameter_filename = '%s_%03d.txt' % (O.method,ithread)
    OO.par['ti_fnam'] = 'ti_thread_%03d.dat' % ithread
    if (ithread==(Nthreads-1)):
        # LAST THREAD
        OO.par['n_real'] = O.par['n_real'] - (Nthreads-1)*real_per_thread
    else:
        OO.par['n_real'] = real_per_thread
            
    OO.par['out_folder']='./thread%03d' % ithread
    if not (os.path.isdir(OO.par['out_folder'])):
        os.mkdir(OO.par['out_folder'])    
    Ocur=[]
    Ocur.append(OO)
    Ocur.append('TEST%03d' % ithread)
    Oall.append(Ocur)
'''   
    
#%% SERIAL    
#for ithread in range(len(Omul)):
#    Omul[ithread].run()
#    
    
    
O_all = O.run_parallel()

emean, evar = O.plot_etype()
    
mps.plot.plot_3d_vtk(emean[:,:,np.newaxis])


#%% PARALLEL
'''
from multiprocessing import Pool
from multiprocessing import cpu_count
#Ncpu = np.int(cpu_count()/2)
Ncpu = np.int(cpu_count())

if __name__ == '__main__':
    p = Pool(Ncpu)
    #Omul = p.map(run_unpack, Oall)
    Omul = p.map(mps.mpslib.run_unpack, O_all)
'''


    
#%%    
'''
O.x=Omul[0].x
O.y=Omul[0].y
O.z=Omul[0].z
for ithread in range(len(Omul)):
    if (ithread==0):
        O.sim = Omul[ithread].sim
    else:
        O.sim = O.sim + Omul[ithread].sim
        
print("N reals = %d" % (len(O.sim)))        
emean, evar = O.plot_etype()
    
mps.plot.plot_3d_vtk(emean[:,:,np.newaxis])

'''

'''

#%%
    
if not (os.path.isdir(O.par['out_folder'])):
    os.mkdir(O.par['out_folder'])

t0=time.time()
O.run()
t1=time.time()-t0
#O.plot_etype('One thread. t=%g s' % t1)


#%% Run MPSlib using one thread
O.par['n_threads']=1;
O.delete_local_files() # Make sure no hard/soft data are conditioned to
O.d_hard = d_hard
t0=time.time()
O.run()
t1=time.time()-t0
O.plot_etype('One thread. t=%g s' % t1)



#%% Run MPSlib using 4 thread
O.par['n_threads']=4;
O.delete_local_files() # Make sure no hard/soft data are conditioned to
O.d_hard = d_hard
t0=time.time()
O.run()
t2=time.time()-t0
O.plot_etype('4 threads. t=%g s' % t2)


#%% Run MPSlib using all available threads
O.par['n_threads']=0;
O.delete_local_files() # Make sure no hard/soft data are conditioned to
O.d_hard = d_hard
t0=time.time()
O.run()
t3=time.time()-t0
O.plot_etype(title='All thread. t=%g s' % t3)



'''