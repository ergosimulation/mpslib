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
#include "IO.h"
#include "Utility.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <climits>
#include <limits>

namespace MPS {
	namespace io {


		/**
		* @brief check if file exists
		*
		* @param fileName source's file name
		*
		* @return true if filename exists
		*/
		bool file_exist(const std::string& fileName)
		{
    	std::ifstream infile(fileName);
    	return infile.good();
		}

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
		bool readTIFromGSLIBFile(const std::string& fileName, std::vector<std::vector<std::vector<float>>>& ti, const int& channelIdx, const float& meanFactor) {
			int nanValGslib = -997799;
			std::ifstream file;
			file.open(fileName, std::ios::in);
			if (!file.is_open()) {
				// debig information should be written from function that calls readTI..
				// std::cerr << "Can't open " << fileName << " !\n";
				return false;
			}

			std::string str;
			//Header
			getline(file, str);
			//cout << str << endl;
			std::stringstream ss(str);
			std::string s;
			std::vector<int> dimensions;
			while (getline(ss, s, ' ')) {
				if(!s.empty()) {
					dimensions.push_back(stoi(s));
				}
			}
			//std::cout << dimensions[0] << " " << dimensions[1] << " " << dimensions[2] << std::endl;

			//Number of channel
			getline(file, str);
			//cout << str << endl;
			int numberOfChannels = stoi(str);

			//Channel labels ...
			for (int i=0; i<numberOfChannels; i++) {
				getline(file, str);
				//cout << str << endl;
			}

			//Initialize TI dimensions
			ti.resize(dimensions[2]);
			for(int i=0; i<dimensions[2]; i++) {
				ti[i].resize(dimensions[1]);
				for(int j=0; j<dimensions[1]; j++) {
					ti[i][j].resize(dimensions[0]);
				}
			}

			//Putting data inside
			int dataCnt = 0, idxX = 0, idxY = 0, idxZ;
			float dataValue;
			while (getline(file, str)) {
				if (numberOfChannels == 1) dataValue = stof(str); //only 1 channel
				else if (numberOfChannels > 1) {
					std::vector<float> data;
					std::stringstream ss(str);
					while (getline(ss, s, ' ')) {
						if(!s.empty()) {
							data.push_back(stof(s));
						}
					}
					if (channelIdx == -1) { //Average
						dataValue = 0;
						for (unsigned int i=0; i<data.size(); i++) {
							dataValue += data[i];
						}
						dataValue /= data.size();
					} else {
						dataValue = data[channelIdx];
					}
				} else {
					dataValue = 0; //Put 0 if get no channel
				}
				MPS::utility::oneDTo3D(dataCnt, dimensions[0], dimensions[1], idxX, idxY, idxZ);	
				if (dataValue==nanValGslib) {
					// if nanValGslib is found, set it as NaN
					ti[idxZ][idxY][idxX]  = std::numeric_limits<float>::quiet_NaN() ;
				} else {
					ti[idxZ][idxY][idxX] = dataValue / meanFactor;
				}

				dataCnt ++;
			}
			return true;
		}

