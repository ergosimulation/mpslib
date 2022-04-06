# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 11:43:18 2019

@author: thoma
"""
from exclass import exclass
import time

#%%
print('__name__= %s' % __name__)
print('time=%g' % time.time())
if __name__ == '__main__':
    O = exclass(x=1);

    nr = 5
    
    Oseq = O.run_seq(N=nr);
     
    Opar = O.run_parallel(N=nr)
         
    for i in range(nr):
        print('i = %d, x_seq=%3g, x_par=%3g'  % (i,Oseq[i].x, Opar[i].x))