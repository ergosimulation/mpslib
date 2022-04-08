#
# In order to build a package
# 1. compile for linux and move executables to scikit-learn/mpslib/bin.
# 2. compile for windoes and move executables to scikit-learn/mpslib/bin.
# 3. Set the scikit-mps version number on setup.py
# 4. Build the python package using this scipt. 
# 5. Use twine to upload
# 
#
#
rm -fr build/; 
rm -fr dist/;
python setup.py sdist 
python setup.py bdist_wheel

# Twine test and upload pypi packages
twine check dist/*
# twine upload --repository testpypi dist/* --verbose
# twine upload --repository pypi dist/* --verbose