		/**
		* @brief Read a GS3D csv file and put data inside a training image
		*
		* @param fileName source's file name
		* @param ti the training image
		*
		* @return true if the reading process is sucessful
		*/
		bool readTIFromGS3DCSVFile(const std::string& fileName, std::vector<std::vector<std::vector<float>>>& ti) {
			std::ifstream file;
			file.open(fileName, std::ios::in);
			if (!file.is_open()) {
			  //std::cerr << "Can't open " << fileName << " !\n";
			  return false;
			}

			int tiSizeX, tiSizeY, tiSizeZ;
			float minWorldX, minWorldY, minWorldZ;
			float stepX, stepY, stepZ;

			std::string str;
			//voxel size
			//X
			getline(file, str);
			tiSizeX = std::stoi(str);
			//Y
			getline(file, str);
			tiSizeY = std::stoi(str);
			//Z
			getline(file, str);
			tiSizeZ = std::stoi(str);
			//Min world coordinates
			//X
			getline(file, str);
			minWorldX = std::stof(str);
			//Y
			getline(file, str);
			minWorldY = std::stof(str);
			//Z
			getline(file, str);
			minWorldZ = std::stof(str);
			//Voxel size
			//X
			getline(file, str);
			stepX = std::stof(str);
			//Y
			getline(file, str);
			stepY = std::stof(str);
			//Z
			getline(file, str);
			stepZ = std::stof(str);
			//Header (X, Y, Z, Value)
			//getline(file, str);
			//cout << str << endl;
			std::stringstream ss(str);
			std::string s;

			//Data
			//Initialize TI dimensions, data cell is initialize to nan
			ti.resize(tiSizeZ);
			for(int i=0; i<tiSizeZ; i++) {
				ti[i].resize(tiSizeY);
				for(int j=0; j<tiSizeY; j++) {
					ti[i][j].resize(tiSizeX, std::numeric_limits<float>::quiet_NaN());
				}
			}

			//Putting data inside
			int idxX = 0, idxY = 0, idxZ;
			float coordX, coordY, coordZ, dataValue;
			while (getline(file, str)) {
				//Read a line and keep values into vector data
				std::vector<float> data;
				std::stringstream ss(str);
				while (getline(ss, s, ';')) {
					if(!s.empty()) {
						data.push_back(stof(s));
					}
				}

				//Convert data read from world coordinate into local coordinate (start from 0, 0, 0 and cell size 1, 1, 1)
				coordX = data[0];
				coordY = data[1];
				coordZ = data[2];
				dataValue = data[3];
				idxX = (int)((coordX - minWorldX) / stepX);
				idxY = (int)((coordY - minWorldY) / stepY);
				idxZ = (int)((coordZ - minWorldZ) / stepZ);
				ti[idxZ][idxY][idxX] = dataValue;
			}
			return true;
		}

		/**
		* @brief Read a GS3D grd3 file and put data inside a training image
		*
		* @param fileName source's file name
		* @param ti the training image
		*
		* @return true if the reading process is sucessful
		*/
		bool readTIFromGS3DGRD3File(const std::string& fileName, std::vector<std::vector<std::vector<float>>>& ti) {
			std::ifstream file;
			file.open(fileName, std::ios::binary);
			if (!file.is_open()) {
				//std::cerr << "Can't open " << fileName << " !\n";
				return false;
			}
			int tiSizeX, tiSizeY, tiSizeZ;
			double minWorldX, minWorldY, minWorldZ;
			double stepX, stepY, stepZ;
			double blankValue;
			char buff[8];
			int valueType;
			int arrayValueSize[4] = {4, 8, 1, 2};
			//ID
			file.read(buff, 4);
			//Version
			file.read(buff, 4);
			//HeaderSize
			file.read(buff, 4);
			//Grid value type
			file.read((char *)&valueType, 4);
			//Blank value
			file.read((char *)&blankValue, 8);
			//Node X
			file.read((char *)&tiSizeX, 4);
			//Node Y
			file.read((char *)&tiSizeY, 4);
			//Node Z
			file.read((char *)&tiSizeZ, 4);
			//Min X
			file.read((char *)&minWorldX, 8);
			//Min Y
			file.read((char *)&minWorldY, 8);
			//Min Z
			file.read((char *)&minWorldZ, 8);
			//Size X
			file.read((char *)&stepX, 8);
			//Size Y
			file.read((char *)&stepY, 8);
			//Size Z
			file.read((char *)&stepZ, 8);
			//Min Value
			file.read(buff, 8);
			//Max Value
			file.read(buff, 8);

			//Data
			//Initialize TI dimensions, data cell is initialize to nan
			ti.resize(tiSizeZ);
			for(int i=0; i<tiSizeZ; i++) {
				ti[i].resize(tiSizeY);
				for(int j=0; j<tiSizeY; j++) {
					ti[i][j].resize(tiSizeX, std::numeric_limits<float>::quiet_NaN());
				}
			}

			//Putting data inside
			int valueSize = arrayValueSize[valueType];
			char dataChar;
			short dataShort;
			float dataSingle;
			double dataDouble;
			for (int z=0; z<tiSizeZ; z++) {
				for (int y=0; y<tiSizeY; y++) {
					for (int x=0; x<tiSizeX; x++) {
						if(valueSize == 1) {
							file.read((char *)&dataChar, valueSize);
							if((double)dataChar != blankValue && (float)dataChar >= 0) ti[z][y][x] = (float)dataChar;
						} else if(valueSize == 2) {
							file.read((char *)&dataShort, valueSize);
							if((double)dataShort != blankValue  && (float)dataShort >= 0) ti[z][y][x] = (float)dataShort;
						} else if(valueSize == 4) {
							file.read((char *)&dataSingle, valueSize);
							if((double)dataSingle != blankValue  && (float)dataSingle >= 0) ti[z][y][x] = (float)dataSingle;
						} else {
							file.read((char *)&dataDouble, valueSize);
							if((double)dataDouble != blankValue  && (float)dataDouble >= 0) ti[z][y][x] = (float)dataDouble;
						}
					}
				}
			}

			return true;
		}

