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

#include "SNESIMTree.h"
#include "mpslib/IO.h"
#include "mpslib/Coords3D.h"

/**
* @brief Constructors from a configuration file
*/
MPS::SNESIMTree::SNESIMTree(const std::string& configurationFile) : MPS::SNESIM(){
	initialize(configurationFile);
}

/**
* @brief Destructors
*/
MPS::SNESIMTree::~SNESIMTree(void) {

}

/**
* @brief Initialize the simulation from a configuration file
* @param configurationFile configuration file name
*/
void MPS::SNESIMTree::initialize(const std::string& configurationFile) {
	//Reading configuration file
	_readConfigurations(configurationFile);

	//Reading data from files
	_readDataFromFiles();

	//Checking the TI array dimensions
	_tiDimX = (int)_TI[0][0].size();
	_tiDimY = (int)_TI[0].size();
	_tiDimZ = (int)_TI.size();


	if (_debugMode > 2) {
		std::cout << "TI size (X,Y,Z): " << _tiDimX << " " << _tiDimY << " " << _tiDimZ << std::endl;
		if (_shuffleSgPath==0) {
			std::cout << "Path type: unilateral"<< std::endl;
		} else if (_shuffleSgPath==1) {
			std::cout << "Path type: random"<< std::endl;
		} else if (_shuffleSgPath==2) {
			std::cout << "Path type: Preferential, Entropy Factor: " << _shuffleEntropyFactor << std::endl;
		}
	}
}

/**
* @brief Abstract function allow acces to the beginning of each simulation of each multiple grid
* @param level the current grid level
*/
void MPS::SNESIMTree::_InitStartSimulationEachMultipleGrid(const int& level) {
	int totalLevel = _totalGridsLevel;

	int templateX = _templateSizeX, templateY = _templateSizeY, templateZ = _templateSizeZ;

	if (_templateSizeX != _templateSizeX_base || _templateSizeY != _templateSizeY_base || _templateSizeZ != _templateSizeZ_base) {
		// Use adaptive template
		// Ajust the template size based on the current level, template get smaller when the level get lower
		
		if (_totalGridsLevel > 0) {
			
			float ddx = ((float)_templateSizeX - (float)_templateSizeX_base) / ((float)_totalGridsLevel);
			float ddy = ((float)_templateSizeY - (float)_templateSizeY_base) / ((float)_totalGridsLevel);
			float ddz = ((float)_templateSizeZ - (float)_templateSizeZ_base) / ((float)_totalGridsLevel);
			templateX = _templateSizeX_base + ceil(level*ddx);
			templateY = _templateSizeY_base + ceil(level*ddy);
			templateZ = _templateSizeZ_base + ceil(level*ddz);
		
			if (_debugMode > 0) {
				std::cout << "Grid " << level << "/" << _totalGridsLevel << std::endl;
				std::cout << "Using adaptive grid" << std::endl;
				std::cout << "Template Size INIT = " << _templateSizeX << "," << _templateSizeY << "," << _templateSizeZ << std::endl;
				std::cout << "Template Size END  = " << _templateSizeX_base << "," << _templateSizeY_base << "," << _templateSizeZ_base << std::endl;
				std::cout << "Template USE       = " << templateX << "," << templateY << "," << templateZ << std::endl;
			}
		}
	}

	//Building template structure
	_constructTemplateFaces(templateX, templateY, templateZ);

	//Scanning the TI and build the search tree
	//Building the search tree
	_searchTree.clear();

	int offset = int(std::pow(2, level));
	int tiX, tiY, tiZ;
	int deltaX, deltaY, deltaZ;
	int nodeCnt = 0;
	bool foundExistingValue = false;
	int foundIdx = 0;
	int totalNodes = _tiDimX * _tiDimY * _tiDimZ;
	int lastProgress = 0;
	//Put the current node as the root node
	std::vector<TreeNode>* currentTreeNode = &_searchTree;

	for (int z=0; z<_tiDimZ; z+=1) {
		for (int y=0; y<_tiDimY; y+=1) {
			for (int x=0; x<_tiDimX; x+=1) {
				//For each pixel
				nodeCnt ++;
				if (_debugMode > -1) {
					//Doing the progression
					//Print progression on screen
					int progress = (int)((nodeCnt / (float)totalNodes) * 100);
					if ((progress % 10) == 0 && progress != lastProgress) { //Report every 10%
						lastProgress = progress;
						std::cout << "Building search tree at level: " << level << " Progression (%): " << progress << std::endl;
					}
				}
				//Reset current node to root node
				currentTreeNode = &_searchTree;
				for (unsigned int i=0; i<_templateFaces.size(); i++) {
					//Go deeper in the pattern template or to a higher level node
					deltaX = offset * _templateFaces[i].getX();
					deltaY = offset * _templateFaces[i].getY();
					deltaZ = offset * _templateFaces[i].getZ();
					tiX = x + deltaX;
					tiY = y + deltaY;
					tiZ = z + deltaZ;

					foundExistingValue = false;
					foundIdx = 0;
					//Checking of NaN value
					//if ((tiX < 0 || tiX >= _tiDimX) || (tiY < 0 || tiY >= _tiDimY) || (tiZ < 0 || tiZ >= _tiDimZ) || MPS::utility::is_nan(_TI[tiZ][tiY][tiX])) { //Out of bound or nan
					if ((tiX < 0 || tiX >= _tiDimX) || (tiY < 0 || tiY >= _tiDimY) || (tiZ < 0 || tiZ >= _tiDimZ) || MPS::utility::is_nan(_TI[z][y][x])) { //Out of bound or nan
						break; //Ignore border stop here
					} else {
						//Searching the TI cell value inside the current node
						for (unsigned int j=0; j<currentTreeNode->size(); j++) {
							if(_TI[tiZ][tiY][tiX] == currentTreeNode->operator[](j).value) {
								//Existing value so increase the counter
								foundExistingValue = true;
								currentTreeNode->operator[](j).counter = currentTreeNode->operator[](j).counter + 1;
								foundIdx = j;
								break;
							}
						}

						//If value is not found then add a new value in the node
						if (!foundExistingValue) {
							TreeNode aTreeNode;
							aTreeNode.counter = 1;
							aTreeNode.value = _TI[tiZ][tiY][tiX];
							aTreeNode.level = i;
							currentTreeNode->push_back(aTreeNode);
							foundIdx = (int)currentTreeNode->size() - 1;
						}
						//Switching the current node to the children
						currentTreeNode = &(currentTreeNode->operator[](foundIdx).children);
					}
				}
			}
		}
	}
	if (_debugMode > -1) {
		std::cout << "Finish building search tree" << std::endl;
		std::cout << "Total nodes: " << nodeCnt << std::endl;
		//std::cout << "Dictionary info: " << std::endl;
		//td::cout << "Level: " << level << std::endl;
	}
	//Check out dictionary
	// ////Showing the search tree for debugging
	// std::list<std::vector<TreeNode>*> nodesToCheck;
	// nodesToCheck.push_back(&_searchTree[level]); //Put the root node in the list node to be checked
	// //Looping through all the node from top to bottom
	// while(nodesToCheck.size() > 0) {
	// 	currentTreeNode = nodesToCheck.back();
	// 	nodesToCheck.pop_back();
	// 	//Showing the current node value and counter
	// 	for (int i=0; i<currentTreeNode->size(); i++) {
	// 		std::cout << currentTreeNode->operator[](i).level << " " << currentTreeNode->operator[](i).value << " " << currentTreeNode->operator[](i).counter << std::endl;
	// 		//Adding the children node to the list node to be checked
	// 		nodesToCheck.push_front(&(currentTreeNode->operator[](i).children));
	// 	}
	// 	//std::cout << "list size: " << nodesToCheck.size() << std::endl;
	// }

}

