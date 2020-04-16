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

#include <limits>
#include "Coords3D.h"

namespace MPS {
	class Coords4D;
}

/**
* @brief A 4D coordinates used to keep a 3D coordinate x, y, z and a value v
*/
class MPS::Coords4D: public MPS::Coords3D
{
private:
	/**
	* @brief value
	*/
	float _v;
public:
	/**
	* @brief Constructors
	*
	* Default value is (0, 0, 0, NaN)
	*/
	Coords4D(void);

	/**
	* @brief Constructors from x, y, z and value 
	* @param x x value
	*	@param y y value
	* @param z z value
	* @param v v value default is NaN
	*/
	Coords4D(const int& x, const int& y, const int& z, const float& v=std::numeric_limits<float>::quiet_NaN());

	/**
	* @brief Constructors from a coords3D and a value 
	* @param coord3D a coord3D
	* @param v v value default is NaN
	*/
	Coords4D(const MPS::Coords3D coord3D, const float& v=std::numeric_limits<float>::quiet_NaN());

	/**
	* @brief Destructors
	*/
	~Coords4D(void);

	/**
	* @brief Getter v Value
	* @return x value
	*/
	inline float getValue(void) const {return _v;}

	/**
	* @brief Setter v Value
	* @param v v value
	*/
	inline void setValue(const float& v) {_v = v;}
};

namespace MPS {
	/**
	* @brief Compare two coordinates
	*
	* @param lhs lef hand value
	* @param rhs right hand value
	*
	* @return true if (x, y, z, v) are equals
	*/
	bool operator==(const MPS::Coords4D& lhs, const MPS::Coords4D& rhs);

	/**
	* @brief Compare two coordinates
	*
	* @param lhs lef hand value
	* @param rhs right hand value
	*
	* @return true if (x, y, z, v) are inferior
	*/
	bool operator<(const MPS::Coords4D& lhs, const MPS::Coords4D& rhs);
}

