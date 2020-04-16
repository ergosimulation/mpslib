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
	* @brief Utility package used for input/output.
	*
	* Functions used to import different file formats into a training image and export a 3D grid into file. It also includes function to draw a 3D grid in the console
	*
	*/

	

	namespace io {
		/**
		* @brief Static predefined char array which is used to represent on the screen
		*/
		static const char *chars[] = {" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
			"a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G", "h", "H",
			"i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N", "p", "P", "q", "Q",
			"r", "R", "s", "S", "t", "T", "u", "U", "v", "v", "w", "W", ",", ";", ".", ":",
			"-", "_", "+", "/", "*", "<", ">", "!", "#", "&", "(", ")", "=", "?"};

		/**
		* @brief An std vector of the static array
		*/
		static const std::vector<std::string> onscreenChars(chars, std::end(chars));

		/**
		* @brief NaN value used when writing GRD3 file to GS3D
		*/
		static const double gs3Dgrd3BlankFloat = 1.701410009187828E+38;

		/**
		* @brief NaN value used when writing GRD3 file to GS3D
		*/
		static const double gs3Dgrd3BlankAscii = -9999;

		/**
		* @brief NaN value used when writing GRD3 file to GS3D
		*/
		static const double gs3Dgrd3BlankByte = 255;

		/**
		* @brief NaN value used when writing GRD3 file to GS3D
		*/
		static const double gs3Dgrd3BlankWord = 65535;

		/**
		* @brief check if file exists
		*
		* @param fileName source's file name
		*
		* @return true if filename exists
		*/
		bool file_exist(const std::string& fileName);

		
		/**
		* @brief Read a GSLIB file and put data inside a training image, multiple channel supported
		*
		* @param fileName source's file name
		* @param ti the training image
		* @param channelIdx which channel to take from the file (-1 in channelIdx means doing the average of all channel)
		* @param meanFactor result read from file will be divided to the meanFactor
		*
		* @return true if the reading process is sucessful
		*/
		bool readTIFromGSLIBFile(const std::string& fileName, std::vector<std::vector<std::vector<float>>>& ti, const int& channelIdx=0, const float& meanFactor=1);

		/**
		* @brief Read a GS3D csv file and put data inside a training image
		*
		* @param fileName source's file name
		* @param ti the training image
		*
		* @return true if the reading process is sucessful
		*/
		bool readTIFromGS3DCSVFile(const std::string& fileName, std::vector<std::vector<std::vector<float>>>& ti);

		/**
		* @brief Read a GS3D grd3 file and put data inside a training image
		*
		* @param fileName source's file name
		* @param ti the training image
		*
		* @return true if the reading process is sucessful
		*/
		bool readTIFromGS3DGRD3File(const std::string& fileName, std::vector<std::vector<std::vector<float>>>& ti);

		/**
		* @brief Read a EAS file and put in hard data grid
		*
		* @param fileName source's file name
		* @param noDataValue no data value
		* @param dataSizeX grid size X
		* @param dataSizeY grid size Y
		* @param dataSizeZ grid size Z
		* @param minWorldX min world coordinate X
		* @param minWorldY min world coordinate Y
		* @param minWorldZ min world coordinate Z
		* @param stepX cell size X
		* @param stepY cell size Y
		* @param stepZ cell size Z
		* @param data reading result
		*
		* @return true if the reading process is sucessful
		*/
		bool readHardDataFromEASFile(const std::string& fileName, const float& noDataValue,
			const int& dataSizeX, const int& dataSizeY, const int& dataSizeZ,
			const float& minWorldX, const float& minWorldY, const float& minWorldZ,
			const float& stepX, const float& stepY, const float& stepZ,
			std::vector<std::vector<std::vector<float>>>& data);

		/**
		* @brief Read a EAS file and put in soft data grid
		*
		* @param fileName source's file name
		* @param categories vector of available categories
		* @param dataSizeX grid size X
		* @param dataSizeY grid size Y
		* @param dataSizeZ grid size Z
		* @param minWorldX min world coordinate X
		* @param minWorldY min world coordinate Y
		* @param minWorldZ min world coordinate Z
		* @param stepX cell size X
		* @param stepY cell size Y
		* @param stepZ cell size Z
		* @param data reading result
		*
		* @return true if the reading process is sucessful
		*/
		bool readSoftDataFromEASFile(const std::string& fileName, const std::vector<float>& categories,
			const int& dataSizeX, const int& dataSizeY, const int& dataSizeZ,
			const float& minWorldX, const float& minWorldY, const float& minWorldZ,
			const float& stepX, const float& stepY, const float& stepZ,
			std::vector<std::vector<std::vector<std::vector<float>>>>& data);

		/**
		* @brief Write simulation 3D grid result into a GSlib file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		*/
		void writeToGSLIBFile(const std::string& fileName, const std::vector<std::vector<std::vector<float>>>& sg, const int& sgDimX, const int& sgDimY, const int& sgDimZ);

		/**
		* @brief Write multiple simulation 3D grid result into a GSlib file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		* @param sgN number of 3D realizations
		*/
		void writeToGSLIBFile(const std::string& fileName, const std::vector<std::vector<std::vector<std::vector<float>>>>& sg, const int& sgDimX, const int& sgDimY, const int& sgDimZ, const int& sgN);
	    

		/**
		* @brief Write indices array into a GSlib file
		*
		* @param fileName destination's file name
		* @param iVector the index array which is an integer vector
		* @param dimX dimension X of iVector
		* @param dimY dimension Y of iVector
		* @param dimZ dimension Z of iVector
		*/
		void writeToGSLIBFile(const std::string& fileName, const std::vector<int>& iVector, const int& dimX, const int& dimY, const int& dimZ);

		/**
		* @brief Write simulation 3D grid result into GS3D csv file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		* @param minWorldX minimal GeoGraphic X coordinate of the TI
		* @param minWorldY minimal GeoGraphic Y coordinate of the TI
		* @param minWorldZ minimal GeoGraphic Z coordinate of the TI
		* @param stepX voxel size in X dimension
		* @param stepY voxel size in Y dimension
		* @param stepZ voxel size in Z dimension
		*/
		void writeToGS3DCSVFile(const std::string& fileName, const std::vector<std::vector<std::vector<float>>>& sg,
			const int& sgDimX, const int& sgDimY, const int& sgDimZ,
			const float& minWorldX=0, const float& minWorldY=0, const float& minWorldZ=0,
			const float& stepX=1, const float& stepY=1, const float& stepZ=1);
		/**
		* @brief Write simulation 3D grid result into a ascii file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		* @param minWorldX minimal GeoGraphic X coordinate of the TI
		* @param minWorldY minimal GeoGraphic Y coordinate of the TI
		* @param minWorldZ minimal GeoGraphic Z coordinate of the TI
		* @param stepX voxel size in X dimension
		* @param stepY voxel size in Y dimension
		* @param stepZ voxel size in Z dimension
		*/
		void writeToASCIIFile(const std::string& fileName, const std::vector<std::vector<std::vector<float>>>& sg,
			const int& sgDimX, const int& sgDimY, const int& sgDimZ,
			const float& minWorldX=0, const float& minWorldY=0, const float& minWorldZ=0,
			const float& stepX=1, const float& stepY=1, const float& stepZ=1);
		/**
		* @brief Write 1D vector to file
		*
		* @param fileName destination's file name
		* @param d, ad 1D vector
		*/
		void writeToASCIIFile(const std::string& fileName, const std::vector<float>& d);
		
		
		/**
		* @brief Write simulation 3D grid result into a GS3D grd3 file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		* @param minWorldX minimal GeoGraphic X coordinate of the TI
		* @param minWorldY minimal GeoGraphic Y coordinate of the TI
		* @param minWorldZ minimal GeoGraphic Z coordinate of the TI
		* @param stepX voxel size in X dimension
		* @param stepY voxel size in Y dimension
		* @param stepZ voxel size in Z dimension
		* @param valueType type of data 0:4byte 1:8byte 2:1byte 3:2byte
		*/
		void writeToGRD3File(const std::string& fileName, const std::vector<std::vector<std::vector<float>>>& sg,
			const int& sgDimX, const int& sgDimY, const int& sgDimZ,
			const float& minWorldX=0, const float& minWorldY=0, const float& minWorldZ=0,
			const float& stepX=1, const float& stepY=1, const float& stepZ=1, const int& valueType=1);
	}
}