		/**
		* @brief Read a EAS file and put in hard data grid
		*
		* @param fileName source's file name
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
		bool readHardDataFromEASFile(const std::string& fileName,  const float& noDataValue,
			const int& dataSizeX, const int& dataSizeY, const int& dataSizeZ,
			const float& minWorldX, const float& minWorldY, const float& minWorldZ,
			const float& stepX, const float& stepY, const float& stepZ,
			std::vector<std::vector<std::vector<float>>>& data) {
				std::ifstream file;
				file.open(fileName, std::ios::in);
				if (!file.is_open()) {
					// std::cerr << "Can't open " << fileName << " !\n";
					return false;
				}


				std::string str;
				//TITLE
				getline(file, str);
				//Number of column
				int numberOfColumns;
				getline(file, str);
				numberOfColumns = std::stoi(str);
				//Column title
				for (int i=0; i<numberOfColumns; i++) {
					getline(file, str);
				}
				//Header (X, Y, Z, Value)
				//getline(file, str);
				//cout << str << endl;
				std::stringstream ss(str);
				std::string s;


				//Data
				//Initialize TI dimensions, data cell is initialize to nan
				data.resize(dataSizeZ);
				for(int i=0; i<dataSizeZ; i++) {
					data[i].resize(dataSizeY);
					for(int j=0; j<dataSizeY; j++) {
						data[i][j].resize(dataSizeX, std::numeric_limits<float>::quiet_NaN());
					}
				}

				//Putting data inside
				int dataCnt=0, idxX = 0, idxY = 0, idxZ;
				float coordX, coordY, coordZ, dataValue;
				while (getline(file, str)) {
					//Read a line and keep values into vector data
					std::vector<float> lineData;
					std::stringstream ss(str);
					while (getline(ss, s, ' ')) {
						if(!s.empty()) {
							lineData.push_back(stof(s));
						}
					}

					if (numberOfColumns >= 4) { //XYZD file
						//Convert data read from world coordinate into local coordinate (start from 0, 0, 0 and cell size 1, 1, 1)
						coordX = lineData[0];
						coordY = lineData[1];
						coordZ = lineData[2];
						dataValue = lineData[3];
						idxX = (int)((coordX - minWorldX) / stepX);
						idxY = (int)((coordY - minWorldY) / stepY);
						idxZ = (int)((coordZ - minWorldZ) / stepZ);



						//_sgDimX
						if(dataValue != noDataValue) {
							if ((idxX>-1)&(idxY>-1)&(idxZ>-1)&(idxX<dataSizeX)&(idxY<dataSizeY)&(idxZ<dataSizeZ)) {
								data[idxZ][idxY][idxX] = dataValue;
							} else {
								std::cout << "Hard data, "<< fileName << ": Data outside simulation grid ix,iy,iz=" << idxX << " "<< idxY << " "<< idxZ  << std::endl;
							}
						}
					} else { //Single column file
						MPS::utility::oneDTo3D(dataCnt++, dataSizeX, dataSizeY, idxX, idxY, idxZ);
						dataValue = lineData[0];
						if(dataValue != noDataValue) data[idxZ][idxY][idxX] = dataValue;
					}
				}
				return true;
		}

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
			std::vector<std::vector<std::vector<std::vector<float>>>>& data) {
				std::ifstream file;
				file.open(fileName, std::ios::in);
				if (!file.is_open()) {
				        // std::cerr << "Can't open " << fileName << " !\n";
					return false;
				}

				std::string str;
				//TITLE
				getline(file, str);
				//Number of column
				int numberOfColumns;
				getline(file, str);
				numberOfColumns = std::stoi(str);
				//Column title
				for (int i=0; i<numberOfColumns; i++) {
					getline(file, str);
				}
				//Header (X, Y, Z, Value)
				//getline(file, str);
				//cout << str << endl;
				std::stringstream ss(str);
				std::string s;

				//Data
				//Initialize softdata dimensions, data cell is initialize to nan
				data.resize(categories.size());
				for (unsigned int nbCats=0; nbCats<categories.size(); nbCats++) {
					data[nbCats].resize(dataSizeZ);
					for(int i=0; i<dataSizeZ; i++) {
						data[nbCats][i].resize(dataSizeY);
						for(int j=0; j<dataSizeY; j++) {
							data[nbCats][i][j].resize(dataSizeX, std::numeric_limits<float>::quiet_NaN());
						}
					}
				}

				
				//Putting data inside
				int dataCnt=0, idxX = 0, idxY = 0, idxZ;
				float coordX, coordY, coordZ;
				while (getline(file, str)) {
					//Read a line and keep values into vector data
					std::vector<float> lineData;
					std::stringstream ss(str);
					while (getline(ss, s, ' ')) {
						if(!s.empty()) {
							lineData.push_back(stof(s));
						}
					}


					if (numberOfColumns > categories.size()) { //XYZD file
						//Convert data read from world coordinate into local coordinate (start from 0, 0, 0 and cell size 1, 1, 1)
						coordX = lineData[0];
						coordY = lineData[1];
						coordZ = lineData[2];
						idxX = (int)((coordX - minWorldX) / stepX);
						idxY = (int)((coordY - minWorldY) / stepY);
						idxZ = (int)((coordZ - minWorldZ) / stepZ);

						for (unsigned int nbCats=0; nbCats<categories.size(); nbCats++) {
							if ((idxX>-1)&(idxY>-1)&(idxZ>-1)&(idxX<dataSizeX)&(idxY<dataSizeY)&(idxZ<dataSizeZ)) {
							  data[nbCats][idxZ][idxY][idxX] = lineData[nbCats + 3];
							} else {
								std::cout << "Soft data, "<< fileName << ": Data outside simulation grid ix,iy,iz=" << idxX << " "<< idxY << " "<< idxZ  << std::endl;
							}
						}
					} else { //Single column file
						MPS::utility::oneDTo3D(dataCnt++, dataSizeX, dataSizeY, idxX, idxY, idxZ);
						for (unsigned int nbCats=0; nbCats<categories.size(); nbCats++) {
							data[nbCats][idxZ][idxY][idxX] = lineData[nbCats];
							//std::cout << nbCats << " "<< data[nbCats][idxZ][idxY][idxX] << std::endl;
						}
					}
				}
				return true;
		}

		/**
		* @brief Write simulation 3D grid result into file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		*/
		void writeToGSLIBFile(const std::string& fileName, const std::vector<std::vector<std::vector<float>>>& sg, const int& sgDimX, const int& sgDimY, const int& sgDimZ) {
			int nanValGslib = -997799;
			std::ofstream aFile (fileName);
			// Header
			aFile << sgDimX << " " << sgDimY << " " << sgDimZ << std::endl;
			aFile << 1 << std::endl;
			aFile << "v" << std::endl;
			for (int z=0; z<sgDimZ; z++) {
				for (int y=0; y<sgDimY; y++) {
					for (int x=0; x<sgDimX; x++) {
						if (MPS::utility::is_nan(sg[z][y][x])) {
							aFile << nanValGslib << " ";
						}
						else {
							aFile << sg[z][y][x] << " ";
						}
					}
				}
			}


			// Close the file stream explicitly
			aFile.close();
		}

