# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 11:18:49 2019

@author: thoma
"""

class exclass:
    def __init__(self, x=1):
        self.x = x
 
    def run(self, OBJ = None):
        if not (OBJ is None):
            OBJ.run()
            print('par x=%g' % OBJ.x)
            return OBJ
        else:
            self.x = self.x * self.x
            print("x=%f" % self.x)
            


    def run_parallel(self, N=10):
        '''RUN simulation in parallel
        '''
        import os
        import copy
        from multiprocessing import Pool
        
        Ncpu = 2
        
        
        Oall=[];
        for i in range(N):
            Otest = copy.deepcopy(self)
            Otest.x=i
            Oall.append(Otest)
        
        
        OUT = None
        # parallel run
        #if __name__ == '__main__':
        #p = Pool(Ncpu)
        #p = Pool(Ncpu)
        p = Pool(Ncpu)
        OUT = p.map(self.run, Oall)    
            
        # sequential run
        for i in range(N):
            Oall[i].run()
            
        return Oall, OUT 
