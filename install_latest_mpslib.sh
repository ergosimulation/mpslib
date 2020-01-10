# Get code from GITHUB
rm -fr mpslib && git clone https://github.com/ergosimulation/mpslib.git
cd mpslib
make

# install scikit-mps
cd scikit-mps
pip install .
#pip install pyvista

