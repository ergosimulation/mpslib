rm -fr build/; 
rm -fr dist/;
python setup.py sdist 
python setup.py bdist_wheel

# Twine test and upload pypi packages
twine check dist/*
# twine upload --repository testpypi dist/* --verbose
# twine upload --repository pypi dist/* --verbose