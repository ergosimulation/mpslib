# mpslib_example_tmh
import matplotlib.pyplot as plt
import mpslib as mps

#%% MPS_SNESIM_TREE
O1=mps.mpslib(method='mps_snesim_tree')
#O1=mps.mpslib(method='mps_genesim')
O1.par['debug_level']=-1



# when debug_level>-1 and the text output from mpslib increase, the mpslib exe file is detached from 
# python before it has finished running!!!
#TI, TI_filename=mps.trainingimages.lines()
#TI, TI_filename=mps.trainingimages.bangladesh()
#TI, TI_filename=mps.trainingimages.checkerboard()
#TI, TI_filename=mps.trainingimages.checkerboard2()
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=40, ny=50, cell_x=8, cell_y=4, cell_2=10)
#TI, TI_filename=mps.trainingimages.checkerboard2(nx=100, ny=100, cell_x=4, cell_y=4, cell_2=3)
TI, TI_filename=mps.trainingimages.checkerboard2(nx=100, ny=100, cell_x=14, cell_y=8, cell_2=5)
TI, TI_filename=mps.trainingimages.checkerboard2(nx=40, ny=40, cell_x=14, cell_y=4, cell_2=9)
#TI, TI_filename=mps.trainingimages.maze()

O1.par['ti_fnam']=TI_filename

O1.ti = TI
O1.par['n_cond']=81
O1.par['rseed']=0
O1.par['n_real']=9
O1.parameter_filename='test.par'
O1.run()


plt.ion()

O1.plot_reals()

O1.plot_etype()
plt.savefig("ti_example_%s_%s.png" % (O1.method,O1.par['ti_fnam']), dpi=600)

plt.figure(3)
plt.subplot(3, 3, 1)
plt.imshow(TI, interpolation='none')
plt.title(O1.par['ti_fnam'])


plt.show()
