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
#include <cctype>       // isspace
#include <algorithm>    // std::random_shuffle std::remove_if
#include <list>

#include "SNESIMList.h"
#include "mpslib/IO.h"
#include "mpslib/Coords3D.h"

/**
* @brief Constructors from a configuration file
*/
MPS::SNESIMList::SNESIMList(const std::string& configurationFile) : MPS::SNESIM(){
	initialize(configurationFile);
}

/**
* @brief Destructors
*/
MPS::SNESIMList::~SNESIMList(void) {

}

/**
* @brief Initialize the simulation from a configuration file
* @param configurationFile configuration file name
*/
void MPS::SNESIMList::initialize(const std::string& configurationFile) {

	//Reading configuration file
	_readConfigurations(configurationFile);

	//Reading data from files
	_readDataFromFiles();

	//Checking the TI array dimensions
	_tiDimX = (int)_TI[0][0].size();
	_tiDimY = (int)_TI[0].size();
	_tiDimZ = (int)_TI.size();

	//Building template structure
	_constructTemplateFaces(_templateSizeX, _templateSizeY, _templateSizeZ);

	//Scanning the TI and build the search dictionary
	//Building a multi spaces search dictionary
	int offset = 1;
	_patternsDictionary.resize(_totalGridsLevel + 1);
	for (int level=_totalGridsLevel; level>=0; level--) {
		//For each space level from coarse to fine 
		offset = int(std::pow(2, level));		
		if (_debugMode > -1) {
		  std::cout << "level: " << level << " offset: " << offset << std::endl;
		}
		int tiX, tiY, tiZ;
		int deltaX, deltaY, deltaZ;
		bool isValidKey = false;
		std::vector<float> key;
		int pixelsCnt = 0;
		for (int z=0; z<_tiDimZ; z+=1) {
			for (int y=0; y<_tiDimY; y+=1) {
				for (int x=0; x<_tiDimX; x+=1) {
					//For each pixel
					pixelsCnt ++;
					isValidKey = false;
					key.clear();
					for (unsigned int i=0; i<_templateFaces.size(); i++) {
						deltaX = offset * _templateFaces[i].getX();
						deltaY = offset * _templateFaces[i].getY();
						deltaZ = offset * _templateFaces[i].getZ();
						tiX = x + deltaX;
						tiY = y + deltaY;
						tiZ = z + deltaZ;
						//std::cout << deltaX << " " << deltaY << " " << deltaZ  << std::endl;
 						if ((tiX < 0 || tiX >= _tiDimX) || (tiY < 0 || tiY >= _tiDimY) || (tiZ < 0 || tiZ >= _tiDimZ) || MPS::utility::is_nan(_TI[tiZ][tiY][tiX])) {
							//Out of bound or NaN value then just ignore this key
							isValidKey = false;
							break;
							//key.push_back(std::numeric_limits<float>::quiet_NaN());
							//isValidKey = true;
						}
						else { 
							key.push_back(_TI[tiZ][tiY][tiX]);
							//Check key only when no overflow indices and no NaN value
							isValidKey = true;
						}
					}

					if (isValidKey) {
						//add new key if not found and increase counter if found
						auto itr = _patternsDictionary[level].find(key);
						if (itr != _patternsDictionary[level].end()) { //found 
							//Increase found counter;
							itr->second ++;
						} else { //not found
							//Add a new key inside the dictionary with counter equal to 1
							_patternsDictionary[level].insert ( std::pair<std::vector<float>,int>(key, 1) );
						}
					}
				}
			}	
		}
		if (_debugMode > 0) {
		  std::cout << "Total pixel: " << pixelsCnt << std::endl;
		  //Check out dictionary
		  std::cout << "Dictionary info: " << std::endl;
		  std::cout << "Level: " << level << std::endl;
		  std::cout << "Total elements: " << _patternsDictionary[level].size() << std::endl;
		}
		////Showing the dictionary to debug ...
		/*
		int ic=0;
		for(auto iter = _patternsDictionary[level].begin(); iter != _patternsDictionary[level].end(); ++iter) {
			ic++;
			//std::cout << "ic" << ic << " :: ";
			std::vector<float> key = iter->first;
			for (int i=0; i<key.size(); i++) {
				std::cout << key[i] << " ";
			}
			std::cout << "     " << iter->second << std::endl;
		}
		*/
	}	
}

/**
* @brief Start the simulation
* Virtual function implemented from MPSAlgorithm
*/
void MPS::SNESIMList::startSimulation(void) {
	//Call parent function
	MPS::MPSAlgorithm::startSimulation();
}

