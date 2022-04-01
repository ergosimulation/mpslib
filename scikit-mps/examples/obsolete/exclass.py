# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 11:18:49 2019

@author: thoma
"""
import os
import copy
       
class exclass:
    def __init__(self, x=1):
        self.x = x
 
    def run(self, OBJ = None):
        if not (OBJ is None):
            OBJ.run()
            return OBJ
        else:
            self.x = self.x * self.x
            print('x=%g' % self.x)


    def run_seq(self, N=10):
        Oall=[]
        for i in range(N):
            Otest = copy.deepcopy(self)
            Otest.x=i
            Otest.run()
            Oall.append(Otest)
        return Oall
        
    def run_parallel(self, N=10):
        '''RUN simulation in parallel
        '''
        from multiprocessing import Pool
        
        Oall=[];
        for i in range(N):
            Otest = copy.deepcopy(self)
            Otest.x=i
            Oall.append(Otest)
        
        print(__name__)
        OUT = None
        p = Pool(2)
        OUT = p.map(self.run, Oall)    
                
        return OUT 
