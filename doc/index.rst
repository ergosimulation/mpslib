.. MPSlib documentation master file, created by
   sphinx-quickstart on Thu Jan 24 09:18:42 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

======================================
MPSlib: A C++ class for MPS simulation
======================================


MPSlib provides a C++ class, and a set of algorithms for simulation of
models based on a multiple point statistical (MPS) models inferred from
a training image:

- **ENESIM** [GUARDIANO]_. 
- **Generalized ENESIM** [HANSEN2016]_.
- **Direct Sampling** [MARIETHOZ2010]_.
- **SNESIM using tree structures** [STREBELLE2002]_.
- **SNESIM using list structures** [STRAUBHAAR2011]_.

The algorithms
==============
The above list of algorithms are implemented in two types of algorithms that differ in the way information is inferred from the training image. ENESIM type algorithms samples directly from the training image during simulation, while SNESIM type algorithms scan the training image prior to simulation, and stores the statistics in memory. 

- GENESIM:: :doc:`mps_genesim <Algorithms/chapGenesim/mps_genesim>`

:doc:`mps_genesim <Algorithms/chapGenesim/mps_genesim>` is an implementation of the generalized ENESIM algorithm [GUARDIANO]_. It can run as a pure **ENESIM** algorithm, in which the whole training image is scanned at each iteration, or it can run as a Direct Sampling **DS** algorithm [MARIETHOZ2010]_, in which the training image is scanned for the first matching event. It can can also run as generalized ENESIM **GENESIM** algorithm in which the training image is scanned for the first N matching event [HANSEN2016]_. 

- SNESIM:: :doc:`mps_snesim_tree <Algorithms/chapSnesim/mps_snesim>`/:doc:`mps_snesim_list <Algorithms/chapSnesim/mps_snesim>` 

Two types of SNESIM type simulation methods are implemented. 

:doc:`mps_snesim_tree <Algorithms/chapSnesim/mps_snesim>` stores statistics from the training image in a *tree structure*, as proposed by [STREBELLE2002]_
.
:doc:`mps_snesim_list <Algorithms/chapSnesim/mps_snesim>` stores statistics from the training image in a *list structure*, as proposed by [STRAUBHAAR2011]_.

`mps_snesim_tree`and `mps_snesim_list` differ only in how the information from the training image is store in memory. 

Conditional data
----------------
All algorithms can handle hard and co-loccated soft data. ``mps_genesim`` can also handle non-colocated soft data  [HANSEN2018]_.

Entropy
-------
The entropy of the (unknown) probability distribution related to a specific choice of 1) training image, 2) simulation algorithm, and 3) options for running the simulation algorithm, can optionally be computed as part of simulation. [HANSEN2020]_.

.. Estimation
.. ----------
.. All algorithms can otionally be run in *estimation* mode in which the 1D marginal conditional distribution is directly computed (similar to Etype statistics from a number of realizations) [JOHANNSSON2019]_.



.. see :ref:`ref-snesim`.

PYTHON and MATLAB interface
---------------------------
Interfaces to :doc:`Matlab/Octave interface <../matlab-interface>` and :doc:`Python <../python-interface>` are available.

Code
====

The latest stable code can be downloaded from
http://ergosimulation.github.io/mpslib/.

The current development version is available through GitHub at
https://github.com/ergosimulation/mpslib/.


Background
==========

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


Design
======
Details about the design of the mpslib C++ class can be found in [HANSEN2016]_. (`link <http://www.sciencedirect.com/science/article/pii/S2352711016300164>`_).

Briefly described, the main class is the ``MPSalgorithm`` class, which implements the sequential simulation algorithm (using multiple girds), methods for reading and writing 3D gridded data, methods for reading known data values (known as hard and soft data), and methods for establishing a data neighborhood, and controlling the simulation path.

Two subclasses, ``ENESIM`` and ``SNESIM`` extends ``MPSalgorithm`` to allow ENESIM and SNESIM type simulation. Finally, the three core algorithms are implemented based on these classes.

.. image:: https://ars.els-cdn.com/content/image/1-s2.0-S2352711016300164-gr1.jpg
    :alt: mpslib-design

Referencing
===========

Along with the first version of MPSlib a manuscript was published in
SoftwareX. Please use this for referencing MPSlib:

	Hansen, T.M., Vu. L.T., and Bach, T. 2016. MPSLIB: A C++ class for sequential simulation of multiple-point statistical models, in *SoftwareX*, doi:`10.1016/j.softx.2016.07.001 <https://doi.org/10.1016/j.softx.2016.07.001>`_. [`pdf <http://www.sciencedirect.com/science/article/pii/S2352711016300164/pdfft?md5=b3663280b22a5d06a2e931ca534ef1b5&pid=1-s2.0-S2352711016300164-main.pdf>`_,\ `www <http://www.sciencedirect.com/science/article/pii/S2352711016300164>`_].

To cite the use of soft data and the preferential path, please use:

	Hansen, T. M., Mosegaard, K., & Cordua, K. S. (2018). Multiple point statistical simulation using uncertain (soft) conditional data. *Computers & geosciences*, 114, 1-10. doi:`10.1016/j.cageo.2018.01.017 <https://doi.org/10.1016/j.cageo.2018.01.017>`_.


License (LGPL)
==============

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
   Algorithms/index
   training-image-format
   matlab-interface
   python-interface
   Examples/index
   contributions
   references