		/**
		* @brief Write multiple simulation 3D grid (af 4D grid) result into a GSlib file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 4D float vector
		* @param sgDimX dimension X of SG
		* @param sgDimY dimension Y of SG
		* @param sgDimZ dimension Z of SG
		* @param sgN number of 3D realizations
		*/
		void writeToGSLIBFile(const std::string& fileName, const std::vector<std::vector<std::vector<std::vector<float>>>>& sg, const int& sgDimX, const int& sgDimY, const int& sgDimZ, const int& sgN) {
			int nanValGslib = -997799;
			std::ofstream aFile(fileName);
			// Header
			aFile << sgDimX << " " << sgDimY << " " << sgDimZ << std::endl;
			aFile << sgN << std::endl;
			for (int ic = 0; ic < sgN; ic++) {
				aFile << "v" << ic << std::endl;
			}
			for (int z = 0; z<sgDimZ; z++) {
				for (int y = 0; y<sgDimY; y++) {
					for (int x = 0; x<sgDimX; x++) {
						for (int i = 0; i<sgN; i++) {
							//std::cout << "i=" << i << "/"<< sgN << std::endl;
							if (MPS::utility::is_nan(sg[i][z][y][x])) {
								aFile << nanValGslib << " ";
							}
							else {
								aFile << sg[i][z][y][x] << " ";
							}
						}
						aFile << std::endl;
					}
				}
			}
			// Close the file stream explicitly
			aFile.close();
		}


