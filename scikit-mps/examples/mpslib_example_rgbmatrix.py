#!/usr/bin/env python

# mpslib_example.py
# example of using mpslib.py

import mpslib as mps;
import matplotlib.pyplot as plt;
#plt.ion();

import sys
import numpy as np
from time import sleep
from random import randint
#from sense_emu import SenseHat
#sense = SenseHat()

import time
from rgbmatrix import RGBMatrix, RGBMatrixOptions
from PIL import Image

#%% MPS_SNESIM_TREE
O1 = mps.mpslib(method='mps_snesim_tree',hard_data_fnam = 'mps_2d_hard_data.dat',
                    n_real = 1, verbose_level=1)
#O1.par['simulation_grid_size'][0]=matrix.width;
#O1.par['simulation_grid_size'][1]=matrix.height;
O1.par['simulation_grid_size'][0]=32;
O1.par['simulation_grid_size'][1]=32;
O1.parameter_filename = 'mps_snesim.txt'
O1.par['debug_level']=-1;
O1.par['ti_fnam'] = 'ti.dat';
O1.par['n_cond']=9;
O1.run()
print(O1.sim[0])



# Configuration for the matrix
options = RGBMatrixOptions()
options.rows = 32
options.chain_length = 1
options.parallel = 1
options.hardware_mapping = 'adafruit-hat'  # If you have an Adafruit HAT: 'adafruit-hat'
matrix = RGBMatrix(options = options)

RGB = np.zeros((matrix.width,matrix.height,3))
for ix in range(32):
            for iy in range(32):
                            RGB[iy,ix,1]=100*O1.sim[0][iy,ix]


image = Image.fromarray(np.uint8(RGB))
#image.save('test2.jpg')

image.thumbnail((matrix.width, matrix.height), Image.ANTIALIAS)

matrix.SetImage(image.convert('RGB'))


print(RGB.shape)

try:
    print("Press CTRL-C to stop.")
    while True:
        time.sleep(100)
except KeyboardInterrupt:
    sys.exit(0)

    

i=0;

while i<1:
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
			#sense.set_pixel(x, y, r, g, b)
			#sleep(.01)
	print(O1.sim[0])#sleep(1)

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


