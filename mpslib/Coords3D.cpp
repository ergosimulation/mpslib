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
#include "Coords3D.h"

/**
* @brief Constructors
*
* Default value is (0, 0, 0)
*/
MPS::Coords3D::Coords3D(void) {
}

/**
* @brief Constructors from x, y, z
* @param x x value
* @param y y value
* @param z z value
*/
MPS::Coords3D::Coords3D(const int& x, const int& y, const int& z) {
	_x = x;
	_y = y;
	_z = z;
}

/**
* @brief Destructors
*/
MPS::Coords3D::~Coords3D(void) {
}

namespace MPS {
	/**
	* @brief Compare two coordinates
	*
	* @param lhs lef hand value
	* @param rhs right hand value
	*
	* @return true if (x, y, z) are equals
	*/
	bool operator==(const MPS::Coords3D& lhs, const MPS::Coords3D& rhs){
		return (lhs.getX() == rhs.getX() && lhs.getY() == rhs.getY() && lhs.getZ() == rhs.getZ());
	}
}
