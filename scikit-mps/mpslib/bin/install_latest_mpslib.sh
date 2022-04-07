# Get code from GITHUB
rm -fr mpslib && git clone https://github.com/ergosimulation/mpslib.git
cd mpslib
make clean
make

cp mps_genesim* ../.
cp mps_snesim_tree* ../.
cp mps_snesim_list* ../.

