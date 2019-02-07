.. MPSlib documentation master file, created by
   sphinx-quickstart on Thu Jan 24 09:18:42 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

MPSlib: A C++ class for MPS simulation
======================================

MPSlib provides a C++ class, and a set of algorithms for simulation of
models based on a multiple point statistical (MPS) models inferred from
a training image.

As example the following algorithms has been implemented

-  :doc:`mps_genesim <../Algorithms/chapGenesim>` 
-  :doc:`mps_snesim <../Algorithms/chapSnesim>` 

A `Matlab/Octave interface <matlab-interface>`__ to these algorithms, is
available, from which all parameters can be set.

The latest stable code can be downloaded from
http://ergosimulation.github.io/mpslib/.

The current development version is available through GitHub at
https://github.com/ergosimulation/mpslib/.


Background
----------

The goal of developing these codes has been to produce a set of
algorithms, based on sequential simulation, for simulation of multiple
point statistical models. The code should be easy to compile and extend,
and should be allowed for both commercial and non-commercial use.

MPSlib (version 1.0) has been developed by
`I-GIS <http://www.i-gis.dk/>`__ and `Solid Earth Physics, Niels Bohr
Institute <http://imgp.nbi.ku.dk/>`__.

Development has been funded by the Danish National Hightech Foundation
(now: the Innovation fund) through the ERGO (Effective high-resolution
Geological Modeling) project, a collaboration between
`IGIS <http://i-gis.dk/>`__, `GEUS <http://geus.dk/>`__, and `Niels Bohr
Institute <http://nbi.ku.dk/>`__.

Referencing
-----------

Along with the first version of MPSlib a manuscript was published in
SoftwareX. Please use this for referencing MPSlib:

Hansen, T.M., Vu. L.T., and Bach, T. 2016. MPSLIB: A C++ class for
sequential simulation of multiple-point statistical models, in
*SoftwareX*,
doi:\ `10.1016/j.softx.2016.07.001 <https://doi.org/10.1016/j.softx.2016.07.001>`__.
[`pdf <http://www.sciencedirect.com/science/article/pii/S2352711016300164/pdfft?md5=b3663280b22a5d06a2e931ca534ef1b5&pid=1-s2.0-S2352711016300164-main.pdf>`__,\ `www <http://www.sciencedirect.com/science/article/pii/S2352711016300164>`__]


License (LGPL)
--------------

This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or (at
your option) any later version. This program is distributed in the hope
that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details. You should
have received a copy of the GNU Lesser General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 59
Temple Place - Suite 330, Boston, MA 02111-1307, USA.

How is it organized?
--------------------
.. toctree::
   :maxdepth: 3
	      
   chapInstall
   chapDesign
   Algorithms/README
   Algorithms/chapGenesim
   Algorithms/chapSnesim
   Algorithms/chapSnesim/mps_snesim_tree-with-varying-template
   training-image-format
   matlab-interface
   python-interface
	     

