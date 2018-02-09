scikit-mps: A python interface to MPSlib 
========================================================================================

`scikit-mps` is a Python interface to MPSlib, https://github.com/ergosimulation/mpslib/,
which is a C++ library for geostatistical multiple point simulation, with implementations
of 'SNESIM', 'ENESIM', and 'GENESIM'

It contains three modules:
  * mpslib: Interacts with MPSlib
  * eas: read and write EAS/GSLIB formatted files
  * trainingimages: Access to a number of trainingimages

.. code::
   import mpslib as mps
   O1=mps.mpslib(method='mps_snesim_tree')
   O.run()
   O1.plot_reals()
   O1.plot_etype()

PyPI
~~~~~~~~~
`<http://pypi.python.org/pypi/scikit-mps>`

Requirements
~~~~~~~~~~~~
* Numpy >= 1.0.2
* Matplotlib >= 1.0.2
* MPSlib needs to be downloaded, installed, and in the system path (https://github.com/ergosimulation/mpslib/)
  [Any 11 C++11 compiler should work, such as gcc, MinGW, MSVC]

Installing
~~~~~~~~~~~~~~
* Via pip: pip3 install scikit-mps
.. code::
   cd ROOT_OF_MPSLIB/python   
   pip3 install .

If you wish to develop the scikit-mps package, then install it in editable developer mode using
.. code::
   pip3 install -e .
