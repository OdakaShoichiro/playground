#!/usr/bin/bash

# Python
rye sync --no-lock

# R
Rscript /workspace/setup-renv.R 

# Julia
julia --project='/workspace' -e 'using Pkg; Pkg.instantiate(); Pkg.build("IJulia")'

# Node.js
npm install

# Jupyter
bash /workspace/setup/update-jupyter-template.sh