		/**
		* @brief Write indices array into a file
		*
		* @param fileName destination's file name
		* @param iVector the index array which is a integer vector
		* @param dimX dimension X of iVector
		* @param dimY dimension Y of iVector
		* @param dimZ dimension Z of iVector
		*/
		void writeToGSLIBFile(const std::string& fileName, const std::vector<int>& iVector, const int& dimX, const int& dimY, const int& dimZ) {
			std::ofstream aFile (fileName);
			// Header
			aFile << dimX << " " << dimY << " " << dimZ << std::endl;
			aFile << 1 << std::endl;
			aFile << "v" << std::endl;
			int cnt = 0;
			for (int z=0; z<dimZ; z++) {
				for (int y=0; y<dimY; y++) {
					for (int x=0; x<dimX; x++) {
						aFile << iVector[cnt++] << std::endl;
					}
				}
			}
			// Close the file stream explicitly
			aFile.close();
		}

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
			const float& minWorldX, const float& minWorldY, const float& minWorldZ,
			const float& stepX, const float& stepY, const float& stepZ) {
				std::ofstream aFile (fileName);
				// Header
				aFile << "X;Y;Z;Value" << std::endl;
				for (int z=0; z<sgDimZ; z++) {
					for (int y=0; y<sgDimY; y++) {
						for (int x=0; x<sgDimX; x++) {
							aFile << x*stepX + minWorldX <<";" << y*stepY + minWorldY <<";" << z*stepZ + minWorldZ <<";" << sg[z][y][x] << std::endl;
						}
					}
				}

				// Close the file stream explicitly
				aFile.close();
		}

