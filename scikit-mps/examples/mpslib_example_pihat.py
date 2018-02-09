# mpslib_example.py
# example of using mpslib.py

import sys
sys.path.append('mpslib')

#%%
import mpslib as mps;
import matplotlib.pyplot as plt;
#plt.ion();

from time import sleep
from random import randint
from sense_emu import SenseHat
sense = SenseHat()


#%% MPS_SNESIM_TREE

O1 = mps.mpslib(method='mps_snesim_tree',hard_data_fnam = 'mps_2d_hard_data.dat',
                    n_real = 1, verbose_level=1)

O1.par['simulation_grid_size'][0]=8;
O1.par['simulation_grid_size'][1]=8;

O1.parameter_filename = 'mps_snesim.txt'
O1.par['debug_level']=-1;
O1.par['ti_fnam'] = 'ti.dat';
O1.par['n_cond']=9;
i=0;
while i<1000:
	i=i+1;
	O1.par['rseed']=i;
	O1.run()

	r_rand=randint(0, 255);
	g_rand=randint(0, 255);
	b_rand=randint(0, 255);
	#%% UPDATE SENSE HAT
	for x in range(8):
		for y in range(8):
			v = int(O1.sim[0][y][x])
			#print('i='+repr(i)+' v='+repr(v))
			r = v*r_rand
			g = v*g_rand  	
			b = v*b_rand  	
			sense.set_pixel(x, y, r, g, b)
			#sleep(.01)
	#sleep(1)

#%%

sys.exit()

plt.set_cmap('hot')
fig1 = plt.figure(1)
for i in range(0, O1.par['n_real']):
    plt.subplot(3,3,i+1)
    plt.imshow(O1.sim[i], interpolation='none')

fig1.suptitle(O1.method, fontsize=16)
plt.savefig(O1.method+'.png', dpi=600)
plt.show();


