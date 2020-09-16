// (c) 2015-2020 I-GIS (www.i-gis.dk) and Thomas Mejer Hansen (thomas.mejer.hansen@gmail.com)
//
//    This file is part of MPSlib.
//
//    MPSlib is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    MPSlib is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with MPSlib (COPYING.LESSER).  If not, see <http://www.gnu.org/licenses/>.
//
#include <iomanip>      // std::setprecision
#include <algorithm>    // std::random_shuffle std::remove_if
#include <list>

#include "ENESIM_GENERAL.h"
#include "mpslib/IO.h"
#include "mpslib/Utility.h"
#include "mpslib/Coords3D.h"

/**
* @brief Constructors from a configuration file
*/
MPS::ENESIM_GENERAL::ENESIM_GENERAL(const std::string& configurationFile) : MPS::ENESIM(){
	//std::cout << "Initialize start" << std::endl;
	initialize(configurationFile);
	//std::cout << "Initialize stop" << std::endl;
}

/**
* @brief Destructors
*/
MPS::ENESIM_GENERAL::~ENESIM_GENERAL(void) {
	_shuffleEntropyFactor=4;
}

/**
* @brief Initialize the simulation from a configuration file
* @param configurationFile configuration file name
*/
void MPS::ENESIM_GENERAL::initialize(const std::string& configurationFile) {
	//Reading configuration file
	_readConfigurations(configurationFile);

	//Reading data from files
	_readDataFromFiles();

	//Checking the TI array dimensions
	_tiDimX = (int)_TI[0][0].size();
	_tiDimY = (int)_TI[0].size();
	_tiDimZ = (int)_TI.size();

	//Define a random path to loop through TI cell
	_tiPath.resize(_tiDimX * _tiDimY * _tiDimZ);
	_initilizePath(_tiDimX, _tiDimY, _tiDimZ, _tiPath);
	if (_shuffleTiPath) {
		std::random_shuffle ( _tiPath.begin(), _tiPath.end() );
	}

	
	//Define multi threading parameters
	//_threads.resize(_numberOfThreads - 1);
	_jobDone = false;

	
	if(_debugMode > 0 ) {
		std::cout << "______________________________________" << std::endl;
		std::cout << "____________ENESIM____________________" << std::endl;
		std::cout << "Number of threads: " << _numberOfThreads << std::endl;
		std::cout << "Conditional points: " << _maxNeighbours << std::endl;
		std::cout << "Max iterations: " << _maxIterations << std::endl;
		if (_shuffleSgPath==0) {
			std::cout << "Path type: unilateral"<< std::endl;
		} else if (_shuffleSgPath==1) {
			std::cout << "Path type: random"<< std::endl;
		} else if (_shuffleSgPath==2) {
			std::cout << "Path type: Preferential, Entropy Factor: " << _shuffleEntropyFactor << std::endl;
		}
		std::cout << "Distance measure: " << _distance_measure;
		std::cout << ", threshold:" << _distance_threshold;
		std::cout << ", power order: " << _distance_power_order  << std::endl;
		std::cout << "SG: " << _sgDimX << " " << _sgDimY << " " << _sgDimZ << std::endl;
		std::cout << "TI: " << _tiFilename << " " << _tiDimX << " " << _tiDimY << " " << _tiDimZ << " " << _TI[0][0][0]<< std::endl;
	}
}

/**
* @brief Start the simulation
* Virtual function implemented from MPSAlgorithm
*/
void MPS::ENESIM_GENERAL::startSimulation(void) {
	//Call parent function
	MPS::MPSAlgorithm::startSimulation();

}

/**
* @brief MPS dsim simulation algorithm main function
* @param sgIdxX index X ojf a node inside the simulation grind
* @param sgIdxY index Y of a node inside the simulation grind
* @param sgIdxZ index Z of a node inside the simulation grind
* @param level multigrid level
* @return found node's value
*/
float MPS::ENESIM_GENERAL::_simulate(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, const int& level) {
	// By default do not use rejection sampler to account for soft data

	float real;
	real = _getRealizationFromCpdfEnesim(sgIdxX, sgIdxY, sgIdxZ, _sgIterations[sgIdxZ][sgIdxY][sgIdxX]);
	
	return real;
}

/**
* @brief Abstract function allow acces to the beginning of each simulation of each multiple grid
* @param level the current grid level
*/
void MPS::ENESIM_GENERAL::_InitStartSimulationEachMultipleGrid(const int& level) {
	//Empty for now
	if (_debugMode > 1) {
		std::cout << "Reloading soft data from files" << std::endl;
	}
	_readSoftDataFromFiles();
}