/**
* @brief MPS simulation algorithm main function
* @param sgIdxX index X of a node inside the simulation grind
* @param sgIdxY index Y of a node inside the simulation grind
* @param sgIdxZ index Z of a node inside the simulation grind
* @param level multigrid level
* @return found node's value
*/
float MPS::SNESIMList::_simulate(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, const int& level) {
	//Initialize with node's value
	float foundValue = _sg[sgIdxZ][sgIdxY][sgIdxX];
	//If have NaN value then doing the simulation ...
	if (MPS::utility::is_nan(_sg[sgIdxZ][sgIdxY][sgIdxX])) {
		int offset = int(std::pow(2, level));			
		int sgX, sgY, sgZ;
		int deltaX, deltaY, deltaZ;
		float tmp;
		foundValue = std::numeric_limits<float>::quiet_NaN();
		int maxConditionalPoints = -1, conditionPointsUsedCnt = 0;

		// 1. Find the conditioning event (nodeTemplate) in the neighborhood/template 
		std::vector<float> nodeTemplate;
		std::vector<int> nodeNonNan;
		int n_cond_found = 0;
		for (unsigned int i=1; i<_templateFaces.size(); i++) { //For all the set of templates available except the first one at the template center 	
			//For each template faces
			deltaX = offset * _templateFaces[i].getX();
			deltaY = offset * _templateFaces[i].getY();
			deltaZ = offset * _templateFaces[i].getZ();
			sgX = sgIdxX + deltaX;
			sgY = sgIdxY + deltaY;
			sgZ = sgIdxZ + deltaZ;

			if (!(sgX < 0 || sgX >= _sgDimX) && !(sgY < 0 || sgY >= _sgDimY) && !(sgZ < 0 || sgZ >= _sgDimZ)) { 
				//not overflow
				if ((_maxCondData > n_cond_found  ) && (!MPS::utility::is_nan(_sg[sgZ][sgY][sgX]))) {
					nodeTemplate.push_back(_sg[sgZ][sgY][sgX]);
					nodeNonNan.push_back(i);
					n_cond_found++;
				} else { //NaN value
					nodeTemplate.push_back(std::numeric_limits<float>::quiet_NaN());
				}
			} else nodeTemplate.push_back(std::numeric_limits<float>::quiet_NaN());
		}
			
		//Adding the first value to complete the template
		std::vector<float> dictionaryTemplate;
		bool perfectMatched = false;
		int currentLevel = 0, maxLevel = 0;
		int sumCounters = 0;
		//Searching the template inside the dictionary
		std::map<float, int> conditionalPoints;
		//std::vector<std::pair<float, int>> conditionalPoints;

		// 2 Loop over the list (_patternsDictionary[level]) to find entries of the conditional event (nodeTemplate)
		//std::cout << "DICT SIZE"  <<_patternsDictionary[level].size() << std::endl;
		for(std::map<std::vector<float>,int>::iterator iter = _patternsDictionary[level].begin(); iter != _patternsDictionary[level].end(); ++iter) {
			dictionaryTemplate = iter->first;
			//Compare the fullTemplate with the one in dictionary
			//Could be done parallele here
			sumCounters = iter->second;
			conditionPointsUsedCnt = 0; 
			//maxLevel = 0;

			// Next line: Old implementation, checks all entries in nodeTemplate
			//for(std::string::size_type i = 0; i < nodeTemplate.size(); ++i) {
			// Next line: New implementation, checks only nonNan entries in nodeTemplate 
			int i;
			for(std::vector <int> :: iterator it = nodeNonNan.begin(); it != nodeNonNan.end(); ++it){
				i=*it-1;
				if ((dictionaryTemplate[i + 1] == nodeTemplate[i]) && (!MPS::utility::is_nan(nodeTemplate[i]))) { //Is a matched
					currentLevel = i;
					//Template found so go to higher level node
					if (currentLevel > maxLevel) { 	
						maxLevel = currentLevel;
						//Restart counter at only maximum level
						//sumCounters = iter->second;
					} 
					//else if (currentLevel == maxLevel) {
					//	//Adding the counter to the sum counters
					//	sumCounters += iter->second;
					//}
					conditionPointsUsedCnt ++;
				}
				
			}
			//Only keep the highest conditional points used
			if (conditionPointsUsedCnt > maxConditionalPoints && currentLevel == maxLevel) {
				//maxLevel = currentLevel;
				//Clearing the current conditional points
				conditionalPoints.clear();
				//Adding points to the list
				conditionalPoints.insert ( std::pair<float, int>(dictionaryTemplate[0], sumCounters) );
				maxConditionalPoints = conditionPointsUsedCnt;
				//std::cout << "    --> conditionPointsUsedCnt" << conditionPointsUsedCnt << std::endl;
			} else if(conditionPointsUsedCnt == maxConditionalPoints) {
				auto itr = conditionalPoints.find(dictionaryTemplate[0]);
				if (itr != conditionalPoints.end()) { //found 
					//Increase counter if is the same facie value
					conditionalPoints[dictionaryTemplate[0]] += sumCounters; 
				} else {
					//Adding new facie points to the list
					conditionalPoints.insert ( std::pair<float, int>(dictionaryTemplate[0], sumCounters) );
				}
			}

			////Perfect match then stop searching TODO: Need to check about this, speedup but could be wrong mathematically because the lack of cpdf
			//if (conditionPointsUsedCnt == (dictionaryTemplate.size() - 1)) perfectMatched = true;
			//if (perfectMatched) break;
		}

		//Get the value from cpdf
		if (_doEstimation == true) {
			tmp = _cpdf(conditionalPoints, sgIdxX, sgIdxY, sgIdxZ);
		} else {
			foundValue = _cpdf(conditionalPoints, sgIdxX, sgIdxY, sgIdxZ);
		}
	}
	return foundValue;
}

/**
* @brief Abstract function allow acces to the beginning of each simulation of each multiple grid
* @param level the current grid level
*/
void MPS::SNESIMList::_InitStartSimulationEachMultipleGrid(const int& level) {
	//Empty for now
}
