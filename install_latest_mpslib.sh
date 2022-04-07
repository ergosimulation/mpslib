# Install conda environment
#conda remove --name mpslib_test --all
#conda create -y -n mpslib_test python=3.7 numpy matplotlib ipython
#conda activate mpslib_test 
#conda install -y -c conda-forge pyvista


# Get code from GITHUB
rm -fr mpslib && git clone https://github.com/ergosimulation/mpslib.git
cd mpslib
make clean
make

# install scikit-mps
cd scikit-mps
pip install -e .

# Test installation
python -c "import mpslib as mps;O=mps.mpslib()"
