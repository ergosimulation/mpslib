MPS is a namespace that contains different classes. 
The main class is the  MPSalgorithm class. 
It is a basin implementation of Sequential Simulation, with mulitiple grids

Two abstract member functions are defined, but not implemented: 
MPSAlgorithm::readConfig and 
MPSAlgorithm::simulate

In order to implement a spceific algorithm one must therefore needs to create a class that inherits MPSAlgorithm, 
and that implements MPSAlgorithm::readConfig and MPSAlgorithm::simulate.

EX ENESIM

The ENESIM CLASS is inherited from the MPSAlgorithm class, in the MPS namespace



ENESIM_GENERAL.cpp/h Inherits the ENESIM cass from the MPSAlgorithm class, and has two methods:
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

