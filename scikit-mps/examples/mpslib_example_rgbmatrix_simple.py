#!/usr/bin/env python3
# Visualizing simulstions on RGB MATRIX,


# import 
import sys
import numpy as np
import time
from random import randint

# import mpslib
import mpslib as mps;

# import the RGBMatrix library from
# https://github.com/hzeller/rpi-rgb-led-matrix/tree/master/bindings
from rgbmatrix import RGBMatrix, RGBMatrixOptions
from PIL import Image


#%% Setup MPSlib
O1 = mps.mpslib(method='mps_genesim', n_real = 1, verbose_level=-1)
#O1.par['simulation_grid_size'][0]=matrix.width;
#O1.par['simulation_grid_size'][1]=matrix.height;
O1.par['simulation_grid_size'][0]=32;
O1.par['simulation_grid_size'][1]=32;
O1.par['debug_level']=-1;
O1.par['n_cond']=25;
O1.ti= mps.trainingimages.maze()[0]
O1.ti = O1.ti[10:300:1][:,10:300:1]
#O1.ti = O1.ti[10:300:2][:,10:300:2]
#O1.ti= mps.trainingimages.checkerboard()[0]
O1.par['rseed']=0;
O1.par['shuffle_simulation_grid']=1;
O1.run()

#%% Configuration for the RGB matrix
options = RGBMatrixOptions()
options.rows = 32
options.chain_length = 1
options.parallel = 1
options.hardware_mapping = 'adafruit-hat'  # If you have an Adafruit HAT: 'adafruit-hat'


SIM = [];
NS=8
i=0
while (i<NS):
    i=i+1

    # Fix some data and resimulate the rest
    step = 0.2 # The percentage of data to fix
    d_hard = O1.seq_gibbs_set_hard_data(0.2)
    O1.d_hard = d_hard
        
    O1.par['rseed']=i
    O1.run()
    SIM.append(O1.sim[0])

    

#print(O1.sim[0])
#np.save('file1',O1.sim[0])

matrix = RGBMatrix(options = options)


#for i in range(len(SIM)):
sign = 1;
i=-1;
while (True):

    if (sign==1):
        i=i+1
    else:
        i=i-1

    if (i<0):
        sign=1
        i=1;
    if (i>=len(SIM)):
        i=len(SIM)-2
        sign = -1
    

    print(i)
    SIM_SHOW = SIM[i]
    RGB = np.zeros((matrix.width,matrix.height,3))
    for ix in range(32):
        for iy in range(32):
            RGB[iy,ix,1]=100*SIM_SHOW[iy,ix]
            #        RGB[iy,ix,1]=100*O1.sim[0][iy,ix]


    image = Image.fromarray(np.uint8(RGB))


    image.thumbnail((matrix.width, matrix.height), Image.ANTIALIAS)
    matrix.SetImage(image.convert('RGB'))

    time.sleep(.1)


try:
    print("Press CTRL-C to stop.")
    while True:
        time.sleep(100)
except KeyboardInterrupt:
    sys.exit(0)

    
