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

namespace MPS {
	class Coords3D;
}


/**
* @brief A 3D coordinates used for indexing in a 3D grid
*/
class MPS::Coords3D
{
private:
	/**
	* @brief x index
	*/
	int _x;

	/**
	* @brief y index
	*/
	int _y;

	/**
	* @brief z index
	*/
	int _z;
public:
	/**
	* @brief Constructors
	*
	* Default value is (0, 0, 0)
	*/
	Coords3D(void);

	/**
	* @brief Constructors from x, y, z
	* @param x x value
	* @param y y value
	* @param z z value
	*/
	Coords3D(const int& x, const int& y, const int& z);

	/**
	* @brief Destructors
	*/
	~Coords3D(void);

	/**
	* @brief Getter X value
	* @return x value
	*/
	inline int getX(void) const {return _x;}

	/**
	* @brief Getter Y value
	* @return y value
	*/
	inline int getY(void) const {return _y;}

	/**
	* @brief Getter Z value
	* @return z value
	*/
	inline int getZ(void) const {return _z;}

	/**
	* @brief Setter X value
	* @param x x value
	*/
	inline void setX(const int& x) {_x = x;}

	/**
	* @brief Setter Y value
	* @param y y value
	*/
	inline void setY(const int& y) {_y = y;}

	/**
	* @brief Setter Z value
	* @param z z value
	*/
	inline void setZ(const int& z) {_z = z;}
};

namespace MPS {
	/**
	* @brief Compare two coordinates
	*
	* @param lhs lef hand value
	* @param rhs right hand value
	*
	* @return true if (x, y, z) are equals
	*/
	bool operator==(const MPS::Coords3D& lhs, const MPS::Coords3D& rhs);
}