/**
* @brief Start the simulation
* Virtual function implemented from MPSAlgorithm
*/
void MPS::SNESIMTree::startSimulation(void) {
	//Call parent function
	MPS::MPSAlgorithm::startSimulation();
}

/**
* @brief MPS dsim simulation algorithm main function
* @param sgIdxX index X of a node inside the simulation grind
* @param sgIdxY index Y of a node inside the simulation grind
* @param sgIdxZ index Z of a node inside the simulation grind
* @param level multigrid level
* @return found node's value
*/
float MPS::SNESIMTree::_simulate(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, const int& level) {
	//Initialize with node's value
	float foundValue = _sg[sgIdxZ][sgIdxY][sgIdxX];
	//If have NaN value then doing the simulation ...
	if (MPS::utility::is_nan(_sg[sgIdxZ][sgIdxY][sgIdxX])) {
		int offset = int(std::pow(2, level));
		int sgX, sgY, sgZ;
		int deltaX, deltaY, deltaZ;
		float tmp;
		foundValue = std::numeric_limits<float>::quiet_NaN();
		int maxConditionalPoints = -1, 
		conditionPointsUsedCnt = 0;
		//Initialize a value
		std::vector<float> aPartialTemplate;
		//Building a template based on the neighbor points
		// Find conditional data
		int NinT = -1; // counter for number of found conditional data in _templateFaces
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
				if ( (NinT<_maxCondData) && (!MPS::utility::is_nan(_sg[sgZ][sgY][sgX])) ) {
					NinT = NinT + 1;
					aPartialTemplate.push_back(_sg[sgZ][sgY][sgX]);
				} else { //NaN value
					aPartialTemplate.push_back(std::numeric_limits<float>::quiet_NaN());
				}
			} else aPartialTemplate.push_back(std::numeric_limits<float>::quiet_NaN());
		}


		//std::cout << ".........." << std::endl;
		//std::cout << std::endl;
		//for (std::vector<float>::const_iterator i = aPartialTemplate.begin(); i != aPartialTemplate.end(); ++i)
    	//	std::cout << *i << ' ';


		//std::cout << "NinT=" << NinT << std::endl;
		//std::cout << "_maxCondData=" << _maxCondData << std::endl;
		//std::cout << aPartialTemplate.size() << std::endl;
		//Going through the search tree and get the value of the current template
		std::vector<TreeNode>* currentTreeNode;
		std::list<std::vector<TreeNode>*> nodesToCheck;

		//      RENAME conditionalPoints to conditionalCount
		std::map<float, int> conditionalPoints;
		int sumCounters = 0;
		int currentLevel = 0, maxLevel = 0;

		// MAKE SURE CODE WORKS WHEN N_COND = 1.. SHOULD ALWAYS GIVE the 1D MARGfrom the TI!!!!

		//For all possible values of root tree
		for (unsigned int j=0; j<_searchTree.size(); j++) {
			conditionPointsUsedCnt = 0;
			maxLevel = 0;
			sumCounters = _searchTree[j].counter;
			//std::cout << "sumCounters=" << sumCounters << std::endl;
			nodesToCheck.clear();
			nodesToCheck.push_back(&_searchTree[j].children); //Initialize at children in first level
			//Looping through all the node from top to bottom
			while(nodesToCheck.size() > 0) {
				currentTreeNode = nodesToCheck.back();
				nodesToCheck.pop_back();
				//Showing the current node value and counter
				for (unsigned int i=0; i<currentTreeNode->size(); i++) {
					if (MPS::utility::is_nan(aPartialTemplate[currentTreeNode->operator[](i).level - 1])) {
						//If the template value is non defined then just go to children
						nodesToCheck.push_front(&(currentTreeNode->operator[](i).children));
					} else if (currentTreeNode->operator[](i).value == aPartialTemplate[currentTreeNode->operator[](i).level - 1]) {
						currentLevel = currentTreeNode->operator[](i).level;
						//Template found so go to higher level node
						if (currentLevel > maxLevel) {
							maxLevel = currentLevel;
							//Restart counter at only maximum level
							sumCounters = currentTreeNode->operator[](i).counter;
							conditionPointsUsedCnt ++;
						} else if (currentLevel == maxLevel) {
							//Adding the counter to the sum counters
							sumCounters += currentTreeNode->operator[](i).counter;
						}

						//Only continue to the children node if the current node counter is big enough or if the number of conditional points used is smaller than a given limit
						if(currentTreeNode->operator[](i).counter > _minNodeCount && (conditionPointsUsedCnt < _maxCondData || _maxCondData == -1)) {
							//Adding the children node to the list node to be checked
							nodesToCheck.push_front(&(currentTreeNode->operator[](i).children));
						}
					}
				}
			}
			//std::cout << "j=" << j << " " ;
			//std::cout << "conditionPointsUsedCnt=" << conditionPointsUsedCnt << " " ;
			//std::cout << "maxConditionalPoints=" << maxConditionalPoints << " :: " ;
			//std::cout << _searchTree[j].value << " " << sumCounters << " " << maxLevel << std::endl;
			//finish searching for a value, now do the sum
			if (conditionPointsUsedCnt > maxConditionalPoints) {
				conditionalPoints.clear();
				conditionalPoints.insert ( std::pair<float, int>(_searchTree[j].value, sumCounters) );
				maxConditionalPoints = conditionPointsUsedCnt;
				//foundValue = _searchTree[level][j].value;
			} else if(conditionPointsUsedCnt == maxConditionalPoints) {
				conditionalPoints.insert ( std::pair<float, int>(_searchTree[j].value, sumCounters) );
			}
		}

		if (_debugMode>1) {
            _tg1[sgIdxZ][sgIdxY][sgIdxX] =  conditionPointsUsedCnt;
            _tg2[sgIdxZ][sgIdxY][sgIdxX] =  maxLevel;
            _tg3[sgIdxZ][sgIdxY][sgIdxX] =  sumCounters;
		}
		//Get the value from cpdf
		if (_doEstimation == true) {
			// Estimate --> not store simulated value
			tmp = _cpdf(conditionalPoints, sgIdxX, sgIdxY, sgIdxZ);
		} else {
			foundValue = _cpdf(conditionalPoints, sgIdxX, sgIdxY, sgIdxZ);
		}
		//std::cout << std::endl;
	}
	return foundValue;
}
