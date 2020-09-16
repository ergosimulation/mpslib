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

#include <vector>
#include <string>

namespace MPS {
	/**
	* @brief Utility package which contains utility functions used in simulation algorithms
	*
	* Functions used to do data conversion, checking ...
	*
	*/
	namespace utility {
		/**
		* @brief Check if a value is NAN
		* 
		* @param x value to check
		*
		* @return true if the input value is NAN
		*/
		bool is_nan(const float &x); 

		/**
		* @brief Convert 1D index to 3D index
		* 
		* @param oneDIndex index of the 1D array
		* @param dimX dimension X of the 3D array 
		* @param dimY dimension Y of the 3D array
		* @param idxX output index X
		* @param idxY output index Y
		* @param idxZ output index Z
		*/
		void oneDTo3D(const int& oneDIndex, const int& dimX, const int& dimY, int& idxX, int& idxY, int& idxZ);

		/**
		* @brief Convert 3D index to 1D index
		* 
		* @param idxX index X of the 3D array
		* @param idxY index Y of the 3D array
		* @param idxZ index Z of the 3D arary
		* @param dimX dimension X of the 3D array 
		* @param dimY dimension Y of the 3D array
		* @param oneDIndex output index of the 1D array
		*/
		void treeDto1D(const int& idxX, const int& idxY, const int& idxZ, const int& dimX, const int& dimY, int& oneDIndex);

		/**
		* @brief Convert seconds to hour minute second
		* 
		* @param seconds seconds
		* @param hour output hour
		* @param minute output minute
		* @param second output second
		*/
		void secondsToHrMnSec(const int& seconds, int& hour, int& minute, int& second);

		/**
		* @brief Limit a value, could be clamp it or wrap around
		* 
		* @param aValue input value
		* @param maxValue the maximum value that aValue could have
		* @param wrapAround if true then if aValue is greater than maxValue, it will be modulo with the maxValue. If false the aValue will be clamp to maxValue
		*/
		void limitValue(int& aValue, const int& maxValue, const bool& wrapAround=true);

		/**
		* @brief Get a random value from a voxel grid
		* 
		* @param ti the 3D grid
		* @param tiDimX grid size X
		* @param tiDimY grid size Y
		* @param tiDimZ grid size Z
		*
		* @return a random value from the grid
		*/
		float getRandomValue(const std::vector<std::vector<std::vector<float>>>& ti, const int& tiDimX, const int& tiDimY, const int& tiDimZ);

		/**
		* @brief Get a file extension
		* 
		* @param filename the file name
		*
		* @return filename extension
		*/
		std::string getExtension(const std::string& filename);
	}
}
