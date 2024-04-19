#!/usr/bin/bash

# CaboCha
sh /workspace/setup/setup-cabocha.sh

# Python
rye config --set-bool behavior.use-uv=true
rye sync --no-lock

# CaboCha-Python
source /workspace/.venv/bin/activate
cd ~/cabocha-0.69/python/
# cp /workspace/setup/CaboCha.py .
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
ln -s ~/.jupyter/lab/user-settings /workspace/user-settings