		/**
		* @brief Write simulation 3D grid result into an ASCII file
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
			const float& minWorldX, const float& minWorldY, const float& minWorldZ,
			const float& stepX, const float& stepY, const float& stepZ) {
				std::ofstream aFile (fileName);
				// Header
				aFile << sgDimX << std::endl;
				aFile << sgDimY << std::endl;
				aFile << sgDimZ << std::endl;
				aFile << minWorldX << std::endl;
				aFile << minWorldY << std::endl;
				aFile << minWorldZ << std::endl;
				aFile << stepX << std::endl;
				aFile << stepY << std::endl;
				aFile << stepZ << std::endl;
				for (int z=0; z<sgDimZ; z++) {
					for (int y=0; y<sgDimY; y++) {
						for (int x=0; x<sgDimX; x++) {
							aFile << x*stepX + minWorldX <<";" << y*stepY + minWorldY <<";" << z*stepZ + minWorldZ <<";" << sg[z][y][x] << std::endl;
						}
					}
				}

				// Close the file stream explicitly
				aFile.close();
		}

		/**
		* @brief Write simulation 3D grid result into an ASCII file
		*
		* @param fileName destination's file name
		* @param sg the simulation grid which is a 3D float vector
		*/
		void writeToASCIIFile(const std::string& fileName, const std::vector<float>& d) {
			std::ofstream aFile (fileName);
			int N=d.size();
			for (int i=0; i<N; i++) {
				aFile << d[i] << std::endl;
			}
	
		
		}
		


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
			const float& minWorldX, const float& minWorldY, const float& minWorldZ,
			const float& stepX, const float& stepY, const float& stepZ, const int& valueType) {
				std::ofstream file (fileName, std::ios::out | std::ios::binary);

				//ID
				char id[4] = {'G', 'R', 'D', '3'};
				file.write(id, 4);
				//Version
				int version = 1;
				file.write(reinterpret_cast<const char *>(&version), 4);
				//HeaderSize
				int headerSize = 100;
				file.write(reinterpret_cast<const char *>(&headerSize), 4);
				//Grid value type
				file.write(reinterpret_cast<const char *>(&valueType), 4);
				//Blank value
				file.write(reinterpret_cast<const char *>(&gs3Dgrd3BlankFloat), 8); //Not used in GS3D...
				//Node X
				file.write(reinterpret_cast<const char *>(&sgDimX), 4);
				//Node Y
				file.write(reinterpret_cast<const char *>(&sgDimY), 4);
				//Node Z
				file.write(reinterpret_cast<const char *>(&sgDimZ), 4);
				//Min X
				double dMinWorldX = (double)minWorldX;
				file.write(reinterpret_cast<const char *>(&dMinWorldX), 8);
				//Min Y
				double dMinWorldY = (double)minWorldY;
				file.write(reinterpret_cast<const char *>(&dMinWorldY), 8);
				//Min Z
				double dMinWorldZ = (double)minWorldZ;
				file.write(reinterpret_cast<const char *>(&dMinWorldZ), 8);
				//Size X
				double dStepX = (double)stepX;
				file.write(reinterpret_cast<const char *>(&dStepX), 8);
				//Size Y
				double dStepY = (double)stepY;
				file.write(reinterpret_cast<const char *>(&dStepY), 8);
				//Size Z
				double dStepZ = (double)stepZ;
				file.write(reinterpret_cast<const char *>(&dStepZ), 8);

				//Get min/max value
				//TODO this can be done faster by passing through parameters ...
				float min = INT_MAX;
				float max = INT_MIN;
				for (int z=0; z<sgDimZ; z++) {
					for (int y=0; y<sgDimY; y++) {
						for (int x=0; x<sgDimX; x++) {
							min = sg[z][y][x] < min && !MPS::utility::is_nan(sg[z][y][x])? sg[z][y][x] : min;
							max = sg[z][y][x] > max && !MPS::utility::is_nan(sg[z][y][x])? sg[z][y][x] : max;
						}
					}
				}

				//Min Value
				double minValue = min;
				file.write(reinterpret_cast<const char *>(&minValue), 8);
				//Max Value
				double maxValue = max;
				file.write(reinterpret_cast<const char *>(&maxValue), 8);

				//Data
				//Putting data inside
				int arrayValueSize[4] = {4, 8, 1, 2};
				int valueSize = arrayValueSize[valueType];
				double dataDouble;
				int dataInt;
				short dataShort;
				char dataChar;
				for (int z=0; z<sgDimZ; z++) {
					for (int y=0; y<sgDimY; y++) {
						for (int x=0; x<sgDimX; x++) {
							if(valueSize == 1) {
								if (MPS::utility::is_nan(sg[z][y][x])) {
									dataChar = (char)gs3Dgrd3BlankByte;									
								}
								else {
									dataChar = (char)sg[z][y][x];
								}
								file.write(reinterpret_cast<const char*>(&dataChar), valueSize);
							} else if(valueSize == 2) {
								if (MPS::utility::is_nan(sg[z][y][x])) {
									dataShort = (short)gs3Dgrd3BlankWord;
								}
								else {
									dataShort = (short)sg[z][y][x];
								}
								file.write(reinterpret_cast<const char*>(&dataShort), valueSize);
							} else if(valueSize == 4) {
								if (MPS::utility::is_nan(sg[z][y][x])) {
									dataInt = (int)gs3Dgrd3BlankAscii;
								}
								else {
									dataInt = (int)sg[z][y][x];
								}
								file.write(reinterpret_cast<const char*>(&dataInt), valueSize);
							} else {
								if (MPS::utility::is_nan(sg[z][y][x])) {
									dataDouble = (double)gs3Dgrd3BlankFloat;
								}
								else {
									dataDouble = (double)sg[z][y][x];
								}
								file.write(reinterpret_cast<const char*>(&dataDouble), valueSize);
							}
						}
					}
				}

				// Close the file stream explicitly
				file.close();
		}
	}
}
