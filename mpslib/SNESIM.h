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
#pragma once

#include <iostream>
#include <vector>
#include <map>
#include <string>

#include "MPSAlgorithm.h"
#include "Coords4D.h"
#include "Utility.h"

namespace MPS {
	class SNESIM;
	class Coords3D;
}

/**
* @brief Abstrat class of SNESIM implementation
*/
class MPS::SNESIM :
	public MPS::MPSAlgorithm
{
protected:

	/**
	* @brief Class using to sort by 3D distance element in a list
	*/
	class TemplateSorter {
		int _templateSizeX;
		int _templateSizeY;
		int _templateSizeZ;
	public:
		TemplateSorter(const int& templateSizeX, const int& templateSizeY, const int& templateSizeZ) : _templateSizeZ(templateSizeZ), _templateSizeY(templateSizeY), _templateSizeX(templateSizeX) {}
		bool operator()(const int& idx1, const int& idx2) const {
			int idx1X, idx1Y, idx1Z, idx2X, idx2Y, idx2Z;
			int templateCenterX = (int)floor(_templateSizeX / 2);
			int templateCenterY = (int)floor(_templateSizeY / 2);
			int templateCenterZ = (int)floor(_templateSizeZ / 2);
			MPS::utility::oneDTo3D(idx1, _templateSizeX, _templateSizeY, idx1X, idx1Y, idx1Z);
			MPS::utility::oneDTo3D(idx2, _templateSizeX, _templateSizeY, idx2X, idx2Y, idx2Z);
			return (pow(idx1X - templateCenterX, 2) + pow(idx1Y - templateCenterY, 2) + pow(idx1Z - templateCenterZ, 2)) < (pow(idx2X - templateCenterX, 2) + pow(idx2Y - templateCenterY, 2) + pow(idx2Z - templateCenterZ, 2));
		}
	};

	/**
	* @brief Read configuration file
	* @param fileName configuration filename
	*/
	void _readConfigurations(const std::string& fileName);

	/**
	* @brief Construct templatefaces and sort them around template center
	* @param sizeX template size X
	* @param sizeY template size Y
	* @param sizeZ template size Z
	*/
	void _constructTemplateFaces(const int& sizeX, const int& sizeY, const int& sizeZ);

	/**
	* @brief Getting a node value by calculating the cummulatie probability distribution function
	* @param conditionalPoints list of all found conditional points
	* @param x coordinate X of the current node
	* @param y coordinate Y of the current node
	* @param z coordinate Z of the current node
	*/
	float _cpdf(std::map<float, int>& conditionalPoints, const int& x, const int& y, const int& z);

	/**
	* @brief patterns dictionary
	*/
	std::vector<std::map<std::vector<float>, int>> _patternsDictionary;

	/**
	* @brief template size X
	*/
	int _templateSizeX;


	/**
	* @brief template size y
	*/
	int _templateSizeY;

	/**
	* @brief template size z
	*/
	int _templateSizeZ;

	/**
	* @brief template size X (mulgrid 0)
	* @brief template size Y (mulgrid 0)
	* @brief template size Z (mulgrid 0)
	*/
	int _templateSizeX_base;
	int _templateSizeY_base;
	int _templateSizeZ_base;

	/**
	* @brief Min node count allowed
	*/
	int _minNodeCount = 0;

	/**
	* @brief List of available faces in the template
	*/
	std::vector<MPS::Coords3D> _templateFaces;
public:
	/**
	* @brief Constructors default and empty parameters
	*/
	SNESIM(void);
	/**
	* @brief Destructors
	*/
	virtual ~SNESIM(void);
};
