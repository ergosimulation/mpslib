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
#include <map>

#include "MPSAlgorithm.h"

namespace MPS {
	class ENESIM;
	class Coords3D;
}

/**
* @brief An implementation of the ENESIM algorithm
*/
class MPS::ENESIM :
	public MPS::MPSAlgorithm
{
private:

protected:

	/**
	* @brief maximum number of counts setting up conditional pdf
	*/
	int _nMaxCountCpdf = 1;
	
	/**
	* @brief Select whether to use Metropolis style soft data conditioning
	*/
	int _RejectionSoftData; // = 0;
	//_RejectionSoftData = 1;

	/**
	* @brief Distance measure comparing a template in TI and simulation grid
	*/
	int _distance_measure=1; // PIXEL distance
	// int _distance_measure=1; // EUCLIDEANS

	/**
	* @brief Distance threshold to accept a matching template
	*/
	float _distance_threshold=0.01;//0.01;

	/**
	* @brief Distance power order
	*/
	float _distance_power_order=0; // power order

	/**
	* @brief Maximum Search Radius HARD data
	*/
	float _maxSearchRadius=0; 

		
	/**
	* @brief Maximum Search Radius SOFT data
	*/
    float _maxSearchRadius_soft = 1e+9;
	
	/**
	* @brief Maximum number conditioning SOFT data
	*/
	int _maxNeighbours_soft = 3;


	/**
	* @brief Co-locate Dimension, if used
	*/
	int _ColocatedDimension = 0;


	/**
	* @brief Read configuration file
	* @param fileName configuration filename
	*/
	void _readConfigurations(const std::string& fileName);


	/**
	* @brief Compute cpdf from training image using ENESIM type
	* @param x coordinate X of the current node, pdf1
	* @param y coordinate Y of the current node, pdf2 (map must contain ALL possible outcome values)
	* @param map with conditional pdf
	* @param z coordinate Z of the current node
	* @return true if found a value
	*/
	bool _getCpdEnesim(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, std::map<float, float>& cPDF, float& SoftProbability);

	/**
	* @brief Compbine two PDFs assuming independence
	* @param probability density 1, pdf1
	* @param probability density 2, pdf2
	* @return true if succesfull, and update pdf is available in pdf1
	*/
	bool _combinePdf(std::map<float, float>& cPdf, std::map<float, float>& softPdf);


	/**
	* @brief Compute realization using cpdf obtained using ENESIM and softdata
	* @param sgIdxX coordinate X of the current node
	* @param sgIdxY coordinate Y of the current node
	* @param sgIdxZ coordinate Z of the current node
	* @param iterationCnt Iterations counter
	* @return simulated value
	*/
	//float _getRealizationFromCpdfTiEnesim(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, float& iterationCnt);

	/**
	* @brief Compute realization using cpdf obtained using ENESIM and Metropolis with soft data
	* @param sgIdxX coordinate X of the current node
	* @param sgIdxY coordinate Y of the current node
	* @param sgIdxZ coordinate Z of the current node
	* @param iterationCnt Iterations counter
	* @return simulated value
	*/
	//float _getRealizationFromCpdfTiEnesimRejection(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, float& iterationCnt);

	/**
	* @brief Compute realization using cpdf obtained using ENESIM and Metropolis with NON-colocated soft data
	* @param sgIdxX coordinate X of the current node
	* @param sgIdxY coordinate Y of the current node
	* @param sgIdxZ coordinate Z of the current node
	* @param iterationCnt Iterations counter
	* @return simulated value
	*/
	float _getRealizationFromCpdfEnesim(const int& sgIdxX, const int& sgIdxY, const int& sgIdxZ, float& iterationCnt);

	/**
	* @brief Compute distance between conditional data in TI and template L
	* @param TIi_dxX coordinate X of the current node in TI
	* @param TIi_dxY coordinate Y of the current node in TI
	* @param TIi_dxZ coordinate Z of the current node in TI
	* @return distance
	*/
	float _computeDistanceLV_TI(std::vector<MPS::Coords3D>& L, std::vector<float>& V, const int& TI_idxX, const int& TI_idxY, const int& TI_idxZ);
	
public:
	/**
	* @brief Constructors default and empty parameters
	*/
	ENESIM(void);
	/**
	* @brief Destructors
	*/
	virtual ~ENESIM(void);

};
