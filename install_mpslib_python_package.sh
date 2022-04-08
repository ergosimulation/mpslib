
conda activate base

echo "Removing MPS env"
conda remove --name mps --all

echo "Creating MPS env"
conda create --name mps python=3.9

sleep 5
echo "Activating MPS env"
conda activate mps

pip install --upgrade

pip install --upgrade jupyterlab \
pyvista panel pythreejs ipygany ipyvtklink itkwidgets\
 matplotlib numpy

pip install --upgrade sphinx nbsphinx sphinx_rtd_theme myst-nb

#pip install scikit-mps