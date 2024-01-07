#!/usr/bin/bash

# CaboCha
sh /workspace/setup/setup-cabocha.sh

# Python
rye sync --no-lock

# CaboCha-Python
source /workspace/.venv/bin/activate
python /home/odakas/cabocha-0.69/python/setup.py install

# R
Rscript /workspace/setup-renv.R 

# Julia
julia --project='/workspace' -e 'using Pkg; Pkg.instantiate(); Pkg.build("IJulia")'

# Node.js
npm install

# Jupyter
bash /workspace/setup/update-jupyter-template.sh
