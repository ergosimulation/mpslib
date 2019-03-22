# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 11:43:18 2019

@author: thoma
"""
import exclass

O = exclass.exclass(x=1);
O.run();
Oall, Oall_par =  O.run_parallel(N=20)
 
 
for i in range(len(Oall_par)):
    print('%10.2g %10.2g' % (Oall[i].x,Oall_par[i].x))
 