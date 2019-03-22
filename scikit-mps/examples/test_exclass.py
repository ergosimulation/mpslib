# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 11:43:18 2019

@author: thoma
"""
from exclass import exclass
import time

#%%
print(__name__)
print(time.time())
O = exclass(x=1);
O.run();
if __name__ == '__main__':
    Oall, Oall_par =  O.run_parallel(N=20)
     
    
    for i in range(len(Oall_par)):
        print('%10.2g %10.2g' % (Oall[i].x,Oall_par[i].x))
 