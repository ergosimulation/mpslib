# mpslib_example.py
# example of using mpslib.py

#%%
import mpslib as mps;

from time import sleep
from random import randint
from sense_hat import SenseHat
sense = SenseHat()


#%% MPS_SNESIM_TREE

O1 = mps.mpslib(method='mps_genesim', n_real = 1, verbose_level=-1)

O1.par['simulation_grid_size'][0]=8;
O1.par['simulation_grid_size'][1]=8;

O1.ti= mps.trainingimages.maze()[0]
O1.ti = O1.ti[10:300:2][:,10:300:2]

O1.parameter_filename = 'mps.txt'
O1.par['debug_level']=-1;
O1.par['ti_fnam'] = 'ti.dat';
O1.par['n_cond']=16;
O1.par['shuffle_simulation_grid']=1;
O1.run()


# Initialize color
r_rand=randint(0, 255);
g_rand=randint(0, 255);
b_rand=randint(0, 255);

#%% Start loop
i=0;
while (True):
    i=i+1;

    # Fix some data and resimulate the rest
    step = 0.2 # The percentage of data to fix
    d_hard = O1.seq_gibbs_set_hard_data(0.2)
    O1.d_hard = d_hard
        
    O1.par['rseed']=i;
    O1.run()

    # Update color
    r_rand = r_rand + randint(-5,5);
    g_rand = g_rand + randint(-5,5);
    b_rand = g_rand + randint(-5,5);
    if (r_rand<0):
        r_rand=0
    if (r_rand>255):
        r_rand=255
    if (g_rand<0):
        g_rand=0
    if (g_rand>255):
        g_rand=255
    if (b_rand<0):
        b_rand=0
    if (b_rand>255):
        b_rand=255
        
    #%% UPDATE SENSE HAT
    for x in range(8):
        for y in range(8):
            v = int(O1.sim[0][y][x])
            r = v*r_rand
            g = v*g_rand      
            b = v*b_rand      
            sense.set_pixel(x, y, r, g, b)
    #sleep(.05)





