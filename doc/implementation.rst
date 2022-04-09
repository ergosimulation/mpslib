==============
Implementation
==============


MPSlib is developed in C++, that provides both a C++ class, with wich different sequential simulation algorithms can be implemented, and three example implementations.

Details about the design of the mpslib C++ class can be found in [HANSEN2016]_. (`link <http://www.sciencedirect.com/science/article/pii/S2352711016300164>`_).

``MPS`` is a namespace that contains different classes. 

Briefly described, the main class is the ``MPSalgorithm`` class, which implements the sequential simulation algorithm (using multiple girds), methods for reading and writing 3D gridded data, methods for reading known data values (known as hard and soft data), and methods for establishing a data neighborhood, and controlling the simulation path.

Two abstract member functions are defined, but not implemented: 
``MPSAlgorithm::readConfig`` and 
``MPSAlgorithm::simulate`` 

In order to implement a spceific algorithm one must therefore needs to create a class that inherits MPSAlgorithm, 
and that implements MPSAlgorithm::readConfig and MPSAlgorithm::simulate.

Two subclasses, ``ENESIM`` and ``SNESIM`` extends ``MPSalgorithm`` to allow ENESIM and SNESIM type simulation. Finally, the three core algorithms are implemented based on these classes.

.. image:: https://ars.els-cdn.com/content/image/1-s2.0-S2352711016300164-gr1.jpg
    :alt: mpslib-design

EX: The ENESIM Class
====================
The ENESIM CLASS is inherited from the MPSAlgorithm class, in the MPS namespace

ENESIM_GENERAL.cpp/h Inherits the ENESIM cass from the MPSAlgorithm class, and has two methods:
::
    
    ENESIM_GENERAL::initialize
    ENESIM_GENERAL::startSimulation (inherited from MPSalgorithm

ENESIM_GENERAL contain implementation of 'readConfiguration' and 'simulate'

ENESIM_GENERAL.h includes  
mpslib/ENESIM.h which contains the implementation of 'readConfiguration' and 'simulate'
MPS::ENESIM_GENERAL::_simulate



mpslib/ENESIM.cpp/h implements the method 
MPS::ENESIM_GENERAL::_readConfigurations 
and the function 
'_getRealizationFromCpdfTiEnesimRejectionNonCo' 
which is in effect what os evaluated in the
MPS::ENESIM_GENERAL::_simulate


mps_genesim.cpp/h simple load the class and call the method 'startSimulation' which is defined in MPSalgorithm

