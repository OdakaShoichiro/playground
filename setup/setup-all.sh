#!/usr/bin/bash

# CaboCha
sh /workspace/setup/setup-cabocha.sh

# Python
rye sync --no-lock

# CaboCha-Python
source /workspace/.venv/bin/activate
cd /home/odakas/cabocha-0.69/python/
# cp /workspace/src/CaboCha.py .
python setup.py install
cd /workspace

# R
Rscript /workspace/setup-renv.R 

# Julia
julia --project='/workspace' -e 'using Pkg; Pkg.instantiate(); Pkg.build("IJulia")'

# Node.js
npm install

# Jupyter
bash /workspace/setup/update-jupyter-template.sh
