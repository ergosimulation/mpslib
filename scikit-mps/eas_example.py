# mpslib_example.py
# example of using mpslib.py
#import mpslib as mps;
#import numpy as np;
import sys
sys.path.append('mpslib')
import mpslib.eas as eas
#import eas;
import matplotlib.pyplot as plt;


#%% Download JURA data
import urllib.request
urllib.request.urlretrieve('https://github.com/cultpenguin/mGstat/raw/master/examples/data/jura/prediction.dat', 'prediction.dat')


#%% read and plot 2d scatter data
#import importlib
#importlib.reload(eas)
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


#%% read and plot 2D matrix

file_eas='ti.dat';
O = eas.read(file_eas) 
plt.imshow(O['Dmat'],interpolation='none')
plt.title(O['title']+" - "+O['header'][0])
plt.show()