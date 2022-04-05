# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = MPSlib
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

nb:
	git add Notebooks/mpslib_in_google_colab.ipynb
	git add Notebooks/ex01_mpslib_getting_started.ipynb
	git add Notebooks/ex_mpslib_hard_and_soft.ipynb
	git add Notebooks/ex_mpslib_mask.ipynb
	git add Notebooks/ex_training_images.ipynb 
	git add Notebooks/ex_mpslib_estimation.ipynb
	git add Notebooks/ex_mpslib_entropy.ipynb
	git add Notebooks/ex_snesim_varying_template.ipynb
	git add Notebooks/ex_genesim_distance.ipynb

 PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	rm -f Notebooks/*.ipynb
	ln ../scikit-mps/examples/*.ipynb Notebooks/.
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	nb